---
name: brainstorming
description: "Use before building anything — a feature, a behavior change, scaffolding, a refactor — you MUST state the goal and its delivery criteria in one line before writing code, and settle with the user only that, an unresolvable blocker, a serious risk, or a disagreement. How and when to build is yours."
---

# Brainstorming

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Gate

```
STATE THE GOAL AND ITS DELIVERY CRITERIA IN ONE LINE, OR SETTLE THEM FIRST
```

Before writing code you MUST be able to state, in one line, what the work must achieve and the observable condition under which it is done — and be confident the user would agree with both.

- You can state both, and nothing in the list below applies → build. You MUST NOT ask for permission, a design review, or sign-off on a plan.
- You cannot state both → put the gap to the user and settle it before building.

## What You MUST Settle With the User

These four, and nothing else. Each is the user's to decide and yours to surface.

1. **The goal and its delivery criteria.** What the work must achieve, and how you will both know it is done. Unclear, or resting on an assumption you made → ask.
2. **A blocker you cannot resolve.** Missing access or credentials, information only the user has, a broken external dependency, a constraint that makes the goal unreachable. You MUST present it with the workaround you propose, and you MUST obtain approval of that workaround before applying it.
3. **A serious risk.** The work as asked would break an existing contract, lose data, be hard to reverse, or carry a cost the user has not seen. You MUST name the risk, its consequence, and your recommendation.
4. **A disagreement with the request.** You verified something in the project that contradicts what was asked — the capability already exists, the stated assumption does not hold, a materially better path exists. You MUST state what you verified and where, and your alternative.

You MUST present each through the `confirming-with-the-user` skill: plain language, options, each option's impact, your recommendation. You MUST object once; the user's answer settles it.

## What You MUST NOT Ask

- **How the work will be done** — the approach, the architecture, the decomposition, the libraries, the file layout, the order of steps. You choose these.
- **When to do it** — sequencing, staging, what comes first.
- **Permission to proceed** on a goal already settled.
- **Anything you can determine yourself.** Read the code, the docs, the configuration, the history. Investigate; do not interrogate.
- **A decision already made.**

Two or more of these questions in a row → you are asking the user to do your job.

## Best Practice Is Mandatory

You choose the approach, so you own it.

- You MUST choose the approach a competent practitioner in this domain would choose, grounded in the established practice of the industry this project belongs to, and fitting the project's existing paradigm and conventions.
- The project already has an established pattern for this → follow it. No research.
- No established pattern, AND the choice binds beyond this work — a dependency, a public contract, a data schema, a wire protocol, an auth or concurrency decision — or is hard to reverse, AND you cannot name current practice with confidence → you MUST verify it against an authoritative source before settling. Recall MUST NOT be the basis for that class of decision.
- Ordinary work in a settled domain → decide from what you know and build. You MUST NOT spend the user's time researching a question you can already answer.
- The capability may already exist → you MUST search the codebase by domain concept, not just by keyword, before building it.
- The design contradicts a decision the project has recorded → you MUST surface the contradiction rather than silently override it.
- The request spans several independent subsystems → you MUST say so and decompose before starting.
- You MUST NOT choose an approach because it is faster to implement, easier to test, or avoids a conversation. Implementation effort is not a design criterion.
- You MUST NOT deliver a weaker version and present it as the goal. A shortcut you took knowingly MUST be stated to the user in the same message that delivers the work.

The design centres on a module interface and the alternatives are non-obvious → read `@design-it-twice.md` and apply it before settling on one.

A design question that reasoning and research cannot settle MAY be answered with a throwaway prototype built under the `prototyping` skill's full rule-set.

## Record the Goal

The goal and its delivery criteria are settled → write them where the host keeps durable design documents: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in its `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — its `design-docs` row; (3) where the host already keeps design documents, when unambiguous; (4) the fallback `docs/design/YYYY-MM-DD-<topic>.md`. Resolving to 3 or 4 → confirm the location once, before the project's first such write; resolving to 1 or 2 → MUST NOT ask.

This is a record, not a gate. You MUST NOT wait for it to be reviewed or approved before building, and you MUST NOT re-review it once written.

## Red Flags — STOP

| Thought | What to do instead |
|---|---|
| "I'll ask which approach they prefer." | Choose by best practice. Ask only if the choice carries a serious risk. |
| "I should get the design approved first." | The goal is what gets settled. The design is yours. |
| "I'll write the spec and have them review it." | Settle the goal in conversation; the record follows the decision. |
| "Should I start with the backend or the frontend?" | Sequencing is yours. |
| "I'll confirm before each step." | The goal was settled once. Build to it. |
| "They said X but the code already does X — I'll build it anyway." | State what you verified, and where. |
| "This is simpler and it mostly works." | Not a design criterion. Choose what a competent practitioner would. |
| "I can't tell what 'done' looks like, but I'll start and find out." | That is the one thing the gate exists for. Ask. |
