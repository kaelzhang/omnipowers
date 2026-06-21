#!/usr/bin/env bash
# Run omnipowers skill tests. Content checks are free; --integration also runs
# tests that invoke a real agent (COSTS API).
#   run-skill-tests.sh [--integration] [--test test-<name>.sh]
set -uo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
export OMNIPOWERS_ROOT; OMNIPOWERS_ROOT="$(cd "$DIR/.." && pwd)"
export OMNIPOWERS_INTEGRATION=0
only=""

while [ $# -gt 0 ]; do
  case "$1" in
    --integration) OMNIPOWERS_INTEGRATION=1 ;;
    --test) only="${2:-}"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

fail=0; ran=0
for t in "$DIR"/test-*.sh; do
  [ -e "$t" ] || continue
  [ -n "$only" ] && [ "$(basename "$t")" != "$only" ] && continue
  ran=$((ran + 1))
  bash "$t" || fail=1
  echo
done

[ "$ran" -gt 0 ] || { echo "no tests matched"; exit 2; }
if [ "$fail" = 0 ]; then echo "ALL SKILL TESTS PASSED"; else echo "SOME SKILL TESTS FAILED"; exit 1; fi
