# Skill Map — how the collection fits together

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Skill map — an index of skill scopes, subordinate to each skill's own `SKILL.md`.

## The main flow — building something

```
stress-testing-a-plan ─(build intent)→ brainstorming → writing-plans
        → executing-plans / subagent-driven-development
        → finishing-a-development-branch
```

- **brainstorming** — the pre-build gate on the goal, its delivery criteria, and its technical approach, and best-practice, efficient planning of how and in what order to build; excludes interrogation of a plan with no build intended (`stress-testing-a-plan`).
- **writing-plans** — conversion of a settled goal into an implementation plan; excludes execution.
- **executing-plans** — continuous, step-verified execution of a written plan by the agent; excludes plans with mostly independent tasks when the host has subagents (`subagent-driven-development`).
- **subagent-driven-development** — plan execution with one fresh implementer and reviewer pair per task; excludes tightly coupled plans (`executing-plans`) and ad-hoc parallel work (`keeping-work-in-flight`).
- **finishing-a-development-branch** — integration and cleanup after work is done and verified: merge into the target branch (an integration branch or the mainline) without asking, or a PR under a host PR workflow, then removal of every merged worktree; merge conflicts belong to `resolving-merge-conflicts`.
- **using-git-worktrees** — isolation before work starts, including existing-isolation detection, preference for the host's native mechanism, baseline verification, and return to the target branch; excludes integration (`finishing-a-development-branch`).

## On-ramps — something is wrong

- **fixing-bugs** — reproduction, root-cause identification, correction, and a sweep of sites sharing the cause for a bug, crash, flaky test, regression, build problem, or performance problem; investigation depth loaded on demand.
- **resolving-merge-conflicts** — per-hunk intent reconstruction during an in-progress merge or rebase with conflict markers, without invented behavior.

## Design-time instruments

- **designing-deep-modules** — module and interface design criteria: depth, the deletion test, and the two-adapter rule; an instrument for design choices rather than a separate workflow.
- **prototyping** — a throwaway artifact answering a design question that requires running code, with a verdict delivered by the user; excludes a first draft of the feature.
- **researching** — investigation of a question using primary sources, per-claim citations, and a findings file; excludes design itself.
- **domain-modeling** — the project's language in a glossary (`CONTEXT.md`) and gated ADRs, scoped to term drift and recorded decisions; merely reading the glossary is not this skill.

## Underneath everything — cross-cutting disciplines

- **confirming-with-the-user** — presentation of a single decision to the user, including options, impacts, recommendation, and prose; owner of which decisions belong to the user and which questions are never asked, across skills.
- **verification-before-completion** — evidence requirements before every completion claim, including "done/fixed/passing" claims.
- **honoring-user-requirements** — the standing and work requirement ledgers: read before acting at each session start, compaction, and new piece of work; instructions recorded as stated, verified with evidence at each return and before claims, and carried out exactly once confirmed; appeals governed by `confirming-with-the-user`.
- **keeping-work-in-flight** — counting running work, dispatching one tracked call per idle ownership scope, and then reading at each agent return and before round end; owner of the independence gate for fan-out and continuation past the round.
- **continuous-work-mode** — explicit activation by the user of a stop-time command gate checking the queue before round end, without repeated requests to continue; mechanization of `keeping-work-in-flight`.
- **committing-work** — formation of an individual commit as one coherent change, with explicit paths, the smallest proving check, and a standalone message; excludes integration (`finishing-a-development-branch`) and code judgment (`code-auditing`).
- **code-auditing** — code review and audit, routed in Phase 1 between checkpoint review of finished work before it advances (merge-base range, reviewed against its requirements) and standards audit against the host's compounding checklist; findings recorded and acted on by severity.

## Crossing sessions

- **writing-handoffs** — an explicitly requested handoff document for resumption by an agent with no session context.

## Standalone

- **stress-testing-a-plan** — explicitly requested interrogation of the user's plan, without artifacts; build intent belongs to `brainstorming`.
- **writing-skills** — test-first creation or editing of a skill.
- **writing-documentation** — durable project documentation with one entrypoint per set, task-signal routing to exact files, and updates in the same change; excludes skills (`writing-skills`), handoffs (`writing-handoffs`), and glossary or decision records (`domain-modeling`).
