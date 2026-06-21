# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [using-omnipowers](skills/using-omnipowers/SKILL.md) | Starting any task or conversation — how omnipowers skills work; check for and invoke any applicable skill before responding |
| [test-driven-bug-fixing](skills/test-driven-bug-fixing/SKILL.md) | Fixing any bug or defect — you MUST reproduce it with a failing test before changing production code |
| [code-auditing](skills/code-auditing/SKILL.md) | Reviewing or auditing code — audit against the project's `.omnipowers/rules/CODE_AUDITING.md` checklist, record the result, report a summary, and evolve the checklist over time |

## Install

Install the skills into Claude Code and Codex. Skills are **symlinked**, so your
edits auto-apply without reinstalling.

```bash
make dev            # analyze Claude/Codex status, then install for both
make dev FORCE=1    # re-link even if already installed
make status         # show what is installed
make uninstall      # remove the symlinks
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

## Project files (`.omnipowers/`)

Some skills keep per-project state in a `.omnipowers/` directory at the root of
the project you run them in (not in this repo). For `code-auditing`:

- `.omnipowers/rules/CODE_AUDITING.md` — the project's audit checklist; a durable,
  reviewed quality standard. **Commit it** so the whole team shares one standard.
- `.omnipowers/reviews/` — dated audit logs (`<date>-<time>-<target>.md`). A
  running record; **gitignore it** if you do not want logs in version control.

## Credits

omnipowers is inspired by [Superpowers](https://github.com/obra/superpowers) by
Jesse Vincent.

## License

MIT — see [LICENSE](LICENSE).
