#!/usr/bin/env bash
# Continuous-work-mode gate & installation contract tests (free, isolated temp repo).
set -uo pipefail
source "$(dirname "$0")/test-helpers.sh"

echo "== continuous-work-mode =="

CKPT="$OMNIPOWERS_ROOT/skills/en/continuous-work-mode/checkpoint.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REMOTE="$TMP_DIR/remote.git"
REPO="$TMP_DIR/repo"
git init -q --bare "$REMOTE"
git clone -q "$REMOTE" "$REPO"
git -C "$REPO" config user.email t@example.com
git -C "$REPO" config user.name t
printf '.omnipowers/\n' > "$REPO/.gitignore"
git -C "$REPO" add .gitignore && git -C "$REPO" commit -qm init
git -C "$REPO" push -q -u origin HEAD

mkdir -p "$REPO/.agents/hooks" "$REPO/.omnipowers"
cp "$CKPT" "$REPO/.agents/hooks/checkpoint.sh"
printf '{"continuous-work-mode":{"Stop":[{"type":"command","command":"bash %s/.agents/hooks/checkpoint.sh --gate"}]}}\n' "$REPO" > "$REPO/.agents/hooks.json"

# 1. Inert when disarmed (Antigravity protocol returns decision=stop)
out_inert="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"NO_TOOL_CALL","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_inert" = '{"decision":"stop"}' ] && ok "disarmed Antigravity gate outputs decision=stop" || bad "disarmed Antigravity gate got: $out_inert"

# 2. Arm sentinel with one open item; run from .agents/ cwd as Antigravity does
printf 'goal=fix login timeout\n- [ ] fix login timeout\n' > "$REPO/.omnipowers/continuous-mode"

out_block="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"NO_TOOL_CALL","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
rc_block=$?
[ "$rc_block" = 0 ] && ok "Antigravity gate exits 0 on block" || bad "Antigravity gate exited $rc_block"
assert_contains "$out_block" '"decision":[[:space:]]*"continue"' "Antigravity gate returns decision=continue JSON"
assert_contains "$out_block" 'unmet: fix login timeout' "Antigravity gate includes unmet item in reason"
[ "$(cat "$REPO/.omnipowers/continuous-mode.owner" 2>/dev/null)" = "conv-a" ] \
  && ok "claims conversationId ownership" || bad "failed to record conversationId owner"

# 3.Gate's own .agents/hooks.json & checkpoint.sh are not flagged as uncommitted work
assert_not_contains "$out_block" 'uncommitted in repo: \.agents' "gate files do not trigger uncommitted finding"

# 4. block_once prevents infinite loop on identical finding state
out_repeat="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"NO_TOOL_CALL","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_repeat" = '{"decision":"stop"}' ] && ok "block_once releases second identical stop" || bad "block_once did not release: $out_repeat"
rm -f "$REPO/.omnipowers/continuous-gate.last"

# 5. Another conversationId is ignored
out_other="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-b","terminationReason":"NO_TOOL_CALL","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_other" = '{"decision":"stop"}' ] && ok "foreign conversationId is allowed to stop" || bad "foreign conversationId blocked: $out_other"

# 6. Background tasks still running (fullyIdle: false) or USER_CANCELED are allowed through
out_busy="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"NO_TOOL_CALL","fullyIdle":false}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_busy" = '{"decision":"stop"}' ] && ok "fullyIdle=false lets agent await tracked background work" || bad "fullyIdle=false blocked: $out_busy"

out_cancel="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"USER_CANCELED","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_cancel" = '{"decision":"stop"}' ] && ok "USER_CANCELED is never overridden" || bad "USER_CANCELED blocked: $out_cancel"

# 6b. The documented normal finish (model_stop) is gated; error / max_steps stop
rm -f "$REPO/.omnipowers/continuous-gate.last"
out_model="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"model_stop","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
assert_contains "$out_model" '"decision":[[:space:]]*"continue"' "terminationReason=model_stop is gated"
out_err="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"error","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_err" = '{"decision":"stop"}' ] && ok "terminationReason=error stops" || bad "error blocked: $out_err"
out_max="$(cd "$REPO/.agents" && printf '{"conversationId":"conv-a","terminationReason":"max_steps_exceeded","fullyIdle":true}' | bash ./hooks/checkpoint.sh --gate)"
[ "$out_max" = '{"decision":"stop"}' ] && ok "terminationReason=max_steps_exceeded stops" || bad "max_steps blocked: $out_max"

# 6c. Run from a directory outside the repo: the script finds the project by its own location
rm -f "$REPO/.omnipowers/continuous-gate.last"
out_far="$(cd "$TMP_DIR" && printf '{"conversationId":"conv-a","terminationReason":"model_stop","fullyIdle":true}' | bash "$REPO/.agents/hooks/checkpoint.sh" --gate)"
assert_contains "$out_far" 'unmet: fix login timeout' "gate resolves the project from its own path when cwd is outside it"

# 7. Claude Code protocol still works (session_id -> exit 2 + stderr)
rm -f "$REPO/.omnipowers/continuous-mode.owner" "$REPO/.omnipowers/continuous-gate.last"
claude_err="$(cd "$REPO" && printf '{"session_id":"sess-1"}' | bash "$CKPT" --gate 2>&1 >/dev/null)"
rc_claude=$?
[ "$rc_claude" = 2 ] && ok "Claude Code gate still exits 2" || bad "Claude Code gate exited $rc_claude"
assert_contains "$claude_err" 'unmet: fix login timeout' "Claude Code gate still writes findings to stderr"

# 8. Content checks on installing-the-gate.md (en & zh-CN)
en_gate="$(cat "$OMNIPOWERS_ROOT/skills/en/continuous-work-mode/installing-the-gate.md")"
zh_gate="$(cat "$OMNIPOWERS_ROOT/skills/zh-CN/continuous-work-mode/installing-the-gate.md")"
assert_contains "$en_gate" '\.agents/hooks\.json' "en installing-the-gate documents .agents/hooks.json"
assert_contains "$zh_gate" '\.agents/hooks\.json' "zh-CN installing-the-gate documents .agents/hooks.json"

summary
