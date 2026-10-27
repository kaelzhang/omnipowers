---
name: brainstorming
description: "Use before building anything — a feature, a behavior change, scaffolding, a refactor — you MUST state the goal and its delivery criteria (「终极目标」「交付标准」) in one line before writing code, and settle with the user the goal, any technical approach with more than one viable option, an unresolvable blocker, a serious risk, or a disagreement. Order and timing are yours."
---

# Brainstorming

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Gate

```
STATE THE GOAL AND ITS DELIVERY CRITERIA IN ONE LINE, OR SETTLE THEM FIRST
```

Before writing code → you MUST be able to state, in one line, what the work must achieve and the observable condition under which it is done, and be confident the user would agree with both.

Before writing code → every technical approach decision the work requires MUST be settled under `confirming-with-the-user`.

You can state both, every technical approach decision is settled, and no other decision `confirming-with-the-user` assigns to the user is open → you MUST NOT ask for permission, a design review, or sign-off on a plan.

## User Decisions

- The goal or its delivery criteria are unclear or rest on your assumption → you MUST settle them with the user before building.
- A decision `confirming-with-the-user` assigns to the user arises → you MUST settle it under that skill before building against it.
- Considering a question to the user → you MUST NOT ask anything `confirming-with-the-user` lists under What You MUST NOT Ask.

## Best Practice

Choosing or recommending a technical approach → you MUST choose what a competent practitioner in this domain would choose, grounded in established practice of the project's industry and fitting the project's existing paradigm and conventions.

- No established pattern exists, the choice binds beyond this work or is hard to reverse, and you cannot name current practice with confidence → you MUST verify it against an authoritative source before settling.
- That decision requires authoritative verification → recall MUST NOT be its basis.
- Ordinary work in a settled domain concerns a question you can already answer → you MUST NOT spend the user's time researching it.
- The capability may already exist → you MUST search the codebase by domain concept, not just by keyword, before building it.
- The design contradicts a recorded project decision → you MUST surface the contradiction rather than silently override it.
- The request spans several independent subsystems → you MUST state that scope and decompose before starting.
- An approach is faster to implement, easier to test, or avoids a conversation → you MUST NOT choose it on those grounds.
- Delivering the work → you MUST NOT present a weaker version as the goal.
- You knowingly took a shortcut → you MUST state it to the user in the message delivering the work.

Efficient execution — the order and execution that reach the settled goal in the least elapsed time: pieces of work with no dependency between them run in parallel under `keeping-work-in-flight`, and a result already obtained on the same input is reused under `verification-before-completion`.

- Planning the order and execution of the work → you MUST choose efficient execution.
- Choosing order or execution for speed → you MUST NOT lower the goal, the delivery criteria, or the technical approach.

The design centres on a module interface and the alternatives are non-obvious → read `@design-it-twice.md` and apply it before settling on one.

Reasoning and research cannot settle a design question → you MAY answer it with a throwaway prototype built under the `prototyping` skill's full rule-set.

## Goal Record

Goal record — the settled goal, its delivery criteria, and its technical approach decisions, a `design-docs` artifact located per `using-omnipowers`, fallback `docs/design/YYYY-MM-DD-<topic>.md`.

You could state the goal unaided and the work lands this round → you MUST NOT create a document for it.

Before building → you MUST NOT wait for the goal record to be reviewed or approved.

The goal record has been written → you MUST NOT re-review it.
