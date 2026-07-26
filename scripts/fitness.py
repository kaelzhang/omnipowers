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


def cmd_triggers(args) -> int:
    sc = harness_dir()
    skill_path = os.path.join(SKILLS_DIR, args.skill)
    if not os.path.isfile(os.path.join(skill_path, "SKILL.md")):
        sys.exit(f"fitness.py: no such skill: {args.skill}")
    eval_set = args.eval_set or os.path.join(
        os.environ.get("OMNIPOWERS_FITNESS_ROOT", ""), args.skill, "triggers.json"
    )
    if not os.path.isfile(eval_set):
        sys.exit(f"fitness.py: eval set not found: {eval_set}")

    cmd = [
        sys.executable,
        os.path.join(sc, "scripts", "run_eval.py"),
        "--eval-set", os.path.abspath(eval_set),
        "--skill-path", os.path.abspath(skill_path),
        "--runs-per-query", str(args.runs),
        "--verbose",
    ]
    if args.model:
        cmd += ["--model", args.model]
    env = dict(os.environ, PYTHONPATH=sc + os.pathsep + os.environ.get("PYTHONPATH", ""))
    # CLEAN-ROOM: the harness tests whether the DESCRIPTION triggers, via a
    # synthetic command. Two contaminants invalidate it: (1) the real skill
    # installed globally shadows the synthetic command; (2) a real project cwd
    # invites the model to just start working (first tool = Bash) instead of
    # reaching for any skill. So run from an EMPTY scratch project dir — and
    # uninstall the collection first (`make uninstall`), reinstall after.
    import tempfile
    scratch = tempfile.mkdtemp(prefix="omnipowers_fitness_")
    os.makedirs(os.path.join(scratch, ".claude"), exist_ok=True)
    if os.path.isdir(os.path.expanduser("~/.claude/skills/" + args.skill)):
        print(f"[fitness] WARNING: {args.skill} is still installed globally "
              f"(~/.claude/skills) — it will shadow the synthetic command and "
              f"zero the measurement. Run `make uninstall` first.", file=sys.stderr)
    proc = subprocess.run(cmd, cwd=scratch, env=env, capture_output=True, text=True)
    sys.stderr.write(proc.stderr)
    out = proc.stdout.strip()
    print(out)
    if proc.returncode != 0:
        return proc.returncode

    # Defensive summary: precision/recall over the harness's per-query JSON.
    try:
        data = json.loads(out)
        rows = data if isinstance(data, list) else data.get("results", [])
        tp = sum(1 for r in rows if r.get("should_trigger") and r.get("triggered"))
        fp = sum(1 for r in rows if not r.get("should_trigger") and r.get("triggered"))
        fn = sum(1 for r in rows if r.get("should_trigger") and not r.get("triggered"))
        if tp + fp + fn:
            p = tp / (tp + fp) if tp + fp else 1.0
            r = tp / (tp + fn) if tp + fn else 1.0
            print(f"\n[fitness] {args.skill}: trigger precision={p:.2f} recall={r:.2f} "
                  f"(tp={tp} fp={fp} fn={fn})", file=sys.stderr)
    except Exception:
        pass  # schema drift in the harness output — raw JSON above is authoritative
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


def main() -> int:
    p = argparse.ArgumentParser(prog="fitness.py", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("triggers", help="trigger precision/recall for one skill")
    t.add_argument("--skill", required=True)
    t.add_argument("--eval-set", default="")
    t.add_argument("--runs", type=int, default=3)
    t.add_argument("--model", default="")
    v = sub.add_parser("validate", help="structural validation of all skills")
    args = p.parse_args()
    if args.cmd == "triggers":
        return cmd_triggers(args)
    if args.cmd == "validate":
        return cmd_validate(args)
    return 2


if __name__ == "__main__":
    sys.exit(main())
