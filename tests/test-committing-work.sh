#!/usr/bin/env bash
# Tests for the committing-work skill: the attribution gate must refuse what it
# exists to refuse and pass everything else. Command strings are assembled from
# parts so this file never trips the gate while being written or read.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

echo "== committing-work =="
md="$(skill_md committing-work)"
assert_contains "$md" "Tool attribution is prohibited" "attribution rule present"
assert_contains "$md" "enforced by a hook" "rule points at the gate"

HOOK="$OMNIPOWERS_ROOT/skills/committing-work/block-attribution.sh"
G="git commit"; CA="Co-Authored-By"
tmp="$(mktemp)"; printf 'fix: x\n\n%s: Claude <noreply@anthropic.com>\n' "$CA" > "$tmp"
gate() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$1")" | bash "$HOOK"; }
blocks() { gate "$1" | grep -q '"block"' && ok "blocks: $2" || bad "blocks: $2"; }
passes() { gate "$1" | grep -q '"block"' && bad "passes: $2" || ok "passes: $2"; }

blocks "$G -m fix -m '$CA: Claude <noreply@anthropic.com>'"      "trailer in -m"
blocks "$G -m 'fix: x' -m 'Generated with Claude Code'"           "model name in body"
blocks "$G -m 'fix 🤖'"                                            "robot emoji"
blocks "$G -F $tmp"                                                "trailer in -F file"
blocks "$G --file=$tmp"                                            "trailer in --file="
blocks "gh pr create --title t --body 'Generated with Claude Code'" "pr body"
blocks "cd /tmp && $G -m x -m 'by Claude'"                         "after &&"
blocks "git -C /tmp commit -m '🤖 fix'"                                 "git -C path"
blocks "GIT_EDITOR=true $G -m '$CA: Claude <x@y>'"               "env prefix"
passes "$G -m 'fix: handle empty list'"                             "ordinary commit"
passes "$G --amend --no-edit"                                       "amend without message"
passes "echo Claude > notes.txt"                                     "non-commit mentioning a model"
passes "printf '# act on $G\nClaude' > x.sh"                        "script text mentioning the command"
passes "grep -n '$G' README.md && echo Claude"                      "grep for the command"
passes "echo '$CA: Claude' >> notes.md"                             "trailer text outside a commit"
passes "$G -m 'fix: x' && grep -c hook ~/.claude/settings.json"       "clean commit beside a segment naming a model path"
blocks "$G -F - <<'MSG'
fix: x

$CA: Claude <noreply@anthropic.com>
MSG"                                                                   "trailer in heredoc body"
passes "$G -F - <<'MSG'
fix: x
MSG
echo Claude"                                                            "clean heredoc, model named after it"
rm -f "$tmp"

summary
