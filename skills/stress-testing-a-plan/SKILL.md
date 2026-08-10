---
name: stress-testing-a-plan
description: Use when the user asks you to interrogate their plan, idea, or decision — "stress-test", "poke holes", "grill me", "拷问我" — with no build intended (building → brainstorming; one decision to sign off → confirming-with-the-user); you MUST question every branch, one dependency-ordered question at a time, and produce no artifact
---

# Stress-Testing a Plan

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

The end state is shared understanding: every branch of the user's plan has been interrogated, every decision the user owns has been put to them and answered, and nothing has been built or written down. This skill is a sustained interview of the USER'S thinking — you probe, they decide.

**Core principle:** Decisions are the user's; facts are yours to fetch. You surface the questions the plan has not answered — you do not answer them for the user, and you do not replace their plan with your own.

## When to Use — and When Another Skill Governs

You MUST use this skill when the user asks you to interrogate their plan, idea, or decision — "stress-test this", "poke holes", "grill me", "challenge this idea", "拷问我" — with no build necessarily intended.

Routing boundaries — crossing them bypasses a gate this skill has no authority to open:

- **About to BUILD anything** → the brainstorming skill governs, and its full design gate applies. You MUST NOT use this skill as a backdoor around that gate.
- **Presenting a single decision for sign-off** → the confirming-with-the-user skill governs on its own.
- **This skill** = sustained interrogation of the user's plan, and nothing else.

## The Interrogation Loop

Treat the plan as a decision tree: every choice it makes — or silently assumes — is a node, with alternatives, risks, and consequences hanging off it. Then:

1. **Walk EVERY branch.** You MUST cover each branch of the tree — goals, assumptions, alternatives, risks, failure modes, edge cases — not only the branches the user already thought about. The unexamined branch is where the plan fails.
2. **Dependency order.** You MUST settle a parent decision before asking any question that hangs off it. An early answer reshapes the later questions; a child question asked before its parent is settled is likely the wrong question entirely.
3. **One question at a time.** You MUST ask exactly one question, then wait for the user's answer before the next. Parallel questions bewilder the user and tangle the dependencies you are trying to resolve.
4. **Every question carries your recommended answer.** Each question MUST include the answer you would give, with a one-line reason. A question with no recommendation offloads your thinking onto the user.
5. **Look up facts; ask only decisions.** Any fact obtainable from the environment (the codebase, docs, a command, a search) you MUST look up yourself and MUST NOT ask the user for. Anything that is genuinely the user's call you MUST put to the user and MUST NOT assume or silently decide.
6. **Presentation.** Each question's presentation MUST follow the confirming-with-the-user skill: plain language, labelled options where the choice is enumerable, each option's impact, and your recommendation.

## Terminal State — Shared Understanding, Nothing Written

The interrogation ends when the user confirms you have reached a shared understanding of the plan: its shape, its trade-offs, and the decision taken on each branch.

This skill is stateless. You MUST NOT produce a **new** spec, design document, plan file, notes file, or any other artifact — not even "a quick summary doc". Its entire output is the conversation itself. A request for a written spec or design is build intent — hand off, below.

Stateless means this skill authors nothing; it does not mean the conclusions evaporate. Where the interrogation changed a decision the project already records — a plan the host keeps, a recorded design decision — that record MUST be updated once the interrogation ends, so the plan on disk stops contradicting the plan you just agreed to. Update it after the interrogation closes, never during: writing mid-flight turns an interrogation into a documentation exercise, which is the failure this rule exists to prevent.

## The Handoff — the Moment Build Intent Appears

The moment the user decides to actually build any of it — "let's do it", "implement option B", "write this up" — you MUST hand off to the brainstorming skill, and its full design gate governs from there. The interrogation's answers are input to that gate, not a substitute for it: a grilled plan is NOT an approved design, and you MUST NOT treat it as one.

## Rationalizations — Rejected

| Excuse | Reality |
|---|---|
| "Batching all my questions is faster" | An early answer reshapes the later questions — a batch asks the wrong ones. One at a time, in dependency order. |
| "This branch is obvious, skip it" | Obvious to you is not settled by the user. Every branch gets walked; skipped branches are where plans die. |
| "The user is the expert — no recommendation needed" | A question without your recommended answer offloads your thinking onto them. The recommendation is REQUIRED. |
| "We've basically agreed — I'll just draft the design" | Shared understanding ends this skill; it does not open the design gate. Hand off to the brainstorming skill. |

## Red Flags — STOP

| Red flag | Why it is wrong |
|---|---|
| Answering your own question and moving on | The decision was the user's; you just took it from them. |
| Drifting into designing the solution yourself | This skill interrogates THEIR plan; your design belongs to the brainstorming skill, behind its gate. |
| Writing a spec / notes / summary file | This skill is stateless — it produces no artifact, ever. |
| Firing several questions at once | Breaks dependency order and bewilders the user. |
| Asking the user a fact you could look up | Facts are yours to fetch; only decisions go to the user. |
| Starting to build "since we basically agreed" | Build intent triggers the handoff — the design gate is not optional. |
