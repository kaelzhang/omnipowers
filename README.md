# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [test-driven-bug-fixing](skills/test-driven-bug-fixing/SKILL.md) | Fixing any bug or defect — you MUST reproduce it with a failing test before changing production code |

## Install

Install the skills into Claude Code and Codex. Skills are **symlinked**, so your
edits auto-apply without reinstalling.

```bash
make dev          # analyze Claude/Codex status, then install for both
make status       # show what is installed
make install      # install (idempotent; FORCE=1 to re-link)
make uninstall    # remove the symlinks
```

Skills are discovered at:

| Tool | Path |
| --- | --- |
| Claude Code | `~/.claude/skills/<name>/` |
| Codex | `~/.agents/skills/<name>/` |

Because skills are symlinked, editing a skill's `SKILL.md` takes effect **without
reinstalling**: Claude Code hot-reloads it live in the session; Codex auto-detects
the change (restart Codex if it does not show). Re-run `make install` only when
you add a new skill.

## Credits

omnipowers is inspired by [Superpowers](https://github.com/obra/superpowers) by
Jesse Vincent.

## License

MIT — see [LICENSE](LICENSE).
