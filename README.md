# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [test-driven-development](skills/test-driven-development/SKILL.md) | Implementing any feature or bugfix, before writing implementation code |

## Install (development)

During development, symlink a skill into a directory Claude Code watches so edits
hot-reload without restarting the session:

```bash
ln -s "$(pwd)/skills/test-driven-development" ~/.claude/skills/test-driven-development
```

## Credits

omnipowers builds on [Superpowers](https://github.com/obra/superpowers) by Jesse
Vincent (MIT). Ported skills retain their original behavior; see `LICENSE`.

## License

MIT — see [LICENSE](LICENSE).
