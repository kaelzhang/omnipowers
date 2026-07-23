---
name: prototyping
description: Use when asked to prototype, spike, mock up, or run a throwaway experiment — sanity-checking whether a state model, data shape, or piece of logic feels right, or exploring what a page, screen, or layout should look like before committing to a design — you MUST write the design question down before any prototype code and let the user, not your own run, deliver the verdict
---

# Prototyping

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A prototype is **throwaway code that answers one design question**. Not a first draft of the feature, not a demo, not proof that you can build it — a disposable instrument for settling a single open question. Done right, it ends as three things: the decision recorded in the design spec, the prototype preserved on a clearly-named throwaway branch, and a main branch that never saw any of it.

**Core principle:** The question scopes everything. Code that does not help answer the written question does not belong in the prototype.

## The Question Comes First

You MUST write the design question down — one or two sentences, at the top of the prototype's entry file or in a file next to it — **before writing any prototype code**.

The written question is what makes every later step checkable: it scopes what gets built, it defines when the prototype is done, and it is what the verdict and the capture are recorded against. A prototype without a written question cannot be checked for drift and cannot be captured — it is just unreviewed code.

## Pick the Branch

The question decides the artifact's shape. Getting this wrong wastes the whole prototype.

- Question about **state, logic, transitions, data shape, or API feel** ("does this state machine handle X then Y?", "can this model represent Z?") → read @logic-prototype.md and apply it.
- Question about **UI, layout, or information hierarchy** ("what should this page look like?", "which structure works?") → read @ui-prototype.md and apply it.

If the question could genuinely be either, you MUST ask the user which is being asked before building — a wrong guess here forfeits the entire artifact.

## Hygiene Rules

Every prototype, on both branches, MUST obey all five:

1. **Clearly marked throwaway.** Name and place the prototype so a casual reader sees it is a prototype (the word `prototype` in the path or filename). Locate it near the code it is prototyping for, following the host project's existing conventions — never a new top-level structure. Unmarked prototype code gets mistaken for production and maintained.
2. **One command to run.** You MUST wire the prototype into the host project's existing task runner (`package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, …) so the user starts it with a single command. A prototype the user cannot trivially run never gets driven — and the verdict never arrives. If the host has no task runner, the single command MUST be stated next to the written question.
3. **In-memory state only.** State lives in memory and resets on restart. You MUST NOT wire the prototype to a real database or persistent store; you MAY touch persistence ONLY when the written question is itself about persistence, and then only against a scratch store whose name marks it as disposable (e.g. `PROTOTYPE-wipe-me`).
4. **Skip all polish.** No tests, no abstractions, no error handling beyond what keeps the prototype runnable. Polish spends the very time the prototype exists to save, and disguises throwaway code as durable.
5. **Surface internal state visibly.** After every action or variant switch, the prototype MUST show the full relevant state (printed or rendered). Invisible state means the user cannot observe the model — and observation is the entire product of a prototype.

## The User Drives

You MUST hand over a runnable artifact: the run command (or URL) and how to drive it. The user pushes the prototype through the cases; the interesting moments — "wait, that shouldn't be possible", "I assumed X here" — are defects in the *idea*, and they only surface under the user's hands.

You MUST NOT declare the question answered from your own run. Your run proves the prototype executes; the verdict on the design is the **user's observation**, and only the user delivers it. If the user asks for new actions or variants while driving, add them — a prototype evolves freely inside the written question's scope.

## Capture Protocol

When the user delivers the verdict, you MUST capture it in two places:

1. **The decision → the design spec.** Record the question, the verdict, and the rationale in the design spec being brainstormed — the document under the host project's `.omnipowers/specs/` produced by the brainstorming skill. A verdict that stays in the conversation is lost.
2. **The prototype → a throwaway branch.** Commit the prototype itself to a clearly-named throwaway branch (e.g. `prototype/<question-slug>`) as the primary source behind the decision. **Main stays clean**: no variants, switchers, or terminal shells reach the main branch. Prototype code left in main rots fast and misleads the next reader.

## Red Flags — STOP

- The prototype is growing features the written question never asked for — it is drifting into unscoped implementation.
- You are adding tests, error handling, or abstractions to throwaway code — you are polishing what will be thrown away.
- You ran the prototype and are about to announce the answer — you are self-judging a verdict that belongs to the user.
- No written question exists — nothing scopes the work and nothing can be captured.
- Prototype code is heading into the main branch.

## Rationalizations — Rejected

| Excuse | Reality |
|---|---|
| "The question is obvious — I'll skip writing it down" | An unwritten question cannot scope the code or be checked at capture; drift becomes invisible. Write it first. |
| "It worked when I ran it — question answered" | Your run proves execution, not the design. The verdict is the user's observation; hand the artifact over. |
| "While I'm in here, I'll build the real feature" | That is unscoped implementation wearing a prototype's name. The real implementation goes through design and review, not a spike. |
| "This prototype code is good enough to merge" | It was written under prototype constraints — no tests, no error handling. The decision goes to the spec; the code goes to the throwaway branch. |
| "A few tests / a bit of error handling won't hurt" | Polish delays the answer and disguises throwaway code as durable. Skip it. |
