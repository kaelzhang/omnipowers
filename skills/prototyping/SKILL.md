---
name: prototyping
description: Use when asked to prototype, spike, or mock up a throwaway experiment — testing a state model, data shape, or logic, or exploring a page or layout before committing to a design — you MUST write the design question down before any code and let the user deliver the verdict
---

# Prototyping

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- A prototype is throwaway code that answers one design question.
- Code that does not help answer the written question does not belong in the prototype.

## The Question Comes First

You MUST write the design question down — one or two sentences, at the top of the prototype's entry file or in a file next to it — **before writing any prototype code**.

## Pick the Branch

- Question about **state, logic, transitions, data shape, or API feel** → read @logic-prototype.md and apply it.
- Question about **UI, layout, or information hierarchy** → read @ui-prototype.md and apply it.
- The question could genuinely be either → you MUST ask the user which is being asked before building.

## Hygiene Rules

Every prototype, on both branches, MUST obey all five:

1. **Clearly marked throwaway.** Name and place the prototype so a casual reader sees it is a prototype (the word `prototype` in the path or filename). Locate it near the code it is prototyping for, following the host project's existing conventions — never a new top-level structure.
2. **One command to run.** You MUST wire the prototype into the host project's existing task runner (`package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, …) so the user starts it with a single command. The host has no task runner → the single command MUST be stated next to the written question.
3. **In-memory state only.** State lives in memory and resets on restart. You MUST NOT wire the prototype to a real database or persistent store; you MAY touch persistence ONLY when the written question is itself about persistence, and then only against a scratch store whose name marks it as disposable (e.g. `PROTOTYPE-wipe-me`).
4. **Skip all polish.** No tests, no abstractions, no error handling beyond what keeps the prototype runnable.
5. **Surface internal state visibly.** After every action or variant switch, the prototype MUST show the full relevant state (printed or rendered).

## The User Drives

- You MUST hand over a runnable artifact: the run command (or URL) and how to drive it.
- You MUST NOT declare the question answered from your own run; the verdict is the user's observation, and only the user delivers it.
- The user asks for new actions or variants while driving → add them; a prototype evolves freely inside the written question's scope.

## Capture Protocol

The user delivers the verdict → you MUST capture it in two places:

1. **The decision → the design spec.** Record the question, the verdict, and the rationale in the design spec being brainstormed — the durable design document the brainstorming skill produced, wherever this host project keeps such documents. No spec exists yet → the verdict still MUST be written into the host's design documents rather than left in the transcript.
2. **The prototype → a throwaway branch.** Commit the prototype itself to a clearly-named throwaway branch (e.g. `prototype/<question-slug>`) as the primary source behind the decision. **Main stays clean**: no variants, switchers, or terminal shells reach the main branch.

## Red Flags — STOP

Stop on either trigger: you catch yourself thinking the excuse, or the condition is already true.

| Excuse or condition | Reality |
|---|---|
| "The question is obvious — I'll skip writing it down" / no written question exists | Write it first. |
| "It worked when I ran it — question answered" / about to announce the answer off your own run | The verdict is the user's observation; hand the artifact over. |
| "While I'm in here, I'll build the real feature" / the prototype is growing features the written question never asked for | That is unscoped implementation; the real implementation goes through design and review, not a spike. |
| "A few tests / a bit of error handling won't hurt" / adding tests, error handling, or abstractions to throwaway code | Skip it. |
| "This prototype code is good enough to merge" / prototype code is heading into the main branch | The decision goes to the spec; the code goes to the throwaway branch. |
