#!/usr/bin/env python3
"""fitness.py — skill fitness review tooling for omnipowers.

Wraps the official Anthropic skill-creator eval harness (EXTERNAL dependency,
not vendored). Point SKILLCREATOR_HOME at a clone of
https://github.com/anthropics/skills (default: ~/Sources/harness/anthropic-skills).

Commands:
  triggers --skill NAME --eval-set FILE [--runs N] [--model M]
      Trigger fitness for one skill: runs the harness's run_eval.py against an
      eval set of queries labelled should_trigger true/false, then summarizes
      precision/recall. Uses `claude -p` under the hood (needs an authenticated CLI).
  validate
      Structural validation of every skill via the harness's quick_validate.py.

Eval sets are maintained OUTSIDE this repo (they are dev data, not product);
pass their path explicitly or set OMNIPOWERS_FITNESS_ROOT.
See FITNESS.md for the full review pipeline and decision rules.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
SKILLS_DIR = os.path.join(REPO, "skills")


def harness_dir() -> str:
    home = os.environ.get("SKILLCREATOR_HOME") or os.path.expanduser(
        "~/Sources/harness/anthropic-skills"
    )
    sc = os.path.join(home, "skills", "skill-creator")
    if not os.path.isfile(os.path.join(sc, "scripts", "run_eval.py")):
        sys.exit(
            f"fitness.py: harness not found under {home} — clone "
            "https://github.com/anthropics/skills and/or set SKILLCREATOR_HOME"
        )
    return sc


def _run_one_trigger(query: str, description: str, skill_name: str, timeout: int, model: str,
                     fixture_dir: str = "", accept: list | None = None) -> bool:
    """One clean-room trigger run: does the DESCRIPTION get the model to invoke
    the synthetic command for this query?

    Protocol (adapted from the skill-creator harness): an empty scratch project
    carries ONE synthetic command whose body is the description under test; we
    run `claude -p <query>` and scan the WHOLE stream for a Skill/SlashCommand
    tool_use naming it. We deliberately do NOT require the first tool to be
    Skill — current models explore first (Bash/Read) and invoke the skill
    after, which the harness's first-tool criterion miscounts as no-trigger.
    """
    import tempfile, shutil, uuid
    salt = uuid.uuid4().hex[:8]
    # Chain-aware acceptance: a trigger counts when ANY accepted skill fires
    # (default: only the skill under test). Lets a bug-phrased query legitimately
    # route to the debugging sibling per the collection's own designed flow.
    accept_names = [f"{s}-skill-{salt}" for s in (accept or [skill_name])]
    clean_name = f"{skill_name}-skill-{salt}"
    scratch = tempfile.mkdtemp(prefix="omnipowers_fitness_")
    try:
        # v2: seed the scratch with a fixture project so repo-contextual queries
        # are ecologically plausible ("add a toggle" needs a codebase to exist).
        if fixture_dir:
            shutil.copytree(fixture_dir, scratch, dirs_exist_ok=True)
            setup = os.path.join(scratch, "setup.sh")
            if os.path.isfile(setup):
                subprocess.run(["bash", "setup.sh"], cwd=scratch,
                               capture_output=True, timeout=30)
                os.unlink(setup)
        cdir = os.path.join(scratch, ".claude", "commands")
        os.makedirs(cdir, exist_ok=True)
        # Plant the WHOLE collection's descriptions as synthetic commands, not
        # just the skill under test: with a single candidate, every query grabs
        # the only tool available and precision reads falsely low. Competition
        # lets negatives route to their true home.
        for other in sorted(os.listdir(SKILLS_DIR)):
            sk_md = os.path.join(SKILLS_DIR, other, "SKILL.md")
            if not os.path.isfile(sk_md):
                continue
            d = ""
            with open(sk_md, encoding="utf-8") as f:
                for line in f:
                    if line.startswith("description:"):
                        d = line.split(":", 1)[1].strip().strip('"')
                        break
            if other == skill_name:
                d = description  # allow --description-style overrides later
            name = f"{other}-skill-{salt}"
            indented = "\n  ".join(d.split("\n"))
            with open(os.path.join(cdir, f"{name}.md"), "w", encoding="utf-8") as f:
                f.write(f"---\ndescription: |\n  {indented}\n---\n\n# {other}\n\n"
                        f"This skill handles: {d}\n")
        cmd = ["claude", "-p", query, "--output-format", "stream-json",
               "--verbose", "--include-partial-messages"]
        if model:
            cmd += ["--model", model]
        env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                                cwd=scratch, env=env, text=True)
        import time as _t
        deadline = _t.time() + timeout
        saw_assistant = False
        try:
            for line in proc.stdout:
                if _t.time() > deadline:
                    break
                line = line.strip()
                if not line:
                    continue
                if '"type": "assistant"' in line or '"type":"assistant"' in line:
                    saw_assistant = True
                # A limit/error result poisons the run even when assistant events
                # were emitted (usage-limit replies arrive AS assistant messages).
                if '"type": "result"' in line or '"type":"result"' in line:
                    try:
                        res = json.loads(line)
                        if res.get("is_error") or res.get("api_error_status") or \
                           "limit" in str(res.get("result", "")).lower()[:200]:
                            return None
                    except Exception:
                        pass
                if not any(n in line for n in accept_names):
                    continue
                # Both the init/system event AND an early user event list EVERY
                # planted command — matching a listing would count as invocation.
                # Only an assistant tool_use naming the command is a trigger.
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                if e.get("type") == "assistant" and '"tool_use"' in line:
                    return True
            # A run with NO assistant events at all is an errored run (auth/rate
            # failure), not a non-trigger — report it as invalid, never as False.
            return False if saw_assistant else None
        except Exception:
            return None
        finally:
            proc.kill()
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def cmd_triggers(args) -> int:
    from concurrent.futures import ThreadPoolExecutor
    skill_path = os.path.join(SKILLS_DIR, args.skill)
    if not os.path.isfile(os.path.join(skill_path, "SKILL.md")):
        sys.exit(f"fitness.py: no such skill: {args.skill}")
    eval_set = args.eval_set or os.path.join(
        os.environ.get("OMNIPOWERS_FITNESS_ROOT", ""), args.skill, "triggers.json"
    )
    if not os.path.isfile(eval_set):
        sys.exit(f"fitness.py: eval set not found: {eval_set}")
    if os.path.isdir(os.path.expanduser("~/.claude/skills/" + args.skill)):
        print(f"[fitness] WARNING: {args.skill} is installed globally — it will "
              f"shadow the synthetic command. Run `make uninstall` first.", file=sys.stderr)

    # description from frontmatter
    desc = ""
    with open(os.path.join(skill_path, "SKILL.md"), encoding="utf-8") as f:
        for line in f:
            if line.startswith("description:"):
                desc = line.split(":", 1)[1].strip().strip('"')
                break
    if not desc:
        sys.exit("fitness.py: no description frontmatter found")

    with open(eval_set, encoding="utf-8") as f:
        cases = json.load(f)

    fixtures_root = args.fixtures_root or os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(eval_set))), "fixtures"
    )

    def eval_case(c):
        fx = ""
        if c.get("fixture"):
            fx = os.path.join(fixtures_root, c["fixture"])
            if not os.path.isdir(fx):
                sys.exit(f"fitness.py: fixture not found: {fx}")
        hits = valid = invalid = 0
        for _ in range(args.runs):
            r = _run_one_trigger(c["query"], desc, args.skill, args.timeout, args.model, fx,
                                 c.get("accept"))
            if r is None:  # errored run — retry once, then count as invalid
                r = _run_one_trigger(c["query"], desc, args.skill, args.timeout, args.model, fx,
                                     c.get("accept"))
            if r is None:
                invalid += 1
                continue
            valid += 1
            hits += 1 if r else 0
        if not valid:
            return {"query": c["query"], "should_trigger": c["should_trigger"],
                    "trigger_rate": None, "triggered": None, "pass": None,
                    "invalid_runs": invalid}
        rate = hits / valid
        triggered = rate >= 0.5
        return {"query": c["query"], "should_trigger": c["should_trigger"],
                "trigger_rate": rate, "triggered": triggered,
                "pass": triggered == c["should_trigger"], "invalid_runs": invalid}

    # Warmup: one serial call refreshes an expired OAuth token BEFORE the
    # parallel batch — N workers racing a refresh invalidate each other and
    # every later run errors out as a silent non-trigger.
    subprocess.run(["claude", "-p", "Reply OK", "--output-format", "json"],
                   capture_output=True, timeout=90,
                   env={k: v for k, v in os.environ.items() if k != "CLAUDECODE"})

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        rows = list(ex.map(eval_case, cases))

    for r in rows:
        mark = "PASS" if r["pass"] else ("FAIL" if r["pass"] is False else "INVALID")
        rate = "n/a " if r["trigger_rate"] is None else f"{r['trigger_rate']:.2f}"
        inv = f" invalid={r['invalid_runs']}" if r.get("invalid_runs") else ""
        print(f"  [{mark}] rate={rate} expected={r['should_trigger']}{inv}: {r['query']}")
    n_invalid = sum(1 for r in rows if r["pass"] is None)
    if n_invalid:
        print(f"\n[fitness] {args.skill}: {n_invalid} query(ies) INVALID (errored runs) — "
              f"metrics below exclude them; rerun after checking CLI auth", file=sys.stderr)
    rows_v = [r for r in rows if r["pass"] is not None]
    tp = sum(1 for r in rows_v if r["should_trigger"] and r["triggered"])
    fp = sum(1 for r in rows_v if not r["should_trigger"] and r["triggered"])
    fn = sum(1 for r in rows_v if r["should_trigger"] and not r["triggered"])
    p = tp / (tp + fp) if tp + fp else 1.0
    rc = tp / (tp + fn) if tp + fn else 1.0
    print(f"\n[fitness] {args.skill}: trigger precision={p:.2f} recall={rc:.2f} (tp={tp} fp={fp} fn={fn})")
    print(json.dumps({"skill": args.skill, "results": rows}, ensure_ascii=False))
    return 0


def cmd_validate(args) -> int:
    sc = harness_dir()
    env = dict(os.environ, PYTHONPATH=sc + os.pathsep + os.environ.get("PYTHONPATH", ""))
    rc = 0
    for name in sorted(os.listdir(SKILLS_DIR)):
        sk = os.path.join(SKILLS_DIR, name)
        if not os.path.isfile(os.path.join(sk, "SKILL.md")):
            continue
        proc = subprocess.run(
            [sys.executable, os.path.join(sc, "scripts", "quick_validate.py"), sk],
            cwd=REPO, env=env, capture_output=True, text=True,
        )
        status = "ok" if proc.returncode == 0 else "FAIL"
        line = (proc.stdout or proc.stderr).strip().splitlines()
        detail = line[-1] if line else ""
        print(f"  {status:4} {name}  {detail if status == 'FAIL' else ''}")
        rc |= proc.returncode
    return rc


def preflight_cli(model: str = "") -> tuple[bool, str]:
    """One cheap `claude -p` call to prove the CLI can actually reach the API.

    Without this, an expired OAuth token turns a whole review round into pages of
    silently INVALID runs that look like a protocol bug. Returns (ok, detail).
    """
    import tempfile
    scratch = tempfile.mkdtemp(prefix="omnipowers_preflight_")
    cmd = ["claude", "-p", "reply with the single word ok",
           "--output-format", "stream-json", "--verbose", "--include-partial-messages"]
    if model:
        cmd += ["--model", model]
    env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
    try:
        proc = subprocess.run(cmd, cwd=scratch, env=env, capture_output=True,
                              text=True, timeout=120)
    except FileNotFoundError:
        return False, "`claude` CLI not found on PATH"
    except subprocess.TimeoutExpired:
        return False, "`claude` CLI timed out on a trivial prompt"
    for line in (proc.stdout or "").splitlines():
        try:
            e = json.loads(line)
        except Exception:
            continue
        if e.get("type") == "result":
            if e.get("is_error") or e.get("api_error_status"):
                return False, str(e.get("result") or e.get("api_error_status"))
            return True, "ok"
        if e.get("error") == "authentication_failed":
            return False, "authentication_failed — the CLI needs an interactive re-login"
    return False, "no result event from the CLI"


def _skills_installed() -> list:
    root = os.path.expanduser("~/.claude/skills")
    if not os.path.isdir(root):
        return []
    ours = {d for d in os.listdir(SKILLS_DIR)
            if os.path.isfile(os.path.join(SKILLS_DIR, d, "SKILL.md"))}
    return sorted(ours & set(os.listdir(root)))


# A long injected skill times out under worker contention and its runs are
# discarded from one arm only, which biases the delta. Run those serially.
LARGE_SKILL_BYTES = 12000


def cmd_round(args) -> int:
    """Run a whole fitness review: preflight, trigger evals, behavioral A/B."""
    root = args.fitness_root or os.environ.get("OMNIPOWERS_FITNESS_ROOT", "")
    if not root or not os.path.isdir(root):
        sys.exit("fitness.py: pass --fitness-root or set OMNIPOWERS_FITNESS_ROOT")
    skills = ([s.strip() for s in args.skills.split(",") if s.strip()] if args.skills
              else sorted(d for d in os.listdir(SKILLS_DIR)
                          if os.path.isfile(os.path.join(SKILLS_DIR, d, "SKILL.md"))))

    print("[round] preflight: checking the CLI can reach the API ...", flush=True)
    ok, detail = preflight_cli(args.model)
    if not ok:
        sys.exit(f"[round] ABORT — the `claude` CLI cannot run: {detail}\n"
                 f"        Every run would be scored INVALID. Re-authenticate "
                 f"(run `claude` once interactively and sign in), then retry.")
    print("[round] preflight ok", flush=True)

    if args.phase in ("all", "triggers"):
        installed = _skills_installed()
        if installed:
            sys.exit(f"[round] ABORT — these skills are installed globally and would "
                     f"shadow the synthetic command, zeroing every trigger measurement: "
                     f"{', '.join(installed)}\n        Run `make uninstall` first, and "
                     f"`make dev` after the round.")

    rc = 0
    summary: list[str] = []
    for skill in skills:
        if args.phase in ("all", "triggers"):
            es = os.path.join(root, skill, "triggers.json")
            if os.path.isfile(es):
                print(f"\n──── triggers: {skill} ────", flush=True)
                targs = argparse.Namespace(skill=skill, eval_set=es, runs=args.runs,
                                           timeout=args.timeout, workers=args.workers,
                                           fixtures_root=os.path.join(root, "fixtures"),
                                           model=args.model)
                rc |= cmd_triggers(targs)
            else:
                summary.append(f"  {skill}: no trigger eval set — not measured")
        if args.phase in ("all", "compliance"):
            sc = os.path.join(root, skill, "compliance.json")
            if not os.path.isfile(sc):
                summary.append(f"  {skill}: no compliance scenarios — not measured")
                continue
            size = os.path.getsize(os.path.join(SKILLS_DIR, skill, "SKILL.md"))
            workers = 1 if size >= LARGE_SKILL_BYTES else args.workers
            print(f"\n──── compliance: {skill} "
                  f"({'serial — large skill' if workers == 1 else f'{workers} workers'}) ────",
                  flush=True)
            proc = subprocess.run(
                [sys.executable, os.path.join(REPO, "scripts", "compliance.py"), "run",
                 "--skill", skill, "--scenarios", sc,
                 "--fixtures-root", os.path.join(root, "fixtures"),
                 "--runs", str(args.runs), "--workers", str(workers),
                 "--timeout", str(args.compliance_timeout)]
                + (["--model", args.model] if args.model else []))
            rc |= proc.returncode

    if summary:
        print("\n[round] not measured:")
        for line in summary:
            print(line)
    return rc


def main() -> int:
    p = argparse.ArgumentParser(prog="fitness.py", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("triggers", help="trigger precision/recall for one skill")
    t.add_argument("--skill", required=True)
    t.add_argument("--eval-set", default="")
    t.add_argument("--runs", type=int, default=3)
    t.add_argument("--timeout", type=int, default=90, help="seconds per run")
    t.add_argument("--workers", type=int, default=4)
    t.add_argument("--fixtures-root", default="", help="dir of fixture archetypes (default: <eval-set>/../../fixtures)")
    t.add_argument("--model", default="")
    v = sub.add_parser("validate", help="structural validation of all skills")
    r = sub.add_parser("round", help="a whole fitness review: preflight + triggers + A/B")
    r.add_argument("--skills", default="", help="comma-separated; default every skill")
    r.add_argument("--phase", choices=["all", "triggers", "compliance"], default="all")
    r.add_argument("--fitness-root", default="", help="dir holding <skill>/{triggers,compliance}.json + fixtures/")
    r.add_argument("--runs", type=int, default=3)
    r.add_argument("--timeout", type=int, default=90, help="seconds per trigger run")
    r.add_argument("--compliance-timeout", type=int, default=300, help="seconds per A/B run")
    r.add_argument("--workers", type=int, default=4)
    r.add_argument("--model", default="")
    args = p.parse_args()
    if args.cmd == "triggers":
        return cmd_triggers(args)
    if args.cmd == "validate":
        return cmd_validate(args)
    if args.cmd == "round":
        return cmd_round(args)
    return 2


if __name__ == "__main__":
    sys.exit(main())
