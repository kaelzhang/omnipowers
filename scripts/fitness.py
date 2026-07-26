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


def _run_one_trigger(query: str, description: str, skill_name: str, timeout: int, model: str) -> bool:
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
    clean_name = f"{skill_name}-skill-{salt}"
    scratch = tempfile.mkdtemp(prefix="omnipowers_fitness_")
    try:
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
        try:
            for line in proc.stdout:
                if _t.time() > deadline:
                    break
                line = line.strip()
                if not line or clean_name not in line:
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
            return False
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

    def eval_case(c):
        hits = sum(
            1 for _ in range(args.runs)
            if _run_one_trigger(c["query"], desc, args.skill, args.timeout, args.model)
        )
        rate = hits / args.runs
        triggered = rate >= 0.5
        return {"query": c["query"], "should_trigger": c["should_trigger"],
                "trigger_rate": rate, "triggered": triggered,
                "pass": triggered == c["should_trigger"]}

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        rows = list(ex.map(eval_case, cases))

    for r in rows:
        mark = "PASS" if r["pass"] else "FAIL"
        print(f"  [{mark}] rate={r['trigger_rate']:.2f} expected={r['should_trigger']}: {r['query']}")
    tp = sum(1 for r in rows if r["should_trigger"] and r["triggered"])
    fp = sum(1 for r in rows if not r["should_trigger"] and r["triggered"])
    fn = sum(1 for r in rows if r["should_trigger"] and not r["triggered"])
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


def main() -> int:
    p = argparse.ArgumentParser(prog="fitness.py", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("triggers", help="trigger precision/recall for one skill")
    t.add_argument("--skill", required=True)
    t.add_argument("--eval-set", default="")
    t.add_argument("--runs", type=int, default=3)
    t.add_argument("--timeout", type=int, default=60, help="seconds per run")
    t.add_argument("--workers", type=int, default=4)
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
