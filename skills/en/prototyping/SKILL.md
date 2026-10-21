---
name: prototyping
description: Use when asked to prototype, spike, or mock up a throwaway experiment — testing a state model, data shape, or logic, or exploring a page or layout before committing to a design — you MUST write the design question down before any code and let the user deliver the verdict
---

# Prototyping

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Definitions

Prototype — throwaway code that answers one written design question.

## The Question Comes First

Before writing any prototype code → you MUST write the design question in one or two sentences at the top of the prototype's entry file or in a file next to it.

## Pick the Branch

- Question about **state, logic, transitions, data shape, or API feel** → read @logic-prototype.md and apply it.
- Question about **UI, layout, or information hierarchy** → read @ui-prototype.md and apply it.
- The question could belong to either branch listed above → you MUST ask the user which is being asked before building.

## Hygiene Rules

For every prototype on either branch, you MUST:

1. **Clearly marked throwaway.** Put the word `prototype` in the path or filename. Locate the prototype near the code it is prototyping for, following the host project's existing conventions; do not create a new top-level structure.
2. **One command to run.** When the host project has a task runner → you MUST wire the prototype into that task runner (`package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, …) with a single command to start it. When the host has no task runner → the single command MUST be stated next to the written question.
3. **In-memory state only.** Keep state in memory and reset it on restart. For prototype storage → you MUST NOT wire the prototype to a real database or persistent store. When the written question is itself about persistence → you MAY touch persistence ONLY against a scratch store whose name marks it as disposable.
4. **Skip all polish.** Omit tests, abstractions, and error handling beyond what keeps the prototype runnable.
5. **Surface internal state visibly.** After every action or variant switch → the prototype MUST show the full relevant state, printed or rendered.

## The User Drives

- At handover → you MUST provide a runnable artifact, its run command or URL, and instructions for driving it.
- When declaring whether the question is answered → you MUST NOT declare it answered from your own run.

Verdict — the user's observation, delivered only by the user.

## Capture Protocol

When the user delivers the verdict → you MUST capture it in two places:

1. **The decision → the design spec.** Record the question, verdict, and rationale in the design spec being brainstormed: the durable design document produced by the brainstorming skill, wherever the host project keeps such documents. When no spec exists yet → the verdict still MUST be written into the host's design documents.
2. **The prototype → a throwaway branch.** Commit the prototype itself to a clearly named throwaway branch as the primary source behind the decision. Keep variants, switchers, and terminal shells off the main branch.
