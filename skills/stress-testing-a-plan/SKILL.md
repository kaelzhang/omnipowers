---
name: stress-testing-a-plan
description: Use when the user asks you to interrogate their plan, idea, or decision — "stress-test", "poke holes", "grill me", "拷问我" — with no build intended (building → brainstorming; one decision to sign off → confirming-with-the-user); you MUST question every branch, one dependency-ordered question at a time, and produce no artifact
---

# Stress-Testing a Plan

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- End state: every branch of the user's plan interrogated, every decision the user owns put to them and answered, nothing built and nothing written down.
- You probe; the user decides.
- **Core principle:** decisions are the user's, facts are yours to fetch → you surface the questions the plan has not answered; you do not answer them for the user, and you do not replace their plan with your own.

## When to Use — and When Another Skill Governs

- The user asks you to interrogate their plan, idea, or decision — "stress-test this", "poke holes", "grill me", "challenge this idea", "拷问我" — with no build necessarily intended → you MUST use this skill.
- **About to BUILD anything** → the brainstorming skill governs: the goal and its delivery criteria get settled before code. You MUST NOT use this skill as a backdoor around that gate.
- **Presenting a single decision for sign-off** → the confirming-with-the-user skill governs on its own.
- **This skill** = sustained interrogation of the user's plan, and nothing else.

## The Interrogation Loop

Treat the plan as a decision tree: every choice it makes — or silently assumes — is a node, with alternatives, risks, and consequences hanging off it. Then:

1. **Walk EVERY branch.** You MUST cover each branch of the tree — goals, assumptions, alternatives, risks, failure modes, edge cases — not only the branches the user already thought about.
2. **Dependency order.** You MUST settle a parent decision before asking any question that hangs off it.
3. **One question at a time.** You MUST ask exactly one question, then wait for the user's answer before the next.
4. **Every question carries your recommended answer.** Each question MUST include the answer you would give, with a one-line reason.
5. **Look up facts; ask only decisions.** Any fact obtainable from the environment (the codebase, docs, a command, a search) you MUST look up yourself and MUST NOT ask the user for. Anything that is genuinely the user's call you MUST put to the user and MUST NOT assume or silently decide.
6. **Presentation.** Each question's presentation MUST follow the confirming-with-the-user skill: plain language, labelled options where the choice is enumerable, each option's impact, and your recommendation.

## Terminal State — Shared Understanding, Nothing Written

- The user confirms a shared understanding of the plan — its shape, its trade-offs, and the decision taken on each branch → the interrogation ends.
- This skill is stateless. You MUST NOT produce a **new** spec, design document, plan file, notes file, or any other artifact.
- The user asks for a written spec or design → that is build intent → hand off, below.
- The interrogation changed a decision the project already records — a plan the host keeps, a recorded design decision → that record MUST be updated once the interrogation ends, never during it.

## The Handoff — the Moment Build Intent Appears

- The user decides to actually build any of it — "let's do it", "implement option B", "write this up" → you MUST hand off to the brainstorming skill, and its goal gate governs from there.
- A grilled plan is NOT a settled goal → you MUST NOT treat it as one; hand off and settle the goal.

## Rationalizations — Rejected

- "Batching all my questions is faster" → one question at a time, in dependency order.
- "This branch is obvious, skip it" → every branch gets walked.
- "The user is the expert — no recommendation needed" → the recommendation is REQUIRED.
- "We've basically agreed — I'll just draft the design" → shared understanding ends this skill; hand off to the brainstorming skill.

## Red Flags — STOP

Stop when any of these occurs:

- Answering your own question and moving on.
- Drifting into designing the solution yourself.
- Writing a spec / notes / summary file.
- Firing several questions at once.
- Asking the user a fact you could look up.
- Starting to build "since we basically agreed".
