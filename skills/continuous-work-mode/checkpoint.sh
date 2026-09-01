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

if [ "$MODE" = gate ] && [ ! -f "$SENTINEL" ]; then exit 0; fi

BASE=""; DEFECTS=(); REPOS=("$ROOT")
if [ -f "$SENTINEL" ]; then
  while IFS='=' read -r k v; do
    case "$k" in
      base)    BASE="$v" ;;
      defects) DEFECTS+=("$v") ;;
      repo)    REPOS+=("$v") ;;
    esac
  done < "$SENTINEL"
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
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$f" in .omnipowers/*) continue ;; esac
    stem=$(basename "$f"); stem="${stem%.*}"
    [ ${#stem} -ge 4 ] || continue
    if git -C "$repo" grep -l -w -F -- "$stem" -- . ':!*.md' ':!*.txt' >/dev/null 2>&1; then
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
  [ "$MODE" = report ] && echo "checkpoint: queue empty — nothing uncommitted, unpushed, unreferenced, or open."
  exit 0
fi

report() {
  echo "Continuous work mode — the queue is not empty:"
  printf '  - %s\n' "${FINDINGS[@]}"
  echo ""
  echo "Clear what is clearable now, dispatch what can run, and end the round only"
  echo "on what genuinely needs the user. Report last, not first."
}

if [ "$MODE" = report ]; then report; exit 0; fi

# Gate: block once per distinct state, never twice for the same one, so an
# unfixable finding can never deadlock the session.
sig=$(printf '%s\n' "${FINDINGS[@]}" | shasum | awk '{print $1}')
if [ -f "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "$sig" ]; then exit 0; fi
mkdir -p "$(dirname "$MARKER")" && printf '%s' "$sig" > "$MARKER"
report >&2
exit 2
