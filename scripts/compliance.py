#!/usr/bin/env python3
"""compliance.py — behavioral A/B: does a skill change what the agent DOES?

Trigger evals answer "does the description fire?". This answers the question that
decides a skill's fate: **compliance delta vs a no-skill control**. For each
scenario we run the same task twice in an identical fixture — once with the skill
text injected, once without — and grade both transcripts against the skill's own
expectations with an independent judge. The delta is the skill's measured value.

Scenario sets live outside this repo (dev data):
  <fitness-root>/<skill>/compliance.json =
    [{"prompt": "...", "fixture": "webapp", "expectations": ["...", "..."]}, ...]

Usage:
  compliance.py run --skill NAME [--scenarios FILE] [--fixtures-root DIR]
                   [--runs N] [--workers N] [--timeout SEC] [--model M]

Grading is done by `claude -p` with a strict rubric; each arm is graded blind
(the judge never learns which arm produced the transcript).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from concurrent.futures import ThreadPoolExecutor

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
SKILLS_DIR = os.path.join(REPO, "skills")


def _env():
    return {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}


def _claude(prompt: str, cwd: str, timeout: int, model: str = "") -> tuple[str, bool]:
    """Run one non-interactive turn. Returns (text, valid). valid=False on
    auth/limit/API errors so a poisoned run is never scored as behavior."""
    cmd = ["claude", "-p", prompt, "--output-format", "json"]
    if model:
        cmd += ["--model", model]
    try:
        p = subprocess.run(cmd, cwd=cwd, env=_env(), capture_output=True,
                           text=True, timeout=timeout)
        data = json.loads(p.stdout or "{}")
    except Exception:
        return "", False
    if data.get("is_error") or data.get("api_error_status"):
        return "", False
    text = str(data.get("result", ""))
    if not text.strip() or re.search(r"usage limit|rate limit", text[:300], re.I):
        return "", False
    return text, True


def _fixture_scratch(fixtures_root: str, fixture: str) -> str:
    scratch = tempfile.mkdtemp(prefix="omnipowers_compliance_")
    if fixture:
        src = os.path.join(fixtures_root, fixture)
        if not os.path.isdir(src):
            sys.exit(f"compliance.py: fixture not found: {src}")
        shutil.copytree(src, scratch, dirs_exist_ok=True)
        setup = os.path.join(scratch, "setup.sh")
        if os.path.isfile(setup):
            subprocess.run(["bash", "setup.sh"], cwd=scratch, capture_output=True, timeout=30)
            os.unlink(setup)
    return scratch


def _grade(transcript: str, expectations: list[str], timeout: int, model: str) -> tuple[int, str]:
    """Blind grade: how many expectations does this transcript satisfy?"""
    exp = "\n".join(f"{i+1}. {e}" for i, e in enumerate(expectations))
    prompt = (
        "You are grading an AI assistant's response against explicit expectations. "
        "Be STRICT: an expectation passes only if the response actually demonstrates it — "
        "mentioning the idea is not doing it. You do not know how the response was produced; "
        "judge only what is written.\n\n"
        f"--- EXPECTATIONS ---\n{exp}\n\n"
        f"--- RESPONSE ---\n{transcript[:12000]}\n--- END ---\n\n"
        'Reply with ONLY JSON: {"passed": [<numbers of satisfied expectations>], '
        '"reason": "<one sentence>"}'
    )
    scratch = tempfile.mkdtemp(prefix="omnipowers_grade_")
    try:
        out, valid = _claude(prompt, scratch, timeout, model)
        if not valid:
            return -1, "grading run invalid"
        m = re.search(r"\{.*\}", out, re.S)
        if not m:
            return -1, "unparseable grade"
        g = json.loads(m.group(0))
        return len(g.get("passed", [])), str(g.get("reason", ""))[:160]
    except Exception:
        return -1, "grade error"
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def cmd_run(args) -> int:
    skill_md = os.path.join(SKILLS_DIR, args.skill, "SKILL.md")
    if not os.path.isfile(skill_md):
        sys.exit(f"compliance.py: no such skill: {args.skill}")
    scen_file = args.scenarios or os.path.join(
        os.environ.get("OMNIPOWERS_FITNESS_ROOT", ""), args.skill, "compliance.json")
    if not os.path.isfile(scen_file):
        sys.exit(f"compliance.py: scenarios not found: {scen_file}")
    with open(scen_file, encoding="utf-8") as f:
        scenarios = json.load(f)
    # Fixtures root: explicit flag → OMNIPOWERS_FITNESS_ROOT → beside the
    # scenario file. Deriving only from the scenario path breaks the moment a
    # scenario lives outside the fitness tree (e.g. a scratch file in /tmp).
    fixtures_root = args.fixtures_root or (
        os.path.join(os.environ["OMNIPOWERS_FITNESS_ROOT"], "fixtures")
        if os.environ.get("OMNIPOWERS_FITNESS_ROOT") else
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(scen_file))), "fixtures"))
    with open(skill_md, encoding="utf-8") as f:
        skill_text = f.read()

    if os.path.isdir(os.path.expanduser(f"~/.claude/skills/{args.skill}")):
        print(f"[compliance] WARNING: {args.skill} is installed globally — the CONTROL "
              f"arm would still see it. Run `make uninstall` first.", file=sys.stderr)

    # Serial warmup so a token refresh never races the parallel batch.
    _claude("Reply OK", tempfile.mkdtemp(prefix="omnipowers_warm_"), 60, args.model)

    def one_run(sc: dict, arm: str) -> tuple[int, int, bool]:
        scratch = _fixture_scratch(fixtures_root, sc.get("fixture", ""))
        try:
            prompt = sc["prompt"] if arm == "control" else (
                "A skill governs how you must handle this kind of request. Follow it exactly.\n\n"
                f"--- SKILL ---\n{skill_text}\n--- END SKILL ---\n\n{sc['prompt']}"
            )
            text, valid = _claude(prompt, scratch, args.timeout, args.model)
            if not valid:
                return 0, 0, False
            n, _ = _grade(text, sc["expectations"], args.timeout, args.model)
            if n < 0:
                return 0, 0, False
            return n, len(sc["expectations"]), True
        finally:
            shutil.rmtree(scratch, ignore_errors=True)

    jobs = [(sc, arm, r) for sc in scenarios for arm in ("control", "skill")
            for r in range(args.runs)]
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        out = list(ex.map(lambda j: (j[1], *one_run(j[0], j[1])), jobs))

    agg = {}
    for arm, hit, total, valid in out:
        a = agg.setdefault(arm, {"hit": 0, "total": 0, "invalid": 0})
        if valid:
            a["hit"] += hit
            a["total"] += total
        else:
            a["invalid"] += 1

    def rate(a):
        return a["hit"] / a["total"] if a["total"] else float("nan")

    c, s = agg.get("control", {"hit": 0, "total": 0, "invalid": 0}), agg.get("skill", {"hit": 0, "total": 0, "invalid": 0})
    print(f"[compliance] {args.skill}: control={rate(c):.2f} skill={rate(s):.2f} "
          f"DELTA={rate(s)-rate(c):+.2f}  (invalid: control={c['invalid']} skill={s['invalid']})")
    print(json.dumps({"skill": args.skill, "control": c, "skill_arm": s,
                      "control_rate": rate(c), "skill_rate": rate(s),
                      "delta": rate(s) - rate(c)}, ensure_ascii=False))
    return 0


def main() -> int:
    p = argparse.ArgumentParser(prog="compliance.py", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("run", help="behavioral A/B for one skill")
    r.add_argument("--skill", required=True)
    r.add_argument("--scenarios", default="")
    r.add_argument("--fixtures-root", default="")
    r.add_argument("--runs", type=int, default=2)
    r.add_argument("--workers", type=int, default=3)
    r.add_argument("--timeout", type=int, default=300)  # long skills need long turns
    r.add_argument("--model", default="")
    args = p.parse_args()
    return cmd_run(args) if args.cmd == "run" else 2


if __name__ == "__main__":
    sys.exit(main())
