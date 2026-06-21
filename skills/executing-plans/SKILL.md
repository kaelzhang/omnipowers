---
name: executing-plans
description: Use when you have a written implementation plan to execute — you MUST review it critically first, then execute each step in order and verify at every checkpoint before moving on, stopping the moment you hit a blocker
---

# Executing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A written plan exists. Your job is to load it, review it critically, execute every step in order, verify at each checkpoint, and report when the work is complete. You MUST NOT improvise around the plan or skip its verifications.

## Iron Law

**EXECUTE THE PLAN STEP BY STEP, VERIFYING AT EACH CHECKPOINT. WHEN BLOCKED, STOP AND ASK — NEVER GUESS.**

A plan is a sequence of bite-sized steps, each with a verification. The plan only holds if every step is executed in order and every verification passes before the next step begins. Skipping a verification, batching steps, or guessing past a blocker breaks that contract and invalidates everything downstream.

## The Process

### Step 1: Load and Review the Plan

1. You MUST read the entire plan file before taking any action.
2. You MUST review it critically and identify every question, gap, ambiguity, or concern.
3. If you have ANY concern, you MUST raise it with the user and get resolution BEFORE starting execution. You MUST NOT begin implementation while a material concern is unresolved.
4. If you have no concerns, you MUST create a tracked checklist of the plan's steps (one entry per step) and proceed.

### Step 2: Execute Each Step

You MUST work the steps strictly in the order the plan defines them. For each step:

1. Mark it in progress.
2. Follow the step exactly as written. Plans are deliberately broken into small steps — you MUST NOT merge, reorder, or shortcut them.
3. Run the verification the step specifies. You MUST NOT skip a verification, and you MUST NOT mark a step done on the basis of an unrun or unread verification.
4. Confirm the verification passed by reading its actual output. If it failed, treat it as a blocker (see "When to Stop and Ask").
5. Mark the step completed only after its verification has passed.

If the plan instructs you to apply a particular technique, follow another procedure, or invoke a specific capability at a step, you MUST do so at that step rather than substituting your own approach.

### Step 3: Complete the Work

After every step is complete and every verification has passed:

1. You MUST run the project's full verification (tests, type checks, linters, build — whatever the project defines as its completeness gate) and read the output.
2. You MUST NOT claim the work is complete until that verification has passed on real, observed output.
3. Report completion with the evidence: which steps were executed and the result of the final verification.

## Branch Safety

You MUST NOT begin implementation on the `main` or `master` branch without explicit user consent. If the work is not already on a dedicated branch or isolated workspace, you MUST create one (or confirm the existing one) before writing any code.

## When to Stop and Ask for Help

You MUST stop executing immediately when any of the following occurs:

- You hit a blocker (missing dependency, failing test, environment problem).
- A step's instruction is unclear or you do not understand it.
- The plan has a critical gap that prevents you from starting or continuing.
- A verification fails repeatedly.

When stopped, you MUST ask the user for clarification. You MUST NOT guess, fabricate a missing step, or force your way past a blocker. You MUST NOT silently downgrade a step to a weaker version that you can complete.

## When to Revisit Earlier Steps

You MUST return to Step 1 (Load and Review) when:

- The user updates the plan in response to your feedback.
- The fundamental approach turns out to need rethinking.

A revised plan MUST be re-reviewed from the top before execution resumes. You MUST NOT continue executing against a plan that has materially changed without re-reviewing it.

## Red Flags — STOP if you catch yourself

| Red flag | What it means | What you MUST do instead |
| --- | --- | --- |
| "I'll batch these steps to save time." | You are abandoning step-by-step verification. | Execute one step, verify, then the next. |
| "The verification probably passes — I'll mark it done." | You are asserting success without evidence. | Run the verification and read its output first. |
| "This step is unclear, but I think it means X." | You are guessing past ambiguity. | Stop and ask the user. |
| "The plan says X, but Y is better — I'll do Y." | You are improvising around the plan. | Raise the concern with the user; do not silently substitute. |
| "I'll start on main, just this once." | You are skipping branch safety. | Get explicit consent or create a branch first. |
| "The plan didn't cover this case, so I'll invent a step." | You are filling a critical gap by guessing. | Stop and ask; the plan needs updating. |
| "Tests fail, but it's probably flaky — I'll move on." | You are forcing through a blocker. | Stop, investigate, and ask if you cannot resolve it. |

## Rationalizations — none of these are valid

| Rationalization | Reality |
| --- | --- |
| "Reviewing the whole plan first wastes time." | An unreviewed plan hides the gaps that cost the most later. Review is non-negotiable. |
| "Running every verification slows me down." | Skipped verifications are how silent breakage compounds. Every step's verification is REQUIRED. |
| "I understand the intent, so the exact steps don't matter." | The steps are the contract. Deviating invalidates the plan's guarantees. |
| "Asking the user about this small ambiguity is annoying." | A wrong guess costs far more than a question. When unclear, ask. |
| "I can fix the plan's gap myself without asking." | Inventing steps means executing a plan no one reviewed. Surface the gap instead. |
| "It's faster to keep going than to stop at this blocker." | Forcing past a blocker produces work built on a broken foundation. Stop. |

## Checklist

Before reporting the work complete, confirm:

- [ ] I read the entire plan and reviewed it critically before starting.
- [ ] I raised every concern with the user and resolved them before execution.
- [ ] I created a tracked checklist of the plan's steps.
- [ ] I am on a dedicated branch/workspace (not `main`/`master` without consent).
- [ ] I executed every step in order, exactly as written.
- [ ] I ran and read the output of every step's verification before marking it done.
- [ ] I never guessed past a blocker — I stopped and asked when unclear.
- [ ] I ran the project's full verification at the end and read its output.
- [ ] My completion report cites the actual verification result as evidence.
