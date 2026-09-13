#!/usr/bin/env bash
# block-attribution.sh — a pre-command hook for the host's shell tool.
#
# Refuses a commit or pull-request command whose message credits a tool, a
# model, or a vendor: an attribution trailer (Co-Authored-By naming a tool,
# Generated-by, Reviewed-by), the words Claude / Anthropic / Codex / OpenAI, a
# GPT model name, the robot emoji, or "Generated with". The message is read
# from the commit segment itself, its heredoc body, and any -F / --file /
# --body-file it names — never from other commands sharing the same call.
#
# It acts only when a command segment actually IS `git commit` or
# `gh pr create|edit`; a script or document that merely mentions those words
# passes. Anything it cannot parse passes untouched (fails open).
#
# Contract (Claude Code PreToolUse): the hook payload arrives on stdin as JSON
# with tool_input.command; printing {"decision":"block","reason":...} refuses
# the call and shows the reason to the agent; printing {} allows it.

set -uo pipefail
payload="$(cat)"
command -v python3 >/dev/null 2>&1 || { echo '{}'; exit 0; }

HOOK_PAYLOAD="$payload" python3 - <<'PY'
import json, os, re, shlex, sys

def allow():
    print("{}"); sys.exit(0)

try:
    data = json.loads(os.environ.get("HOOK_PAYLOAD", ""))
    cmd = (data.get("tool_input") or {}).get("command", "") or ""
except Exception:
    allow()

PREFIXES = {"sudo", "env", "command", "exec", "nice", "time"}
GIT_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace"}
SEG_SPLIT = re.compile(r"\s*(?:&&|\|\||;|\|)\s*")
HEREDOC = re.compile(r"<<-?\s*(['\"]?)(\w+)\1")

def tokens(text):
    try:
        return shlex.split(text, posix=True)
    except ValueError:
        return text.split()

def is_commit_segment(seg):
    toks = tokens(seg.lstrip("({ \t"))
    while toks and (re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", toks[0]) or toks[0] in PREFIXES):
        toks.pop(0)
    if not toks:
        return False
    if toks[0] == "gh":
        return len(toks) >= 3 and toks[1] == "pr" and toks[2] in ("create", "edit")
    if toks[0] != "git":
        return False
    i = 1
    while i < len(toks) and toks[i].startswith("-"):
        i += 2 if toks[i] in GIT_OPTS_WITH_VALUE else 1
    return i < len(toks) and toks[i] == "commit"

# Collect only the text that belongs to a commit: the segment, its heredoc
# body, and any message file it names.
lines = cmd.split("\n")
texts = []
i = 0
while i < len(lines):
    line = lines[i]
    for seg in SEG_SPLIT.split(line):
        if not seg.strip() or not is_commit_segment(seg):
            continue
        texts.append(seg)
        m = HEREDOC.search(seg)
        if m:
            term = m.group(2)
            j = i + 1
            while j < len(lines) and lines[j].strip() != term:
                texts.append(lines[j]); j += 1
            i = j
        toks = tokens(seg)
        for k, t in enumerate(toks):
            path = None
            if t in ("-F", "--file", "--body-file") and k + 1 < len(toks):
                path = toks[k + 1]
            elif t.startswith(("--file=", "--body-file=")):
                path = t.split("=", 1)[1]
            if path and path != "-" and os.path.isfile(path):
                try:
                    with open(path, encoding="utf-8", errors="replace") as f:
                        texts.append(f.read())
                except OSError:
                    pass
    i += 1

if not texts:
    allow()

forbidden = re.compile(
    r"(Co-?authored-?by|Generated-?by|Reviewed-?by)\s*:"
    r"|\bClaude\b|\bAnthropic\b|\bCodex\b|\bOpenAI\b|\bGPT-?\d"
    r"|Generated with|noreply@anthropic\.com|\U0001F916",
    re.IGNORECASE,
)
m = forbidden.search("\n".join(texts))
if not m:
    allow()

reason = (
    "Commit and PR messages must not credit a tool, model, or vendor "
    f"(found: {m.group(0)!r}). No Co-Authored-By or Generated-by trailer, no "
    "Claude/Anthropic/Codex/OpenAI, no robot emoji. Rewrite the message and retry."
)
print(json.dumps({"decision": "block", "reason": reason}))
PY
