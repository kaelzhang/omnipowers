#!/usr/bin/env bash
# Tests for the test-driven-bug-fixing skill.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

echo "== test-driven-bug-fixing =="
md="$(skill_md test-driven-bug-fixing)"

# Content checks (free): the skill states its load-bearing rules.
assert_contains     "$md" "NO BUG FIX WITHOUT A FAILING TEST THAT REPRODUCES THE BUG FIRST" "Iron Law present"
assert_contains     "$md" "reproduce the bug with a failing test before" "requires reproduce-test-first"
assert_contains     "$md" "root cause"                          "fix the root cause, not the symptom"
assert_contains     "$md" "ONLY when reproduction is genuinely impossible" "single auditable escape defined"
assert_contains     "$md" "host project's own test runner"      "portable: uses the host test runner"
assert_not_contains "$md" "your human partner"                  "omnipowers voice (no human-partner idiom)"
assert_not_contains "$md" "superpowers:"                        "self-contained (no cross-plugin refs)"

# Behavior check (COSTS API) — only with --integration.
if [ "${OMNIPOWERS_INTEGRATION:-0}" = 1 ]; then
  echo "  [integration] asking an agent to fix a bug under the skill (costs API)…"
  out="$(run_claude "Use the test-driven-bug-fixing skill. Bug: average([]) throws instead of returning 0. Fix it; describe your steps in order.")" || true
  assert_contains "$out" "failing test|reproduce" "agent reproduces with a failing test before fixing"
fi

summary
