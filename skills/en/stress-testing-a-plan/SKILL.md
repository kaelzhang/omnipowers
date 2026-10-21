---
name: stress-testing-a-plan
description: Use when the user asks you to interrogate their plan, idea, or decision — "stress-test", "poke holes", "grill me", "拷问我" — with no build intended (building → brainstorming; one decision to sign off → confirming-with-the-user); you MUST question every branch, one dependency-ordered question at a time, and produce no artifact
---

# Stress-Testing a Plan

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Definitions

- Stress-testing a plan — sustained interrogation of the user's plan.
- Interrogation end — the user confirms shared understanding of the plan's shape, trade-offs, and decision taken on each branch.
- Decision tree — the plan's explicit and assumed choices as nodes, with their alternatives, risks, and consequences as branches.

## When to Use

- The user asks you to interrogate their plan, idea, or decision with no build necessarily intended → you MUST use this skill.
- You are about to build anything → you MUST NOT use this skill as a backdoor around the brainstorming skill's gate for settling the goal and its delivery criteria before code.

## The Interrogation Loop

- During interrogation → you MUST cover each branch of the decision tree: goals, assumptions, alternatives, risks, failure modes, and edge cases, including branches the user has not considered.
- Before asking a question dependent on a parent decision → you MUST settle that parent decision.
- When asking a question → you MUST ask exactly one question, then wait for the user's answer before the next.
- When asking a question → you MUST include the answer you would give, with a one-line reason.
- A fact is obtainable from the environment (the codebase, docs, a command, or a search) → you MUST look it up yourself.
- A fact is obtainable from the environment → you MUST NOT ask the user for it.
- A decision is owned by the user → you MUST put it to the user.
- A decision is owned by the user → you MUST NOT assume or silently decide it.
- When presenting a question → you MUST follow the confirming-with-the-user skill: plain language, labelled options where the choice is enumerable, each option's impact, and your recommendation.

## Terminal State

- During this skill → you MUST NOT produce a new spec, design document, plan file, notes file, or any other artifact.
- The interrogation changed a decision the project already records → that record MUST be updated once the interrogation ends, never during it.

## The Handoff

- The user decides to build any of the plan, including requesting a written spec or design → you MUST hand off to the brainstorming skill, with its goal gate governing from there.
- A plan has been grilled → you MUST NOT treat it as a settled goal.

## Rationalizations — Rejected

- "The user is the expert — no recommendation needed" → the recommendation is REQUIRED.
