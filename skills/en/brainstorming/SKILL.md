---
name: brainstorming
description: "Use before building anything — a feature, a behavior change, scaffolding, a refactor — you MUST state the goal and its delivery criteria (「终极目标」「交付标准」) in one line before writing code, and settle with the user only that, an unresolvable blocker, a serious risk, or a disagreement. How and when to build is yours."
---

# Brainstorming

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Gate

```
STATE THE GOAL AND ITS DELIVERY CRITERIA IN ONE LINE, OR SETTLE THEM FIRST
```

Before writing code → you MUST be able to state, in one line, what the work must achieve and the observable condition under which it is done, and be confident the user would agree with both.

You can state both, and none of the four user decisions below applies → you MUST NOT ask for permission, a design review, or sign-off on a plan.

## User Decisions

User decisions — the goal and its delivery criteria; a blocker you cannot resolve; a serious risk; a disagreement with the request.

Serious risk — work that would break an existing contract, lose data, be hard to reverse, or carry a cost the user has not seen.

Disagreement with the request — a verified project fact contradicting the request: the capability already exists, the stated assumption does not hold, or a materially better path exists.

One of the four user decisions applies → you MUST settle it with the user.

- The goal or its delivery criteria are unclear or rest on your assumption → you MUST settle them with the user before building.
- A blocker cannot be resolved → you MUST present it with your proposed workaround, and you MUST obtain approval of that workaround before applying it.
- A serious risk applies → you MUST name the risk, its consequence, and your recommendation.
- A disagreement with the request applies → you MUST state what you verified and where, and your alternative.

Presenting one of the four user decisions → you MUST use the `confirming-with-the-user` skill.

## Questions Excluded

During brainstorming → you MUST NOT ask the user about:

- how the work will be done: the approach, architecture, decomposition, libraries, file layout, or order of steps;
- when to do it: sequencing, staging, or what comes first;
- permission to proceed on a goal already settled;
- anything you can determine yourself;
- a decision already made;
- a trivial, reversible choice with an obvious default.

## Best Practice

Choosing the approach → you MUST choose what a competent practitioner in this domain would choose, grounded in established practice of the project's industry and fitting the project's existing paradigm and conventions.

- No established pattern exists, the choice binds beyond this work or is hard to reverse, and you cannot name current practice with confidence → you MUST verify it against an authoritative source before settling.
- That decision requires authoritative verification → recall MUST NOT be its basis.
- Ordinary work in a settled domain concerns a question you can already answer → you MUST NOT spend the user's time researching it.
- The capability may already exist → you MUST search the codebase by domain concept, not just by keyword, before building it.
- The design contradicts a recorded project decision → you MUST surface the contradiction rather than silently override it.
- The request spans several independent subsystems → you MUST state that scope and decompose before starting.
- An approach is faster to implement, easier to test, or avoids a conversation → you MUST NOT choose it on those grounds.
- Delivering the work → you MUST NOT present a weaker version as the goal.
- You knowingly took a shortcut → you MUST state it to the user in the message delivering the work.

The design centres on a module interface and the alternatives are non-obvious → read `@design-it-twice.md` and apply it before settling on one.

Reasoning and research cannot settle a design question → you MAY answer it with a throwaway prototype built under the `prototyping` skill's full rule-set.

## Goal Record

Goal record — the settled goal and its delivery criteria, a `design-docs` artifact located per `using-omnipowers`, fallback `docs/design/YYYY-MM-DD-<topic>.md`.

You could state the goal unaided and the work lands this round → you MUST NOT create a document for it.

Before building → you MUST NOT wait for the goal record to be reviewed or approved.

The goal record has been written → you MUST NOT re-review it.
