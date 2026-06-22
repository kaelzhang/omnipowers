#!/usr/bin/env python3
"""optimize.py — optimize omnipowers skills with SkillOpt-Sleep.

SkillOpt is an EXTERNAL dependency (not vendored). Point SKILLOPT_HOME at a local
clone of https://github.com/microsoft/SkillOpt (default: ~/Sources/harness/SkillOpt).

What it does, per skill: replay tasks under the skill, propose BOUNDED edits,
gate them on a held-out split, and STAGE a proposal under <repo>/.skillopt-sleep/
(gitignored). It NEVER edits a skill until you `adopt`.

Tasks come from one of two sources, per skill:
  * curated  — <eval-root>/<skill>/tasks.json exists  -> replay that reviewed set.
  * mined    — no eval set                            -> SkillOpt harvests your
               agent transcripts and mines tasks filtered to that skill
               (needs a real backend; mock only does heuristic mining).

Backend is REQUIRED and must be `claude` or `codex` (both call real models and
cost budget). `mock` is test-only and selectable ONLY via OMNIPOWERS_OPTIMIZE_MOCK=1.

Usage:
  optimize.py run    [--skill a,b,c] --backend claude|codex [--model M] [--dry]
                     [--eval-root DIR] [--source claude|codex|auto] [--lookback-hours N]
  optimize.py status [--skill a,b,c]
  optimize.py adopt  --skill NAME          # apply that skill's staged proposal (backup kept)
  optimize.py list                         # every skill: eval set? config? last staged?

Env:
  SKILLOPT_HOME              clone of microsoft/SkillOpt (default ~/Sources/harness/SkillOpt)
  OMNIPOWERS_EVAL_ROOT       where <skill>/tasks.json + config.json live (default <repo>/eval)
  OMNIPOWERS_OPTIMIZE_MOCK   =1 lets the test-only `mock` backend be used
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from typing import Any, Dict, List, Optional, Tuple

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
SKILLS_DIR = os.path.join(REPO, "skills")
ARTIFACT_DIR = os.path.join(REPO, ".skillopt-sleep")          # gitignored
STATE_ROOT = os.path.join(ARTIFACT_DIR, "state")              # per-skill SkillOpt state
INDEX_PATH = os.path.join(ARTIFACT_DIR, "driver-index.json")  # skill -> last staging dir

USER_BACKENDS = ("claude", "codex")
# config.json keys forwarded to SkillOpt (everything else is ignored).
_CONFIG_KEYS = (
    "backend", "model", "gate_mode", "edit_budget", "gate_metric", "gate_mixed_weight",
    "holdout_fraction", "val_fraction", "test_fraction", "source", "lookback_hours",
    "max_tasks_per_night", "max_sessions_per_night", "scope", "seed",
)


def die(msg: str, code: int = 2) -> None:
    print(f"optimize.py: {msg}", file=sys.stderr)
    sys.exit(code)


def _mock_allowed() -> bool:
    return os.environ.get("OMNIPOWERS_OPTIMIZE_MOCK", "").strip().lower() in {"1", "true", "yes"}


def load_skillopt() -> None:
    """Put the external SkillOpt clone on sys.path and verify it imports."""
    home = os.environ.get("SKILLOPT_HOME") or os.path.expanduser("~/Sources/harness/SkillOpt")
    if home not in sys.path:
        sys.path.insert(0, home)
    try:
        import skillopt_sleep  # noqa: F401
    except Exception as exc:  # noqa: BLE001
        die(f"SkillOpt not importable (SKILLOPT_HOME={home}): {exc}\n"
            "        clone https://github.com/microsoft/SkillOpt and set SKILLOPT_HOME")


# ── discovery ────────────────────────────────────────────────────────────────

def all_skills() -> List[str]:
    out = []
    if not os.path.isdir(SKILLS_DIR):
        return out
    for name in sorted(os.listdir(SKILLS_DIR)):
        if os.path.isfile(os.path.join(SKILLS_DIR, name, "SKILL.md")):
            out.append(name)
    return out


def skill_md(name: str) -> str:
    return os.path.join(SKILLS_DIR, name, "SKILL.md")


def eval_root(cli_value: str) -> str:
    return os.path.abspath(
        cli_value or os.environ.get("OMNIPOWERS_EVAL_ROOT") or os.path.join(REPO, "eval")
    )


def tasks_file_for(name: str, root: str) -> str:
    p = os.path.join(root, name, "tasks.json")
    return p if os.path.isfile(p) else ""


def config_for(name: str, root: str) -> Dict[str, Any]:
    p = os.path.join(root, name, "config.json")
    if not os.path.isfile(p):
        return {}
    try:
        with open(p, encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception as exc:  # noqa: BLE001
        die(f"{name}: bad config.json: {exc}")
    return {}


def resolve_targets(skill_arg: str) -> List[str]:
    present = all_skills()
    if not skill_arg:
        if not present:
            die(f"no skills found under {SKILLS_DIR}")
        return present
    want = [s.strip() for s in skill_arg.split(",") if s.strip()]
    missing = [s for s in want if s not in present]
    if missing:
        die(f"unknown skill(s): {', '.join(missing)} (have: {', '.join(present)})")
    return want


def resolve_backend(cli_backend: str, cfg_backend: str) -> str:
    chosen = (cli_backend or cfg_backend or ("mock" if _mock_allowed() else "")).strip().lower()
    if not chosen:
        die("backend required — pass --backend claude|codex (Makefile: BACKEND=claude)")
    if chosen == "mock" and not _mock_allowed():
        die("'mock' is test-only — set OMNIPOWERS_OPTIMIZE_MOCK=1 to use it")
    if chosen not in USER_BACKENDS and chosen != "mock":
        die(f"unsupported backend '{chosen}' — use {' or '.join(USER_BACKENDS)}")
    return chosen


# ── driver-side staging index (so adopt targets the right skill) ─────────────

def _read_index() -> Dict[str, str]:
    try:
        with open(INDEX_PATH, encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception:  # noqa: BLE001
        return {}


def _write_index(idx: Dict[str, str]) -> None:
    os.makedirs(ARTIFACT_DIR, exist_ok=True)
    with open(INDEX_PATH, "w", encoding="utf-8") as f:
        json.dump(idx, f, indent=2)


# ── run ──────────────────────────────────────────────────────────────────────

def _build_overrides(name: str, backend: str, cfg: Dict[str, Any], args) -> Dict[str, Any]:
    """Compose SkillOpt config overrides for ONE skill's consolidate run.

    Every per-skill run replays seed_tasks (curated eval or a slice of the shared
    mined pool), so harvest is skipped here — which also sidesteps SkillOpt's
    per-run `last_harvest` shared-default bug. CLI flags > per-skill config.json.
    """
    ov: Dict[str, Any] = {
        "invoked_project": REPO,
        "projects": "invoked",                          # harvest skipped (seed_tasks given)
        "target_skill_path": skill_md(name),
        "backend": backend,
        "state_dir": os.path.join(STATE_ROOT, name),    # per-skill staging/night isolation
        "evolve_skill": True,
        "evolve_memory": False,                          # never touch repo CLAUDE.md/AGENTS.md
    }
    for k in _CONFIG_KEYS:
        if k in cfg and cfg[k] is not None:
            ov["transcript_source" if k == "source" else k] = cfg[k]
    if args.model:
        ov["model"] = args.model
    if getattr(args, "max_tasks", None) is not None:
        ov["max_tasks_per_night"] = args.max_tasks
    if getattr(args, "progress", False):
        ov["progress"] = True
    return ov


def _read_skill_text(name: str) -> str:
    try:
        with open(skill_md(name), encoding="utf-8") as f:
            return f.read()
    except Exception:  # noqa: BLE001
        return ""


def _harvest_mine_pool(args, backend_name: str):
    """Harvest transcripts + LLM-mine ONCE into a shared candidate task pool.

    The expensive step (LLM mining of the user's sessions) runs a single time and
    feeds every auto-discovery skill, instead of being repeated per skill. Returns
    (pool, n_sessions).
    """
    import time
    from skillopt_sleep.config import load_config
    from skillopt_sleep.harvest_sources import harvest_for_config
    from skillopt_sleep.mine import mine
    from skillopt_sleep.backend import get_backend
    from skillopt_sleep.state import _now_iso

    ov: Dict[str, Any] = {"invoked_project": REPO, "projects": "all", "backend": backend_name}
    if args.model:
        ov["model"] = args.model
    if args.source:
        ov["transcript_source"] = args.source
    if args.lookback_hours is not None:
        ov["lookback_hours"] = args.lookback_hours
    if getattr(args, "max_tasks", None) is not None:
        ov["max_tasks_per_night"] = args.max_tasks
    cfg = load_config(**ov)

    lb = cfg.get("lookback_hours", 72)
    since = _now_iso(time.time() - lb * 3600) if lb and lb > 0 else None
    cap = cfg.get("max_tasks_per_night", 40)
    max_sessions = cfg.get("max_sessions_per_night", 0) or cap * 3
    digests = harvest_for_config(cfg, since_iso=since, limit=max_sessions)
    if not digests:
        return [], 0

    llm_miner = None
    if backend_name != "mock":
        try:
            from skillopt_sleep.llm_miner import make_llm_miner
            be = get_backend(backend_name, model=cfg.get("model", ""),
                             codex_path="", project_dir=REPO)
            llm_miner = make_llm_miner(be, max_sessions=max_sessions, max_tasks=cap * 3)
        except Exception:  # noqa: BLE001
            llm_miner = None

    pool = mine(digests, llm_miner=llm_miner, target_skill_text="", target_skill_path="",
                max_tasks=cap * 3, candidate_limit=cap * 3,
                holdout_fraction=cfg.get("holdout_fraction", 0.34), seed=cfg.get("seed", 42))
    return pool, len(digests)


def cmd_run(args) -> int:
    load_skillopt()
    import copy
    from skillopt_sleep.config import load_config
    from skillopt_sleep.cycle import run_sleep_cycle
    from skillopt_sleep.tasks_file import load_tasks_file
    from skillopt_sleep.mine import assign_splits, filter_tasks_for_target

    root = eval_root(args.eval_root)
    targets = resolve_targets(args.skill)
    idx = _read_index()
    rows: List[Dict[str, Any]] = []

    # Auto-discovery skills (no curated eval) share ONE harvest+mine pass — the
    # expensive LLM mining runs once, not once per skill. Every per-skill run
    # below replays seed_tasks and never harvests, so SkillOpt's per-run
    # last_harvest shared-default bug cannot bite.
    mine_targets = [n for n in targets if not tasks_file_for(n, root)]
    pool: List[Any] = []
    n_sessions = 0
    if mine_targets:
        pool_backend = resolve_backend(args.backend, str(config_for(mine_targets[0], root).get("backend", "")))
        pool, n_sessions = _harvest_mine_pool(args, pool_backend)
        if not args.json:
            print(f"[optimize] shared pool: {n_sessions} session(s) → {len(pool)} mined task(s), "
                  f"harvested + mined once for {len(mine_targets)} auto-discovery skill(s)")

    for name in targets:
        cfg = config_for(name, root)
        backend = resolve_backend(args.backend, str(cfg.get("backend", "")))
        scfg = load_config(**_build_overrides(name, backend, cfg, args))
        cap = scfg.get("max_tasks_per_night", 40)
        frac = scfg.get("holdout_fraction", 0.34)
        seed = scfg.get("seed", 42)

        tf = tasks_file_for(name, root)
        if tf:
            seed_tasks, meta = load_tasks_file(tf, holdout_fraction=frac, seed=seed)
            source = "eval"
            if backend != "mock" and meta.get("reviewed") is not True:
                print(f"[skip] {name}: real-backend replay refused — {tf} is not "
                      'reviewed (set "reviewed": true after inspecting it)', file=sys.stderr)
                rows.append({"skill": name, "source": "eval:refused", "tasks": 0, "baseline": None,
                             "candidate": None, "gate": "refused", "accepted": False, "staging": ""})
                continue
        else:
            source = "mined"
            relevant = filter_tasks_for_target(pool, _read_skill_text(name), skill_md(name)) if pool else []
            if relevant is pool:                  # identity sentinel → nothing matched this skill
                relevant = []
            relevant = copy.deepcopy(list(relevant)[:cap])
            seed_tasks = assign_splits(relevant, holdout_fraction=frac, seed=seed) if relevant else []
            if not seed_tasks:
                rows.append({"skill": name, "source": "mined:0", "tasks": 0, "baseline": None,
                             "candidate": None, "gate": "", "accepted": False, "staging": ""})
                continue

        outcome = run_sleep_cycle(scfg, seed_tasks=seed_tasks, dry_run=bool(args.dry))
        rep = outcome.report
        if not args.dry and outcome.staging_dir:
            idx[name] = outcome.staging_dir
        rows.append({
            "skill": name,
            "source": f"{source}:{rep.n_tasks}",
            "tasks": rep.n_tasks,
            "baseline": rep.baseline_score,
            "candidate": rep.candidate_score,
            "gate": rep.gate_action,
            "accepted": rep.accepted,
            "staging": outcome.staging_dir or "",
        })

    if not args.dry:
        _write_index(idx)

    if args.json:
        print(json.dumps({"dry_run": bool(args.dry), "backend_default": args.backend,
                          "n_sessions": n_sessions, "results": rows}, ensure_ascii=False, indent=2))
    else:
        _print_table(rows, dry=bool(args.dry))
    return 0


def _fmt_score(v: Optional[float]) -> str:
    return "  -  " if v is None else f"{v:.3f}"


def _print_table(rows: List[Dict[str, Any]], *, dry: bool) -> None:
    if not rows:
        print("[optimize] nothing to do")
        return
    w = max((len(r["skill"]) for r in rows), default=5)
    print(f"[optimize] {'(dry-run, no staging) ' if dry else ''}{len(rows)} skill(s)")
    print(f"  {'skill'.ljust(w)}  {'source':<10}  {'base':>5} {'cand':>5}  {'gate':<16} staged")
    for r in rows:
        staged = "yes" if r["staging"] else ("-" if not r["accepted"] else "")
        print(f"  {r['skill'].ljust(w)}  {r['source']:<10}  "
              f"{_fmt_score(r['baseline']):>5} {_fmt_score(r['candidate']):>5}  "
              f"{r['gate']:<16} {staged}")
    if not dry and any(r["staging"] for r in rows):
        print("\n[optimize] review with `make optimize-status SKILL=<name>`, "
              "then `make optimize-adopt SKILL=<name>`")


# ── status / adopt / list ─────────────────────────────────────────────────────

def cmd_status(args) -> int:
    targets = resolve_targets(args.skill) if args.skill else sorted(_read_index())
    if not targets:
        print("[optimize] no staged proposals yet — run `make optimize` first")
        return 0
    idx = _read_index()
    for name in targets:
        staging = idx.get(name, "")
        print(f"\n=== {name} ===")
        if not staging or not os.path.isdir(staging):
            print("  (no staged proposal)")
            continue
        print(f"  staged: {staging}")
        report = os.path.join(staging, "report.md")
        if os.path.isfile(report):
            with open(report, encoding="utf-8") as f:
                print("\n" + f.read())
    return 0


def cmd_adopt(args) -> int:
    if not args.skill or "," in args.skill:
        die("adopt takes exactly one skill: --skill NAME")
    name = resolve_targets(args.skill)[0]
    idx = _read_index()
    staging = idx.get(name, "")
    if not staging or not os.path.isdir(staging):
        die(f"{name}: no staged proposal to adopt (run `make optimize SKILL={name}` first)")
    load_skillopt()
    from skillopt_sleep.staging import adopt as adopt_staging
    updated = adopt_staging(staging)
    if not updated:
        print(f"[optimize] {name}: proposal contained no accepted changes")
        return 0
    print(f"[optimize] {name}: adopted from {staging}")
    for p in updated:
        print(f"   -> {p}")
    idx.pop(name, None)
    _write_index(idx)
    return 0


def cmd_list(args) -> int:
    root = eval_root(args.eval_root)
    idx = _read_index()
    skills = all_skills()
    if not skills:
        print(f"[optimize] no skills under {SKILLS_DIR}")
        return 0
    w = max(len(s) for s in skills)
    print(f"[optimize] eval-root: {root}")
    print(f"  {'skill'.ljust(w)}  eval  config  staged")
    for name in skills:
        ev = "eval" if tasks_file_for(name, root) else "mine"
        cf = "yes" if os.path.isfile(os.path.join(root, name, "config.json")) else " - "
        st = "yes" if (idx.get(name) and os.path.isdir(idx[name])) else " - "
        print(f"  {name.ljust(w)}  {ev:<4}  {cf:<6}  {st}")
    return 0


# ── cli ────────────────────────────────────────────────────────────────────────

def _add_run_flags(p: argparse.ArgumentParser) -> None:
    p.add_argument("--skill", default="", help="comma list (a,b,c); empty = all skills")
    p.add_argument("--backend", default="", help="claude | codex (required for normal use)")
    p.add_argument("--model", default="", help="backend model override")
    p.add_argument("--dry", action="store_true", help="report only; do not stage")
    p.add_argument("--eval-root", default="", help="dir of <skill>/tasks.json + config.json")
    p.add_argument("--source", default="", choices=["", "claude", "codex", "auto"],
                   help="transcript source for auto-discovery")
    p.add_argument("--lookback-hours", type=int, default=None,
                   help="auto-discovery harvest window (0 = full history)")
    p.add_argument("--max-tasks", type=int, default=None,
                   help="cap mined candidate pool + per-skill task count (cost control)")
    p.add_argument("--progress", action="store_true",
                   help="stream SkillOpt phase progress (harvest/mine/consolidate) to stderr")
    p.add_argument("--json", action="store_true", help="machine-readable output")


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="optimize.py", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_run = sub.add_parser("run", help="optimize skill(s) -> staged proposals")
    _add_run_flags(p_run)
    p_status = sub.add_parser("status", help="show staged proposals")
    p_status.add_argument("--skill", default="", help="comma list; empty = all staged")
    p_adopt = sub.add_parser("adopt", help="apply one skill's staged proposal (backup kept)")
    p_adopt.add_argument("--skill", default="", help="exactly one skill name")
    p_list = sub.add_parser("list", help="list skills + eval/config/staged state")
    p_list.add_argument("--eval-root", default="")

    args = parser.parse_args(argv)
    if args.cmd == "run":
        return cmd_run(args)
    if args.cmd == "status":
        return cmd_status(args)
    if args.cmd == "adopt":
        return cmd_adopt(args)
    if args.cmd == "list":
        return cmd_list(args)
    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
