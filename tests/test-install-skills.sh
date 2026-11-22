#!/usr/bin/env bash
# Installer tests — run in an isolated temp HOME; free, touches nothing real.
set -uo pipefail
source "$(dirname "$0")/test-helpers.sh"

echo "== install-skills =="
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT
mkdir -p "$TMP_HOME/.gemini/antigravity"

run_inst() {
  HOME="$TMP_HOME" OMNIPOWERS_TARGETS="${1:-claude codex antigravity}" OMNIPOWERS_LOCALE="${2:-en}" \
    bash "$OMNIPOWERS_ROOT/scripts/install-skills.sh" "${@:3}"
}

out="$(PATH="/usr/bin:/bin" run_inst "antigravity" "zh-CN" dev)"
assert_contains "$out" "Antigravity:.*\\.gemini/antigravity" "detects Antigravity desktop app dir"
assert_contains "$out" "Antigravity: brainstorming \\(installed\\)" "installs skills for antigravity target"

if [ -L "$TMP_HOME/.gemini/config/skills/brainstorming" ] && \
   [ "$(readlink "$TMP_HOME/.gemini/config/skills/brainstorming")" = "$OMNIPOWERS_ROOT/skills/zh-CN/brainstorming" ]; then
  ok "symlinks point to skills/zh-CN/<name> under ~/.gemini/config/skills"
else
  bad "symlink target mismatch under ~/.gemini/config/skills"
fi

if [ ! -e "$TMP_HOME/.claude/skills" ] && [ ! -e "$TMP_HOME/.agents/skills" ]; then
  ok "only requested target directory is touched"
else
  bad "untouched targets were unexpectedly created"
fi

out_sw="$(run_inst "antigravity" "en" dev)"
assert_contains "$out_sw" "switched zh-CN → en" "switches locale cleanly on re-install"

out_st="$(run_inst "antigravity" "en" status)"
assert_contains "$out_st" "brainstorming \\(linked locale: en\\)" "status reports linked locale for Antigravity"

out_un="$(HOME="$TMP_HOME" bash "$OMNIPOWERS_ROOT/scripts/install-skills.sh" uninstall antigravity)"
assert_contains "$out_un" "removed .*/\\.gemini/config/skills/brainstorming" "uninstall removes Antigravity symlinks"
if [ ! -L "$TMP_HOME/.gemini/config/skills/brainstorming" ]; then
  ok "Antigravity symlink removed after uninstall"
else
  bad "Antigravity symlink still present after uninstall"
fi

# Test Makefile parameterized dev/uninstall via TARGETS / TARGET (codex and agy alias)
HOME="$TMP_HOME" make -C "$OMNIPOWERS_ROOT" --no-print-directory dev TARGETS="codex,agy" LOCALE=zh-CN >/dev/null
if [ -L "$TMP_HOME/.agents/skills/brainstorming" ] && [ -L "$TMP_HOME/.gemini/config/skills/brainstorming" ]; then
  ok "make dev TARGETS=codex,agy symlinks skills"
else
  bad "make dev TARGETS=codex,agy failed to symlink"
fi

HOME="$TMP_HOME" make -C "$OMNIPOWERS_ROOT" --no-print-directory uninstall TARGETS="codex agy" >/dev/null
if [ ! -e "$TMP_HOME/.agents/skills/brainstorming" ] && [ ! -e "$TMP_HOME/.gemini/config/skills/brainstorming" ]; then
  ok "make uninstall TARGETS='codex agy' removes symlinks"
else
  bad "make uninstall TARGETS='codex agy' left symlinks behind"
fi

summary
