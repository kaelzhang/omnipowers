#!/usr/bin/env bash
# Tests for the fixing-bugs skill.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

echo "== fixing-bugs =="
md="$(skill_md fixing-bugs)"

# Content checks (free): the skill states its load-bearing rules.
assert_contains     "$md" "REPRODUCE IT RED — NAME THE ROOT CAUSE — ONLY THEN CHANGE PRODUCTION CODE" "Iron Law present"
assert_contains     "$md" "until a test reproduces the bug and you have watched it fail" "requires reproduce-test-first"
assert_contains     "$md" "not evident from the failing test" "investigation depth loads on demand"
assert_contains     "$md" "every other site that shares this root cause" "sweeps the defect class"
assert_contains     "$md" "root cause"                          "fix the root cause, not the symptom"
assert_contains     "$md" "ONLY when reproduction is genuinely impossible" "single auditable escape defined"
assert_contains     "$md" "host project's own test runner"      "portable: uses the host test runner"
assert_not_contains "$md" "your human partner"                  "omnipowers voice (no human-partner idiom)"
assert_not_contains "$md" "superpowers:"                        "self-contained (no cross-plugin refs)"

# Behavior check (COSTS API) — only with --integration.
if [ "${OMNIPOWERS_INTEGRATION:-0}" = 1 ]; then
  echo "  [integration] asking an agent to fix a bug under the skill (costs API)…"
  out="$(run_claude "Use the fixing-bugs skill. Bug: average([]) throws instead of returning 0. Fix it; describe your steps in order.")" || true
  assert_contains "$out" "failing test|reproduce" "agent reproduces with a failing test before fixing"
fi

summary
