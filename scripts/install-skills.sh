#!/usr/bin/env bash
# install-skills.sh — install omnipowers skills into Claude Code and Codex.
#
# Skills are SYMLINKED (not copied) so edits in this repo auto-apply:
#   - Claude Code hot-reloads SKILL.md edits live in the current session.
#   - Codex auto-detects skill changes (restart Codex if an update does not show).
#
# Discovery dirs (official):
#   Claude Code : ~/.claude/skills/<name>   https://code.claude.com/docs/en/skills
#   Codex       : ~/.agents/skills/<name>   https://developers.openai.com/codex/skills
#
# Usage:
#   install-skills.sh status      # analyze install state, link nothing
#   install-skills.sh install     # symlink skills (idempotent; FORCE=1 to relink)
#   install-skills.sh uninstall   # remove omnipowers symlinks
#
# Env:
#   FORCE=1   re-link even if already installed, and replace a foreign symlink.
#             Never deletes a real file/directory.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
FORCE="${FORCE:-0}"

CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="$HOME/.agents/skills"

if [ -t 1 ]; then
  B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; C=$'\033[36m'; N=$'\033[0m'
else
  B=''; G=''; Y=''; R=''; C=''; N=''
fi

info() { printf '%s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$N" "$*"; }
err()  { printf '  %s✗%s %s\n' "$R" "$N" "$*"; }

# Print the directory name of every skill (a dir under skills/ holding SKILL.md).
skill_names() {
  local d
  for d in "$SKILLS_DIR"/*/; do
    [ -f "${d}SKILL.md" ] || continue
    basename "$d"
  done
}

cli_path() { command -v "$1" 2>/dev/null || true; }

status_target() { # label dir
  local label="$1" dir="$2" name link
  info "  ${C}$label${N}  →  $dir"
  [ -d "$dir" ] || warn "    directory does not exist yet (created on install)"
  while IFS= read -r name; do
    link="$dir/$name"
    if [ -L "$link" ]; then
      if [ "$(readlink "$link")" = "$SKILLS_DIR/$name" ]; then
        ok "    $name (linked)"
      else
        warn "    $name (foreign symlink → $(readlink "$link"))"
      fi
    elif [ -e "$link" ]; then
      err "    $name (real file/dir present — not managed by omnipowers)"
    else
      info "    $name (not installed)"
    fi
  done < <(skill_names)
}

print_status() {
  info "${B}omnipowers — environment status${N}"
  info "  repo: $REPO"
  info ""
  info "${B}CLIs on PATH${N}"
  local claude codex
  claude="$(cli_path claude)"; codex="$(cli_path codex)"
  if [ -n "$claude" ]; then ok "Claude Code: $claude"; else warn "Claude Code: not found"; fi
  if [ -n "$codex" ];  then ok "Codex: $codex";        else warn "Codex: not found"; fi
  info ""
  info "${B}Skills in this repo${N}"
  local n=0 name
  while IFS= read -r name; do n=$((n + 1)); info "  - $name"; done < <(skill_names)
  [ "$n" -gt 0 ] || warn "no skills found under $SKILLS_DIR"
  info ""
  info "${B}Install state${N}"
  status_target "Claude Code" "$CLAUDE_DIR"
  status_target "Codex" "$CODEX_DIR"
}

link_one() { # name dir label
  local name="$1" dir="$2" label="$3"
  local src="$SKILLS_DIR/$name" link="$dir/$name"
  mkdir -p "$dir"
  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" = "$src" ]; then
      if [ "$FORCE" = "1" ]; then rm -f "$link"; ln -s "$src" "$link"; ok "$label: $name (re-linked)"
      else ok "$label: $name (already installed)"; fi
    elif [ "$FORCE" = "1" ]; then
      rm -f "$link"; ln -s "$src" "$link"; warn "$label: $name (replaced foreign symlink)"
    else
      warn "$label: $name (foreign symlink exists; FORCE=1 to replace)"
    fi
    return
  fi
  if [ -e "$link" ]; then
    err "$label: $name (real file/dir at $link — refusing to delete; remove it manually)"
    return
  fi
  ln -s "$src" "$link"; ok "$label: $name (installed)"
}

do_install() {
  info "${B}Installing omnipowers skills${N} (FORCE=$FORCE)"
  local any=0 name
  while IFS= read -r name; do
    any=1
    link_one "$name" "$CLAUDE_DIR" "Claude"
    link_one "$name" "$CODEX_DIR"  "Codex "
  done < <(skill_names)
  if [ "$any" != 1 ]; then err "no skills found under $SKILLS_DIR"; exit 1; fi
  info ""
  info "Edits to a skill's SKILL.md auto-apply through the symlink:"
  info "  - Claude Code hot-reloads live (restart once only if ~/.claude/skills"
  info "    did not exist when Claude started)."
  info "  - Codex auto-detects changes (restart Codex if one does not show)."
}

do_uninstall() {
  info "${B}Uninstalling omnipowers skills${N}"
  local dir name link
  for dir in "$CLAUDE_DIR" "$CODEX_DIR"; do
    while IFS= read -r name; do
      link="$dir/$name"
      if [ -L "$link" ] && [ "$(readlink "$link")" = "$SKILLS_DIR/$name" ]; then
        rm -f "$link"; ok "removed $link"
      elif [ -e "$link" ] || [ -L "$link" ]; then
        warn "skip $link (not an omnipowers symlink)"
      fi
    done < <(skill_names)
  done
}

case "${1:-status}" in
  status)    print_status ;;
  install)   do_install ;;
  uninstall) do_uninstall ;;
  *) err "unknown command: ${1:-}"; info "use: status | install | uninstall"; exit 2 ;;
esac
