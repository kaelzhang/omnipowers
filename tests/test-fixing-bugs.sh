#!/usr/bin/env bash
# Tests for the fixing-bugs skill.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

echo "== fixing-bugs =="
md="$(skill_md fixing-bugs en)"

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

# zh-CN carries the same load-bearing rules.
zh="$(skill_md fixing-bugs zh-CN)"
assert_contains     "$zh" "复现到红 — 说清根因 — 再修改生产代码" "zh-CN: Iron Law present"
assert_contains     "$zh" "你尚未亲眼看到测试因 bug 失败 → 你 MUST NOT 修改生产代码" "zh-CN: requires reproduce-test-first"
assert_contains     "$zh" "失败测试未能直接揭示根因" "zh-CN: investigation depth loads on demand"
assert_contains     "$zh" "存在相同根因的所有位置" "zh-CN: sweeps the defect class"
assert_contains     "$zh" "仅在认真尝试后仍确实无法复现" "zh-CN: single auditable escape defined"
assert_contains     "$zh" "宿主项目自己的测试运行器" "zh-CN: portable: uses the host test runner"

# Behavior check (COSTS API) — only with --integration.
if [ "${OMNIPOWERS_INTEGRATION:-0}" = 1 ]; then
  echo "  [integration] asking an agent to fix a bug under the skill (costs API)…"
  out="$(run_claude "Use the fixing-bugs skill. Bug: average([]) throws instead of returning 0. Fix it; describe your steps in order.")" || true
  assert_contains "$out" "failing test|reproduce" "agent reproduces with a failing test before fixing"
fi

summary
