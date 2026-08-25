# Skill Map — how the collection fits together

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this map when you are unsure which skill governs the current step, or when two adjacent skills both look applicable. Each entry is one line plus, where confusion is common, an anti-routing line. The map is an index — the skill's own `SKILL.md` is always the authority.

## The main flow — building something

```
stress-testing-a-plan ─(build intent)→ brainstorming → writing-plans
        → executing-plans / subagent-driven-development
        → finishing-a-development-branch
```

- **brainstorming** — the pre-build gate on the GOAL, not the design: state the goal and its delivery criteria in one line, or settle them with the user first, along with any blocker, serious risk, or disagreement. How and when to build is the agent's. NOT for interrogating a plan with no build intended (that is stress-testing-a-plan).
- **writing-plans** — turn a settled goal into a bite-sized implementation plan. NOT for executing it.
- **executing-plans** — execute a written plan yourself, continuously, step-verified. When the host has subagents AND the plan's tasks are mostly independent → subagent-driven-development instead.
- **subagent-driven-development** — execute a plan one fresh implementer+reviewer pair per task. NOT for tightly coupled plans (executing-plans) or ad-hoc parallel work (keeping-work-in-flight).
- **finishing-a-development-branch** — the work is done and verified: merge / PR / keep / discard + cleanup. If the merge conflicts → resolving-merge-conflicts.
- **using-git-worktrees** — the work needs isolation before it starts: detect existing isolation, prefer the host's native mechanism, verify a clean baseline. Owns the return to the mainline when the work is done. NOT the integration decision itself (finishing-a-development-branch).

## On-ramps — something is wrong

- **systematic-debugging** — any bug, crash, flaky test, build or perf problem: root cause before any fix. It governs the *investigation*.
- **test-driven-bug-fixing** — the fix itself: a reproducing failing test before production code changes. Debugging finds the cause; this skill lands the fix.
- **resolving-merge-conflicts** — an in-progress merge/rebase with conflict markers: per-hunk intent archaeology, never invent behavior.

## Design-time instruments

- **designing-deep-modules** — module/interface shape: depth, the deletion test, the two-adapter rule. Serves the agent's own design choices; not a workflow of its own.
- **prototyping** — a design question only running code can answer: throwaway artifact, user delivers the verdict. NOT a first draft of the feature.
- **researching** — a question answered by investigation: primary sources, per-claim citations, findings file. NOT design itself.
- **domain-modeling** — the project's language: glossary (CONTEXT.md), gated ADRs. Fires when terms drift or a recorded decision is being made — merely *reading* the glossary is not this skill.

## Underneath everything — cross-cutting disciplines

- **confirming-with-the-user** — HOW any single decision is put to the user (options, impacts, recommendation, prose). Every other skill's user-facing decisions ride on it.
- **verification-before-completion** — evidence before any "done/fixed/passing" claim. Gates every completion claim in every flow.
- **keeping-work-in-flight** — the dispatch block: at every agent return and before any round ends, count what is running, dispatch one tracked call per idle ownership scope, then read. Also owns the independence gate for fan-out and the continuation of work past the round.
- **committing-work** — how each individual commit is formed: one coherent change, explicit paths, the smallest proving check, a standalone message. NOT integrating the branch afterwards (finishing-a-development-branch), NOT judging the code (code-auditing).
- **code-auditing** — all code review and audit: a checkpoint review of finished work before it advances (merge-base range, reviewed against its requirements) OR a standards audit against the host's compounding checklist; Phase 1 routes between them, and both record + act on findings by severity.

## Crossing sessions

- **writing-handoffs** — user asks to hand off: compact the session into a doc a zero-context agent resumes from. Explicit request only.

## Standalone

- **stress-testing-a-plan** — the user asks to have THEIR plan interrogated; zero artifacts; build intent hands off to brainstorming.
- **writing-skills** — creating or editing any skill, test-first.
- **writing-documentation** — durable project documentation: one entrypoint per set, task-signal routing to exact files, updated in the same change. NOT a skill (writing-skills), NOT a handoff (writing-handoffs), NOT the glossary or decision records themselves (domain-modeling).

## Boundary rules (the chronic confusions)

- Interrogating the user's plan (they answer) → **stress-testing-a-plan**; presenting them one decision (you propose) → **confirming-with-the-user**; about to build → **brainstorming**.
- Finding a bug's cause → **systematic-debugging**; writing the fix → **test-driven-bug-fixing**.
- Any code review or audit → **code-auditing** (it routes internally: checkpoint review vs standards audit).
- Executing a plan with subagents per task → **subagent-driven-development**; parallel unrelated tasks → **keeping-work-in-flight**.
- Making a commit → **committing-work**; merging, pushing, or opening the PR afterwards → **finishing-a-development-branch**. "Commit and push" splits across both.
- Writing a project document → **writing-documentation**; writing a `SKILL.md` → **writing-skills**. What a term means or whether a decision is worth recording → **domain-modeling**; how it is reached and structured → **writing-documentation**.
