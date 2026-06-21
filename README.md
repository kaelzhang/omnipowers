# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [using-omnipowers](skills/using-omnipowers/SKILL.md) | Starting any task or conversation — how omnipowers skills work; check for and invoke any applicable skill before responding |
| [systematic-debugging](skills/systematic-debugging/SKILL.md) | Any bug, test failure, or unexpected behavior — you MUST find the root cause before proposing or making any fix |
| [test-driven-bug-fixing](skills/test-driven-bug-fixing/SKILL.md) | Fixing any bug or defect — you MUST reproduce it with a failing test before changing production code |
| [verification-before-completion](skills/verification-before-completion/SKILL.md) | About to claim work is complete/fixed/passing — you MUST run the verification and read its output before any success claim |
| [code-auditing](skills/code-auditing/SKILL.md) | Reviewing or auditing code — audit against the project's `.omnipowers/rules/CODE_AUDITING.md` checklist, record the result, report a summary, and evolve the checklist over time |
| [brainstorming](skills/brainstorming/SKILL.md) | Before any creative or implementation work — you MUST explore intent, requirements, and design and get the design approved before writing code |
| [writing-plans](skills/writing-plans/SKILL.md) | Turning a spec into a multi-step task — you MUST produce a complete, self-contained, bite-sized plan with zero placeholders before coding |
| [executing-plans](skills/executing-plans/SKILL.md) | Executing a written plan — you MUST review it critically, then run each step in order and verify at every checkpoint |
| [subagent-driven-development](skills/subagent-driven-development/SKILL.md) | Executing a plan of mostly-independent tasks — one task at a time, reviewing spec + quality of each before the next, with a broad whole-branch review at the end |
| [dispatching-parallel-agents](skills/dispatching-parallel-agents/SKILL.md) | 2+ genuinely independent tasks — verify independence, then one focused agent per domain (or sequential inline where subagents are unavailable) |
| [requesting-code-review](skills/requesting-code-review/SKILL.md) | Work complete or before merge — you MUST get a fresh-eyes review of the finished work against its requirements |
| [using-git-worktrees](skills/using-git-worktrees/SKILL.md) | Feature work needing isolation — you MUST ensure an isolated workspace via the host's native worktree tool or a `git worktree` fallback |
| [finishing-a-development-branch](skills/finishing-a-development-branch/SKILL.md) | Work complete and verified — verify tests, present structured merge/PR/keep/discard options, execute the choice, and clean up only what you created |
| [writing-skills](skills/writing-skills/SKILL.md) | Creating or editing a skill — you MUST develop it test-first (watch an agent fail without it first); conforms to `AGENTS.md` |
| [confirming-with-the-user](skills/confirming-with-the-user/SKILL.md) | Any decision or sign-off the user owns (a design, review proposals/findings, a trade-off) — present plain-language options with each option's impact and your recommendation, one decision at a time, in one language |

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
