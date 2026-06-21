#!/usr/bin/env bash
# Shared helpers for omnipowers skill tests.
#
# Content assertions (assert_contains / assert_not_contains / assert_count) read a
# skill's SKILL.md and cost nothing. `run_claude` invokes a real agent headless and
# COSTS API budget — use it only in tests gated behind --integration.
set -uo pipefail

OMNIPOWERS_ROOT="${OMNIPOWERS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PASS=0; FAIL=0

_g(){ [ -t 1 ] && printf '\033[32m%s\033[0m' "$1" || printf '%s' "$1"; }
_r(){ [ -t 1 ] && printf '\033[31m%s\033[0m' "$1" || printf '%s' "$1"; }
ok(){  PASS=$((PASS+1)); printf '  %s %s\n' "$(_g ✓)" "$1"; }
bad(){ FAIL=$((FAIL+1)); printf '  %s %s\n' "$(_r ✗)" "$1"; }

skill_md(){ cat "$OMNIPOWERS_ROOT/skills/$1/SKILL.md"; }

assert_contains(){     # <text> <regex> <name>
  if printf '%s' "$1" | grep -qiE -- "$2"; then ok "$3"; else bad "$3 — missing /$2/"; fi; }
assert_not_contains(){ # <text> <regex> <name>
  if printf '%s' "$1" | grep -qiE -- "$2"; then bad "$3 — present /$2/"; else ok "$3"; fi; }
assert_count(){        # <text> <regex> <n> <name>
  local c; c=$(printf '%s' "$1" | grep -oiE -- "$2" | wc -l | tr -d ' ')
  [ "$c" = "$3" ] && ok "$4 ($c)" || bad "$4 — want $3 got $c"; }

# run_claude <prompt> [extra args] — headless agent run; COSTS API. Returns its output.
run_claude(){
  command -v claude >/dev/null 2>&1 || { echo "[skip] claude not on PATH" >&2; return 127; }
  local p="$1"; shift || true
  claude -p "$p" "$@" 2>/dev/null
}

# Call once at the end of a test file; exit code reflects pass/fail.
summary(){ echo "  → passed=$PASS failed=$FAIL"; [ "$FAIL" = 0 ]; }
