---
name: executing-plans
description: Use when you have a written implementation plan (plan.md / a plan file) to execute, implement, or follow — you MUST review it critically first, then execute each step in order and verify at every checkpoint before moving on, stopping the moment you hit a blocker
---

# Executing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Plan Discipline

- When executing a plan → you MUST NOT improvise around the plan or skip its verifications.

## The Process

### Step 1: Load and Review the Plan

- Before taking any action → you MUST read the entire plan file.
- You wrote this plan in this session and ran the review its own skill requires → you MUST NOT repeat that review.
- You did not write this plan in this session or did not run the review its own skill requires → you MUST review it critically and identify every question, gap, ambiguity, or concern.
- Material concern — a concern that could change what gets built, break a step, or invalidate a verification.
- A material concern exists → you MUST raise it with the user and get resolution before starting execution.
- A material concern is unresolved → you MUST NOT begin implementation.
- Cosmetic concern — a typo or a stylistic preference.
- A cosmetic concern exists → you MUST note it.
- A cosmetic concern exists → you MUST NOT block on it.
- No material concern remains → you MUST create a tracked checklist of the plan's steps, one entry per step, using the host's task/todo tool if one exists, otherwise an explicit written checklist you keep updated in your responses; then proceed.

### Step 2: Execute Each Step

- When executing the plan → you MUST work the steps strictly in the order the plan defines them.
- When executing a step → you MUST mark it in progress.
- When executing a step → you MUST follow it exactly as written.
- When executing a step → you MUST NOT merge, reorder, or shortcut steps.
- Step verification — the verification specified by a step, evaluated under `verification-before-completion`.
- A step specifies a verification → you MUST NOT skip it.
- When executing a step → you MUST mark it completed only after its verification has passed.
- The plan instructs you to apply a particular technique, follow another procedure, or invoke a specific capability at a step → you MUST do so at that step rather than substituting your own approach.

### Step 3: Complete the Work

- Every step is complete and every verification has passed → the project's full verification (tests, type checks, linters, build, whatever it defines as its completeness gate) MUST have passed on the final tree, accepting a run already made on that tree under `verification-before-completion`, otherwise running it and reading the output.
- The final verification has not passed on real, observed output → you MUST NOT claim the work is complete.
- The final verification passes → you MUST integrate the branch by invoking the `finishing-a-development-branch` skill (verify, merge into its target branch without a PR unless the host declares a PR workflow, remove every merged worktree).
- That skill is not installed → run the host project's branch-completion process directly: full suite green, working tree clean, then merge or open the PR as the project requires.

## Continuous Execution

- The plan and its goal are clear → you MUST execute in continuous work mode: run every step through to completion without pausing to check in.
- Between steps → you MUST NOT ask anything `confirming-with-the-user` lists under What You MUST NOT Ask.
- Between steps → you MUST NOT stop for an unsolicited progress summary.
- Between steps → you SHOULD narrate at most one short line.
- Before every step is complete → you MUST stop only for a blocker listed under "When to Stop and Ask for Help", surface it with the `confirming-with-the-user` skill (plain-language options + your recommendation), get the decision, then resume continuous execution.

## Isolation

- Isolation unit — the host's unit of work resolved and created by `using-git-worktrees`, including whether anyone needs asking.
- Before any code is written → the work MUST be in the host's isolation unit.

## When to Stop and Ask for Help

- Any of the following occurs → you MUST stop executing immediately:
  - You hit a blocker (missing dependency, failing test, environment problem).
  - A step's instruction is unclear or you do not understand it.
  - The plan has a critical gap that prevents you from starting or continuing.
  - A verification fails after a prior failure.
- After stopping execution and before surfacing the blocker, you MUST leave the work recoverable without this conversation:
  1. Commit the coherent work already finished.
  2. Write the blocker — what is blocked, what you tried, what you need — into the host's work-state document if it keeps one, otherwise into the plan file beside the step that stalled.
- After leaving the work recoverable → you MUST surface the blocker to the user using the `confirming-with-the-user` skill — plain language, concrete options, your recommendation — get the decision, then resume continuous execution.
- When executing a plan → you MUST NOT guess, fabricate a missing step, or force your way past a blocker.
- When executing a plan → you MUST NOT silently downgrade a step to a weaker version that you can complete.

## When to Revisit Earlier Steps

- The user updates the plan in response to your feedback, or the fundamental approach turns out to need rethinking → you MUST return to Step 1 (Load and Review).
- When revisiting Step 1 → you MUST review what changed and whatever the change bears on.
- The plan has materially changed and you have not reviewed what changed and whatever the change bears on → you MUST NOT continue executing against it.
