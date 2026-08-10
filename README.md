# omnipowers

A collection of skills that improve coding effectiveness for AI coding agents.

## Skills

| Skill | Use when |
| --- | --- |
| [using-omnipowers](skills/using-omnipowers/SKILL.md) | Starting any task or conversation — how omnipowers skills work; check for and invoke any applicable skill before responding |
| [systematic-debugging](skills/systematic-debugging/SKILL.md) | Any bug, test failure, or unexpected behavior — you MUST find the root cause before proposing or making any fix |
| [test-driven-bug-fixing](skills/test-driven-bug-fixing/SKILL.md) | Fixing any bug or defect — you MUST reproduce it with a failing test before changing production code |
| [verification-before-completion](skills/verification-before-completion/SKILL.md) | About to claim work is complete/fixed/passing — you MUST run the verification and read its output before any success claim |
| [code-auditing](skills/code-auditing/SKILL.md) | Any code review or audit — a checkpoint review of finished work before it advances, or a standards audit against the project's compounding checklist; evidence for every finding, Critical/Important fixed before proceeding |
| [brainstorming](skills/brainstorming/SKILL.md) | Before any creative or implementation work — you MUST explore intent, requirements, and design and get the design approved before writing code |
| [writing-plans](skills/writing-plans/SKILL.md) | Turning a spec into a multi-step task — you MUST produce a complete, self-contained, bite-sized plan with zero placeholders before coding |
| [executing-plans](skills/executing-plans/SKILL.md) | Executing a written plan — you MUST review it critically, then run each step in order and verify at every checkpoint |
| [subagent-driven-development](skills/subagent-driven-development/SKILL.md) | Executing a plan of mostly-independent tasks — one task at a time, reviewing spec + quality of each before the next, with a broad whole-branch review at the end |
| [dispatching-parallel-agents](skills/dispatching-parallel-agents/SKILL.md) | 2+ genuinely independent tasks — verify independence, then one focused agent per domain (or sequential inline where subagents are unavailable) |
| [using-git-worktrees](skills/using-git-worktrees/SKILL.md) | Feature work needing isolation — you MUST ensure an isolated workspace via the host's native worktree tool or a `git worktree` fallback |
| [finishing-a-development-branch](skills/finishing-a-development-branch/SKILL.md) | Work complete and verified — verify tests, present structured merge/PR/keep/discard options, execute the choice, and clean up only what you created |
| [writing-skills](skills/writing-skills/SKILL.md) | Creating or editing a skill — you MUST develop it test-first (watch an agent fail without it first); conforms to `AGENTS.md` |
| [confirming-with-the-user](skills/confirming-with-the-user/SKILL.md) | Any decision or sign-off the user owns (a design, review proposals/findings, a trade-off) — present plain-language options with each option's impact and your recommendation, one decision at a time, in one language |
| [stress-testing-a-plan](skills/stress-testing-a-plan/SKILL.md) | The user asks to have their plan interrogated ("poke holes", "grill me") — dependency-ordered questions, each with a recommended answer; no artifact; build intent hands off to brainstorming |
| [domain-modeling](skills/domain-modeling/SKILL.md) | Building the project's language — a root `CONTEXT.md` glossary with banned synonyms, and ADRs gated by a three-part test; resolutions recorded the moment they land |
| [designing-deep-modules](skills/designing-deep-modules/SKILL.md) | Designing a module or interface — depth as the target: the deletion test kills pass-throughs, the two-adapter rule kills speculative abstraction |
| [prototyping](skills/prototyping/SKILL.md) | A design question only running code can answer — a throwaway artifact the user drives; the verdict is the user's observation, captured into the spec |
| [researching](skills/researching/SKILL.md) | Answering a question by investigation — every claim traced to the primary source that owns it, delivered as a cited findings file |
| [resolving-merge-conflicts](skills/resolving-merge-conflicts/SKILL.md) | An in-progress merge or rebase with conflicts — per-hunk intent archaeology; never invent behavior in a conflict hunk, never `--abort` to escape |
| [writing-handoffs](skills/writing-handoffs/SKILL.md) | The user asks to hand off the session — compact it into an evidence-cited, pointer-not-copy document a zero-context agent can resume from |
| [committing-work](skills/committing-work/SKILL.md) | Forming each commit — one coherent logical change, staged path by path, proven by the smallest sufficient check, with a message that stands alone and credits no tool |
| [writing-documentation](skills/writing-documentation/SKILL.md) | Creating or restructuring durable documentation — one entrypoint per set that routes a reader by task to exact files, updated in the same change |

## Install

### Quick install (no clone needed)

Install straight from GitHub with the [skills.sh](https://skills.sh) installer —
it auto-discovers every skill in this repo and installs into the agents you pick
(Claude Code, Codex, Cursor, and more):

```bash
npx skills add kaelzhang/omnipowers
```

Useful variants:

```bash
npx skills add kaelzhang/omnipowers -g                       # user-level install
npx skills add kaelzhang/omnipowers -a claude-code -a codex  # pick agents
npx skills add kaelzhang/omnipowers --skill brainstorming    # pick skills
npx skills update                                            # update later
```

### From a clone (development)

For hacking on the skills themselves, clone this repo and install by **symlink**,
so your edits auto-apply without reinstalling:

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
the change (restart Codex if it does not show). Re-run `make dev` only when
you add a new skill.

## Where skills put things

Skills produce files — a design, a plan, an audit report, a debug harness. Each
one is filed under a **role**, and your project decides where that role lives:

| role | what it holds |
|---|---|
| `design-docs` | approved designs, decision records, research worth keeping |
| `work-state` | the plan, progress, blockers, next action, handoffs |
| `records` | audit reports and other one-off write-ups |
| `scratch` | debug harnesses, captured diffs, resume caches |
| `standards` | your project's own review checklist / coding standards |

Declare the mapping once, in the file your agents already read (`AGENTS.md` or
`CLAUDE.md`). Every row is optional:

```markdown
## Omnipowers

| role | location |
|---|---|
| design-docs | docs/design/ |
| work-state  | docs/planning/ |
| standards   | CONTRIBUTING.md |

- write-authority: <who may write where; how to get authorization otherwise>
- vcs: <your commit, staging, and message convention>
- isolation: <branch or worktree; paths that stay on the mainline>
```

**Declare nothing and the skills still work.** They fall back to sensible
defaults — durable documents to `docs/`, and in-flight or throwaway state to a
`.omnipowers/` directory at your project root — and they confirm the location
with you the first time they write each kind of file.

`.omnipowers/` is a **workbench, not an archive**: only in-flight and throwaway
state goes there, and `finishing-a-development-branch` empties it when the work
lands — promoting anything durable into your design documents and deleting the
rest. Gitignore it if you would rather it never enter version control.

## Developing skills

This repo ships tooling to test and improve the skills. It operates on the skills
here and is **not** part of what downstream projects install.

```bash
make test                                  # content checks on every skill (free)
make optimize BACKEND=claude               # optimize ALL skills -> staged proposals
make optimize SKILL=a,b,c BACKEND=codex    # only these skills
make optimize SKILL=a BACKEND=claude DRY=1 # report only, no staging
make optimize-status SKILL=a               # review a staged proposal
make optimize-adopt  SKILL=a               # apply it (a backup is kept)
make optimize-list                         # skills + eval/config/staged state
```

`make optimize` uses [SkillOpt-Sleep](https://github.com/microsoft/SkillOpt) — an
external dependency; set `SKILLOPT_HOME` to a local clone. For each skill it
replays tasks, proposes bounded edits, gates them on a held-out split, and
**stages** a proposal under `.skillopt-sleep/` (gitignored). It never edits a skill
until you `optimize-adopt`. A backend is **required** (`claude` or `codex`; both
call real models). Tasks come from an optional `<eval-root>/<skill>/tasks.json`
(set `OMNIPOWERS_EVAL_ROOT`); with no eval set, SkillOpt auto-discovers them from
your agent transcripts. An optional `<eval-root>/<skill>/config.json` sets per-skill
knobs (model, gate, edit budget).

## Credits

omnipowers is inspired by [Superpowers](https://github.com/obra/superpowers) by
Jesse Vincent, and absorbs ideas from [mattpocock/skills](https://github.com/mattpocock/skills)
by Matt Pocock.

## License

MIT — see [LICENSE](LICENSE).
