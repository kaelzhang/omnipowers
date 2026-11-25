#!/usr/bin/env bash
# Content & contract checks for optimizing-context (en & zh-CN).
set -uo pipefail
source "$(dirname "$0")/test-helpers.sh"

echo "== optimizing-context =="

en_md="$(skill_md optimizing-context en)"
zh_md="$(skill_md optimizing-context zh-CN)"
en_pm="$(cat "$OMNIPOWERS_ROOT/skills/en/optimizing-context/paired-measurement.md")"
zh_pm="$(cat "$OMNIPOWERS_ROOT/skills/zh-CN/optimizing-context/paired-measurement.md")"

# 1. Explicit-invocation-only triggers (including user-specified default phrases)
assert_contains "$en_md" 'Use only when the user explicitly asks' "en description is explicit-invocation-only"
assert_contains "$zh_md" '仅在用户明确要求' "zh-CN description is explicit-invocation-only"
assert_contains "$zh_md" '精简上下文.*精简知识库.*优化输入大小' "zh-CN carries exact default trigger phrases"

# 2. Core invariants tracing to RED failures
assert_contains "$en_md" 'bare `@path` imports' "forbids bare @path import illusion"
assert_contains "$en_md" 're-read an entrypoint the host already injects' "forbids re-reading injected root in briefs"
assert_contains "$en_md" 'byte for byte' "requires byte-for-byte quotation conservation"
assert_contains "$en_md" 'never line count alone' "forbids line-count-only budgets"
assert_contains "$en_md" 'seed a broken link, an over-budget file, and an altered quotation' "requires seeded-defect gate proof"
assert_contains "$en_md" '@paired-measurement\.md' "links @paired-measurement.md conditionally"

assert_contains "$zh_md" '裸 `@path` 导入' "zh-CN forbids bare @path import illusion"
assert_contains "$zh_md" '重新读取宿主在启动时已经自动注入的入口文件' "zh-CN forbids re-reading injected root in briefs"
assert_contains "$zh_md" '逐字节' "zh-CN requires byte-for-byte quotation conservation"
assert_contains "$zh_md" '绝不只校验行数' "zh-CN forbids line-count-only budgets"
assert_contains "$zh_md" '@paired-measurement\.md' "zh-CN links @paired-measurement.md conditionally"

# 3. Supporting file checks
assert_contains "$en_pm" 'git rev-parse "<rev>\^\{tree\}"' "en paired-measurement pins Git tree hashes"
assert_contains "$zh_pm" 'git rev-parse "<rev>\^\{tree\}"' "zh-CN paired-measurement pins Git tree hashes"

summary
