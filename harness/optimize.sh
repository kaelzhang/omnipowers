#!/usr/bin/env bash
# optimize.sh — optimize an omnipowers skill with SkillOpt-Sleep.
#
# SkillOpt is an EXTERNAL dependency (not vendored). Point SKILLOPT_HOME at a local
# clone of https://github.com/microsoft/SkillOpt, or pip-install `skillopt` into the
# active env. Set OMNIPOWERS_PY to choose the Python (default: python3).
#
# It feeds a reviewed eval task set (--tasks-file) + the target skill to SkillOpt-Sleep,
# which replays each task under the skill, proposes BOUNDED edits, gates them on a
# held-out split, and STAGES a proposal. It NEVER edits the skill until you `adopt`.
# Generated artifacts live in <repo>/.skillopt-sleep/ (gitignored).
#
# Usage:
#   optimize.sh run    <skill> <tasks-file> [backend] [--dry]   # optimize; --dry = report only, no staging
#   optimize.sh status <skill>                                  # show the latest staged proposal
#   optimize.sh adopt  <skill>                                  # apply the latest staged proposal (with backup)
# backend: mock (default, free) | claude | codex                # claude/codex call real models and COST API budget
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLOPT_HOME="${SKILLOPT_HOME:-$HOME/Sources/harness/SkillOpt}"
PY="${OMNIPOWERS_PY:-python3}"

die(){ echo "optimize.sh: $*" >&2; exit 2; }
usage(){
  sed -n 's/^# \{0,1\}//;13,17p' "$0" >&2
  exit "${1:-0}"
}

cmd="${1:-}"; [ -n "$cmd" ] || usage 1
case "$cmd" in run|status|adopt) ;; *) die "unknown command '$cmd' (run|status|adopt)";; esac

skill="${2:-}"; [ -n "$skill" ] || die "skill name required"
skill_path="$REPO/skills/$skill/SKILL.md"
[ -f "$skill_path" ] || die "no such skill: $skill_path"

skopt(){ PYTHONPATH="$SKILLOPT_HOME${PYTHONPATH:+:$PYTHONPATH}" "$PY" -m skillopt_sleep "$@"; }

PYTHONPATH="$SKILLOPT_HOME${PYTHONPATH:+:$PYTHONPATH}" "$PY" -c 'import skillopt_sleep' 2>/dev/null \
  || die "SkillOpt not importable — set SKILLOPT_HOME to a clone of microsoft/SkillOpt (now: $SKILLOPT_HOME), or pip install skillopt"

case "$cmd" in
  run)
    tasks="${3:-}"
    backend="mock"; dry=0
    # Trailing args after <skill> <tasks-file> are [backend] and/or --dry, in any order.
    [ "$#" -ge 3 ] && shift 3 || shift "$#"
    for a in "$@"; do
      case "$a" in
        --dry) dry=1 ;;
        --*)   die "unknown flag '$a'" ;;
        *)     backend="$a" ;;
      esac
    done
    { [ -n "$tasks" ] && [ -f "$tasks" ]; } || die "tasks-file required and must exist: '${tasks:-}'"
    sub=$([ "$dry" = 1 ] && echo dry-run || echo run)
    skopt "$sub" --target-skill-path "$skill_path" --tasks-file "$tasks" --backend "$backend" --project "$REPO"
    ;;
  status) skopt status --target-skill-path "$skill_path" --project "$REPO" ;;
  adopt)  skopt adopt  --target-skill-path "$skill_path" --project "$REPO" ;;
esac
