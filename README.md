# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [test-driven-bug-fixing](skills/test-driven-bug-fixing/SKILL.md) | Fixing any bug or defect — you MUST reproduce it with a failing test before changing production code |

## Install (development)

During development, symlink a skill into a directory Claude Code watches so edits
hot-reload without restarting the session:

```bash
ln -s "$(pwd)/skills/test-driven-bug-fixing" ~/.claude/skills/test-driven-bug-fixing
```

## Credits

omnipowers is inspired by [Superpowers](https://github.com/obra/superpowers) by
Jesse Vincent.

## License

MIT — see [LICENSE](LICENSE).
