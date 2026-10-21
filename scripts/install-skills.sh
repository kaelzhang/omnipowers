#!/usr/bin/env bash
# install-skills.sh — install omnipowers skills into Claude Code and Codex.
#
# Skills from skills/<locale>/<name> are SYMLINKED as <name>, so edits auto-apply:
#   - Claude Code hot-reloads SKILL.md edits live in the current session.
#   - Codex auto-detects skill changes (restart Codex if an update does not show).
#
# Discovery dirs (official):
#   Claude Code : ~/.claude/skills/<name>   https://code.claude.com/docs/en/skills
#   Codex       : ~/.agents/skills/<name>   https://developers.openai.com/codex/skills
#
# Usage:
#   install-skills.sh status [--locale en|zh-CN] [--targets "claude codex"]
#   install-skills.sh dev         # analyze, then symlink skills (idempotent; FORCE=1 to relink)
#   install-skills.sh uninstall   # remove omnipowers symlinks
#
# Configuration: CLI > OMNIPOWERS_TARGETS / OMNIPOWERS_LOCALE > .install.conf
# > defaults (targets=claude codex, locale=en). Never uses LANG.
# .install.conf contains key=value lines: targets=claude codex and locale=en.
# Env:
#   FORCE=1   re-link even if already installed, and replace a foreign symlink.
#             Never deletes a real file/directory.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_ROOT="$REPO/skills"
FORCE="${FORCE:-0}"

CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="$HOME/.agents/skills"

# Read data only; never execute checkout configuration as shell code.
CONF_TARGETS="claude codex"
CONF_LOCALE="en"
if [ -f "$REPO/.install.conf" ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    case "$key" in
      targets) CONF_TARGETS="$value" ;;
      locale) CONF_LOCALE="$value" ;;
    esac
  done < "$REPO/.install.conf"
fi
TARGETS="${OMNIPOWERS_TARGETS:-$CONF_TARGETS}"
LOCALE="${OMNIPOWERS_LOCALE:-$CONF_LOCALE}"
COMMAND="${1:-status}"
[ "$#" -eq 0 ] || shift
CLI_TARGETS=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --locale|--targets)
      [ "$#" -ge 2 ] && [ -n "$2" ] || { printf 'missing value for %s\n' "$1" >&2; exit 2; }
      case "$1" in --locale) LOCALE="$2" ;; --targets) CLI_TARGETS="$2" ;; esac
      shift 2 ;;
    claude|codex) CLI_TARGETS="${CLI_TARGETS:+$CLI_TARGETS }$1"; shift ;;
    *) printf 'unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done
[ -z "$CLI_TARGETS" ] || TARGETS="$CLI_TARGETS"
available_locales() {
  local d
  for d in "$SKILLS_ROOT"/*/; do
    [ -d "$d" ] || continue
    basename "$d"
  done
}
AVAILABLE_LOCALES="$(available_locales | paste -sd ' ' -)"
if [[ "$LOCALE" == */* ]] || [ ! -d "$SKILLS_ROOT/$LOCALE" ]; then
  printf 'unknown locale: %s (available locales: %s)\n' "$LOCALE" "$AVAILABLE_LOCALES" >&2
  exit 2
fi
SKILLS_DIR="$SKILLS_ROOT/$LOCALE"

target_dir()   { case "$1" in claude) printf '%s' "$CLAUDE_DIR" ;; codex) printf '%s' "$CODEX_DIR" ;; esac; }
target_label() { case "$1" in claude) printf 'Claude' ;; codex) printf 'Codex ' ;; esac; }

for _t in $TARGETS; do
  case "$_t" in claude|codex) ;; *) printf 'unknown target: %s (use claude and/or codex)\n' "$_t" >&2; exit 2 ;; esac
done

if [ -t 1 ]; then
  B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; C=$'\033[36m'; N=$'\033[0m'
else
  B=''; G=''; Y=''; R=''; C=''; N=''
fi

info() { printf '%s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$N" "$*"; }
err()  { printf '  %s✗%s %s\n' "$R" "$N" "$*"; }

# Print skill names in the selected locale.
skill_names() {
  local d
  for d in "$SKILLS_DIR"/*/; do
    [ -f "${d}SKILL.md" ] || continue
    basename "$d"
  done
}

cli_path() { command -v "$1" 2>/dev/null || true; }

# Resolve relative symlink targets lexically, including dangling links.
link_target() {
  local link="$1" target
  target="$(readlink "$link")"
  case "$target" in
    /*) printf '%s\n' "$target" ;;
    *) python3 -c 'import os, sys; print(os.path.abspath(os.path.join(os.path.dirname(sys.argv[1]), sys.argv[2])))' "$link" "$target" ;;
  esac
}

# Only locale-scoped links into this checkout belong to us.
ours() { case "$1" in "$SKILLS_ROOT"/*/*) return 0 ;; *) return 1 ;; esac; }
linked_locale() { local rest="${1#"$SKILLS_ROOT"/}"; printf '%s' "${rest%%/*}"; }

retired_links() { # dir
  local dir="$1" link name target
  [ -d "$dir" ] || return 0
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    name="$(basename "$link")"
    target="$(link_target "$link")"
    ours "$target" || continue
    [ -f "$target/SKILL.md" ] && [ -f "$SKILLS_DIR/$name/SKILL.md" ] && continue
    printf '%s\n' "$name"
  done
}

prune_retired() { # dir label
  local dir="$1" label="$2" name
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    rm -f "$dir/$name"
    warn "$label: $name (removed — retired from this repo)"
  done < <(retired_links "$dir")
}

status_target() { # label dir
  local label="$1" dir="$2" name link target old
  info "  ${C}$label${N}  →  $dir"
  [ -d "$dir" ] || warn "    directory does not exist yet (created on install)"
  while IFS= read -r name; do
    link="$dir/$name"
    if [ -L "$link" ]; then
      target="$(link_target "$link")"
      if [ "$target" = "$SKILLS_DIR/$name" ]; then
        ok "    $name (linked locale: $LOCALE)"
      elif ours "$target"; then
        old="$(linked_locale "$target")"
        warn "    $name (linked locale: $old; mismatch, selected $LOCALE — run make dev to switch)"
      else
        warn "    $name (foreign symlink → $(readlink "$link"))"
      fi
    elif [ -e "$link" ]; then
      err "    $name (real file/dir present — not managed by omnipowers)"
    else
      info "    $name (not installed)"
    fi
  done < <(skill_names)
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    err "    $name (RETIRED from this repo but still installed — run 'make dev' to prune)"
  done < <(retired_links "$dir")
}

print_status() {
  info "${B}omnipowers — environment status${N}"
  info "  repo: $REPO"
  info "  selected locale: $LOCALE"
  info "  available locales: $AVAILABLE_LOCALES"
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
  info "  targets: $TARGETS"
  status_target "Claude Code" "$CLAUDE_DIR"
  status_target "Codex" "$CODEX_DIR"
}

link_one() { # name dir label
  local name="$1" dir="$2" label="$3"
  local src="$SKILLS_DIR/$name" link="$dir/$name" target old
  mkdir -p "$dir"
  if [ -L "$link" ]; then
    target="$(link_target "$link")"
    if [ "$target" = "$src" ]; then
      if [ "$FORCE" = "1" ]; then rm -f "$link"; ln -s "$src" "$link"; ok "$label: $name (re-linked)"
      else ok "$label: $name (already installed)"; fi
    elif ours "$target"; then
      old="$(linked_locale "$target")"
      rm -f "$link"; ln -s "$src" "$link"; ok "$label: $name (switched $old → $LOCALE)"
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
  info "${B}Installing omnipowers skills${N} (FORCE=$FORCE, targets: $TARGETS)"
  local t
  for t in $TARGETS; do prune_retired "$(target_dir "$t")" "$(target_label "$t")"; done
  local any=0 name
  while IFS= read -r name; do
    any=1
    for t in $TARGETS; do link_one "$name" "$(target_dir "$t")" "$(target_label "$t")"; done
  done < <(skill_names)
  if [ "$any" != 1 ]; then err "no skills found under $SKILLS_DIR"; exit 1; fi
  info ""
  info "Edits to a skill's SKILL.md auto-apply through the symlink:"
  info "  - Claude Code hot-reloads live (restart once only if ~/.claude/skills"
  info "    did not exist when Claude started)."
  info "  - Codex auto-detects changes (restart Codex if one does not show)."
}

do_uninstall() {
  info "${B}Uninstalling omnipowers skills${N} (targets: $TARGETS)"
  local t dir link
  for t in $TARGETS; do
    dir="$(target_dir "$t")"
    [ -d "$dir" ] || continue
    for link in "$dir"/*; do
      [ -L "$link" ] && ours "$(link_target "$link")" || continue
      rm -f "$link"; ok "removed $link"
    done
  done
}

case "$COMMAND" in
  status)    print_status ;;
  dev)       print_status; info ""; do_install ;;
  uninstall) do_uninstall ;;
  *) err "unknown command: $COMMAND"; info 'use: status | dev | uninstall [--locale en|zh-CN] [--targets "claude codex"]'; exit 2 ;;
esac
