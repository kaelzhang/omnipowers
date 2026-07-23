# Skill Map — how the collection fits together

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this map when you are unsure which skill governs the current step, or when two adjacent skills both look applicable. Each entry is one line plus, where confusion is common, an anti-routing line. The map is an index — the skill's own `SKILL.md` is always the authority.

## The main flow — building something

```
stress-testing-a-plan ─(build intent)→ brainstorming → writing-plans
        → executing-plans / subagent-driven-development
        → finishing-a-development-branch
```

- **brainstorming** — the design gate: explore intent → approved written spec. Every build passes through it. NOT for interrogating a plan with no build intended (that is stress-testing-a-plan).
- **writing-plans** — turn the approved spec into a bite-sized implementation plan. NOT for executing it.
- **executing-plans** — execute a written plan yourself, continuously, step-verified. When the host has subagents AND the plan's tasks are mostly independent → subagent-driven-development instead.
- **subagent-driven-development** — execute a plan one fresh implementer+reviewer pair per task. NOT for tightly coupled plans (executing-plans) or ad-hoc parallel work (dispatching-parallel-agents).
- **finishing-a-development-branch** — the work is done and verified: merge / PR / keep / discard + cleanup. If the merge conflicts → resolving-merge-conflicts.

## On-ramps — something is wrong

- **systematic-debugging** — any bug, crash, flaky test, build or perf problem: root cause before any fix. It governs the *investigation*.
- **test-driven-bug-fixing** — the fix itself: a reproducing failing test before production code changes. Debugging finds the cause; this skill lands the fix.
- **resolving-merge-conflicts** — an in-progress merge/rebase with conflict markers: per-hunk intent archaeology, never invent behavior.

## Design-time instruments

- **designing-deep-modules** — module/interface shape: depth, the deletion test, the two-adapter rule. Serves brainstorming's design step; not a workflow of its own.
- **prototyping** — a design question only running code can answer: throwaway artifact, user delivers the verdict. NOT a first draft of the feature.
- **researching** — a question answered by investigation: primary sources, per-claim citations, findings file. NOT design itself.
- **domain-modeling** — the project's language: glossary (CONTEXT.md), gated ADRs. Fires when terms drift or a recorded decision is being made — merely *reading* the glossary is not this skill.

## Underneath everything — cross-cutting disciplines

- **confirming-with-the-user** — HOW any single decision is put to the user (options, impacts, recommendation, prose). Every other skill's user-facing decisions ride on it.
- **verification-before-completion** — evidence before any "done/fixed/passing" claim. Gates every completion claim in every flow.
- **dispatching-parallel-agents** — 2+ genuinely independent tasks fan out; independence proven first. A mechanism other flows may use, not a flow itself.
- **code-auditing / requesting-code-review** — code-auditing audits against the host's checklist (whole project or diff, compounding standard); requesting-code-review gets a fresh-eyes two-axis review of finished work against its requirements. Audit = your standard; review = this diff.

## Crossing sessions

- **writing-handoffs** — user asks to hand off: compact the session into a doc a zero-context agent resumes from. Explicit request only.

## Standalone

- **stress-testing-a-plan** — the user asks to have THEIR plan interrogated; zero artifacts; build intent hands off to brainstorming.
- **writing-skills** — creating or editing any skill, test-first.

## Boundary rules (the chronic confusions)

- Interrogating the user's plan (they answer) → **stress-testing-a-plan**; presenting them one decision (you propose) → **confirming-with-the-user**; about to build → **brainstorming**.
- Finding a bug's cause → **systematic-debugging**; writing the fix → **test-driven-bug-fixing**.
- Judging finished work → **requesting-code-review**; auditing code against the project standard → **code-auditing**.
- Executing a plan with subagents per task → **subagent-driven-development**; parallel unrelated tasks → **dispatching-parallel-agents**.
