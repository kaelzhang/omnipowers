#!/usr/bin/env bash
# checkpoint.sh — the continuous-work-mode checkpoint.
#
#   checkpoint.sh            report the queue and exit 0 (safe to run any time)
#   checkpoint.sh --gate     Stop-hook gate: exit 2 to block the round from ending
#
# The gate is inert unless continuous work mode is armed, so it is safe to
# install permanently. Arm it by writing the sentinel:
#
#   mkdir -p .omnipowers && cat > .omnipowers/continuous-mode <<EOF
#   base=<sha of the commit the mode started from>
#   defects=<path to a checklist file>     # repeatable, optional
#   repo=<path to another repo to watch>   # repeatable, optional
#   EOF
#
# Disarm by deleting that file.

set -uo pipefail

MODE=report
[ "${1:-}" = "--gate" ] && MODE=gate

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
SENTINEL="$ROOT/.omnipowers/continuous-mode"
MARKER="$ROOT/.omnipowers/continuous-gate.last"
OWNER="$ROOT/.omnipowers/continuous-mode.owner"

if [ "$MODE" = gate ] && [ ! -f "$SENTINEL" ]; then exit 0; fi

# Block at most once per distinct state, so nothing the agent cannot clear can
# deadlock the session.
block_once() {
  [ -f "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "$1" ] && return 1
  mkdir -p "$(dirname "$MARKER")" && printf '%s' "$1" > "$MARKER"
  return 0
}

BASE=""; EXPIRES=24; STARTED=""; GOAL=""; DEFECTS=(); REPOS=("$ROOT")
if [ -f "$SENTINEL" ]; then
  while IFS='=' read -r k v; do
    case "$k" in
      base)    BASE="$v" ;;
      goal)    GOAL="$v" ;;
      started) STARTED="$v" ;;
      expires) EXPIRES="$v" ;;
      defects) DEFECTS+=("$v") ;;
      repo)    REPOS+=("$v") ;;
    esac
  done < "$SENTINEL"
fi

# An armed mode that outlives the session that armed it would block a stranger.
# Ownership is claimed on the gate's first fire, so arming costs no bookkeeping.
if [ "$MODE" = gate ]; then
  hook_session=""
  [ -t 0 ] || hook_session=$(head -c 4096 2>/dev/null \
    | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
  stale=""
  if [ -n "$hook_session" ]; then
    if [ ! -f "$OWNER" ]; then
      mkdir -p "$(dirname "$OWNER")" && printf '%s' "$hook_session" > "$OWNER"
    elif [ "$(cat "$OWNER" 2>/dev/null)" != "$hook_session" ]; then
      stale="it was armed by a different session"
    fi
  fi
  if [ -z "$stale" ] && [ -n "$STARTED" ]; then
    age=$(( ( $(date +%s) - STARTED ) / 3600 ))
    [ "$age" -gt "$EXPIRES" ] && stale="it was armed ${age}h ago, past its ${EXPIRES}h life"
  fi
  if [ -n "$stale" ]; then
    block_once "stale:$stale" || exit 0
    {
      echo "Continuous work mode is armed, but $stale."
      echo "Ask the user whether it still applies. It does not → delete these and the mode is off:"
      echo "  $SENTINEL"
      echo "  $OWNER"
    } >&2
    exit 2
  fi
fi
[ -n "$BASE" ] || BASE=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null)

FINDINGS=()
add() { FINDINGS+=("$1"); }

# 1. Uncommitted work, per top-level module.
for repo in "${REPOS[@]}"; do
  [ -d "$repo/.git" ] || [ -f "$repo/.git" ] || continue
  label=$(basename "$repo")
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null \
          | awk '{ n=$2; sub("/.*","",n); print n }' | sort | uniq -c \
          | awk '{ printf "%s(%s) ", $2, $1 }')
  [ -n "$dirty" ] && add "uncommitted in $label: $dirty"

  # 2. Commits that exist only locally.
  if git -C "$repo" rev-parse '@{u}' >/dev/null 2>&1; then
    n=$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null)
    [ "${n:-0}" -gt 0 ] && add "unpushed in $label: $n commit(s)"
  else
    br=$(git -C "$repo" branch --show-current 2>/dev/null)
    [ -n "$br" ] && add "no upstream in $label: branch '$br' has never been pushed"
  fi

  # 3. Untracked files that committed code already references — the shape that
  #    passes locally and breaks every other checkout.
  #
  #    Two corrections, both made after this fired on correct work. A bare
  #    `git grep` searches the WORKING TREE, so a module another session is
  #    still writing was reported as already committed and broken; asking HEAD
  #    is what makes this a statement about the commit. And the candidate must
  #    be a source file: the defect is a module declared and never tracked, and
  #    matching every stem flagged two thousand capture frames because a log
  #    somewhere contains the word "0001". A gate that argues with correct work
  #    teaches people to skip it.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$f" in .omnipowers/*) continue ;; esac
    case "$f" in
      *.rs|*.swift|*.c|*.h|*.cpp|*.mm|*.py|*.ts|*.tsx|*.js|*.sh|*.proto) ;;
      *) continue ;;
    esac
    stem=$(basename "$f"); stem="${stem%.*}"
    [ ${#stem} -ge 4 ] || continue
    #    And it looks for a DECLARATION, not for the word. HEAD contains
    #    "renderer" in a hundred sentences and declares `mod renderer;` in
    #    none, and only the second one breaks a fresh checkout.
    case "$f" in
      *.rs)  pat="^ *(pub[^ ]* )?mod +${stem} *;" ;;
      *.py)  pat="(^|[^.[:alnum:]_])(import|from) +${stem}([^[:alnum:]_]|$)" ;;
      *.sh)  pat="(source|\\.) +[^ ]*${stem}" ;;
      *)     pat="[\"<][^\"<>]*${stem}\\.[a-z]+[\">]" ;;
    esac
    #    Rust narrows further, to the only two files that CAN declare it.
    #    `mod tests;` appears in hundreds of committed files and refers to a
    #    different tests.rs in every one; scoping to the parent module is what
    #    turns the question from "does this word appear" into "is THIS file
    #    declared". (#[path] can move a module and is not handled: this check
    #    is a cheap warning, and `make check-head` is what actually answers.)
    scope=". :!*.md :!*.txt"
    case "$f" in
      *.rs) d=$(dirname "$f"); scope="${d}.rs ${d}/mod.rs ${d}/lib.rs ${d}/main.rs" ;;
    esac
    # shellcheck disable=SC2086
    if git -C "$repo" grep -l -E -- "$pat" HEAD -- $scope >/dev/null 2>&1; then
      add "untracked but referenced by committed code: $f"
    fi
  done < <(git -C "$repo" ls-files --others --exclude-standard 2>/dev/null | head -40)
done

# 4. Open items on the declared defect checklists.
for d in ${DEFECTS[@]+"${DEFECTS[@]}"}; do
  [ -f "$ROOT/$d" ] || [ -f "$d" ] || continue
  path="$d"; [ -f "$ROOT/$d" ] && path="$ROOT/$d"
  n=$(grep -c '^\s*[-*] \[ \]' "$path" 2>/dev/null || echo 0)
  [ "$n" -gt 0 ] && add "open items in $d: $n"
done

# 5. Capability built with no way in: a symbol this round added, referenced
#    nowhere outside the file that defines it.
if [ -n "$BASE" ]; then
  changed=$(git -C "$ROOT" diff --name-only "$BASE"..HEAD 2>/dev/null; git -C "$ROOT" diff --name-only 2>/dev/null)
  while IFS= read -r f; do
    [ -n "$f" ] && [ -f "$ROOT/$f" ] || continue
    case "$f" in *test*|*spec*|*.md|*.json|*.lock) continue ;; esac
    while IFS= read -r sym; do
      [ ${#sym} -ge 4 ] || continue
      hits=$(git -C "$ROOT" grep -l -w -- "$sym" 2>/dev/null | grep -v -F -- "$f" | grep -vi -e test -e spec | head -1)
      [ -z "$hits" ] && add "defined but never referenced outside $f: $sym"
    done < <(grep -hoE '^[[:space:]]*(export[[:space:]]+(default[[:space:]]+)?)?(async[[:space:]]+)?(pub[[:space:]]+)?(function|const|class|def|fn|func|type|interface)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$ROOT/$f" 2>/dev/null \
            | awk '{ print $NF }' | sort -u | head -12)
  done < <(printf '%s\n' "$changed" | sort -u | head -25)
fi

if [ "${#FINDINGS[@]}" -eq 0 ]; then
  if [ "$MODE" = report ]; then
    echo "checkpoint: queue empty — nothing uncommitted, unpushed, unreferenced, or open."
    [ -f "$SENTINEL" ] && echo "The mode has nothing left to enforce. Disarm it: rm $SENTINEL $OWNER $MARKER"
  fi
  exit 0
fi

report() {
  [ -n "$GOAL" ] && echo "Mode goal: $GOAL"
  echo "Continuous work mode — the queue is not empty:"
  printf '  - %s\n' "${FINDINGS[@]}"
  echo ""
  echo "Clear what is clearable now, dispatch what can run, and end the round only"
  echo "on what genuinely needs the user. Report last, not first."
  echo "None of this is the goal above? Name it as follow-up and disarm — findings"
  echo "do not extend the mode."
}

if [ "$MODE" = report ]; then report; exit 0; fi

block_once "$(printf '%s\n' "${FINDINGS[@]}" | shasum | awk '{print $1}')" || exit 0
report >&2
exit 2
