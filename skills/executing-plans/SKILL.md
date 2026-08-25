---
name: executing-plans
description: Use when you have a written implementation plan (plan.md / a plan file) to execute, implement, or follow — you MUST review it critically first, then execute each step in order and verify at every checkpoint before moving on, stopping the moment you hit a blocker
---

# Executing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- You MUST NOT improvise around the plan or skip its verifications.
- Host provides subagents (isolated worker agents) AND the plan's tasks are largely independent → use the `subagent-driven-development` skill instead.
- Subagents unavailable, OR the plan's steps are tightly coupled and must run in one continuous context → use this skill.

## Iron Law

**EXECUTE THE PLAN STEP BY STEP, VERIFYING AT EACH CHECKPOINT. WHEN BLOCKED, STOP AND ASK — NEVER GUESS.**

## The Process

### Step 1: Load and Review the Plan

1. You MUST read the entire plan file before taking any action.
2. You MUST review it critically and identify every question, gap, ambiguity, or concern.
3. A concern is MATERIAL when it could change what gets built, break a step, or invalidate a verification → you MUST raise it with the user and get resolution BEFORE starting execution, and you MUST NOT begin implementation while it is unresolved.
4. A concern is cosmetic (a typo, a stylistic preference) → you MUST note it and MUST NOT block on it.
5. No material concern remains → you MUST create a tracked checklist of the plan's steps, one entry per step, using the host's task/todo tool if one exists, otherwise an explicit written checklist you keep updated in your responses; then proceed.

### Step 2: Execute Each Step

You MUST work the steps strictly in the order the plan defines them. For each step:

1. Mark it in progress.
2. Follow the step exactly as written. You MUST NOT merge, reorder, or shortcut steps.
3. Run the verification the step specifies. You MUST NOT skip a verification, and you MUST NOT mark a step done on the basis of an unrun or unread verification.
4. Read the verification's actual output to confirm it passed. It failed → treat it as a blocker (see "When to Stop and Ask for Help").
5. Mark the step completed only after its verification has passed.

The plan instructs you to apply a particular technique, follow another procedure, or invoke a specific capability at a step → you MUST do so at that step rather than substituting your own approach.

### Step 3: Complete the Work

Every step is complete and every verification has passed:

1. You MUST run the project's full verification — tests, type checks, linters, build, whatever the project defines as its completeness gate — and read the output.
2. You MUST NOT claim the work is complete until that verification has passed on real, observed output.
3. The final verification passes → you MUST integrate the branch by invoking the `finishing-a-development-branch` skill (verify tests, present the merge / PR / keep / discard options, execute the user's choice, clean up only what you created). That skill is not installed → run the host project's branch-completion process directly: full suite green, working tree clean, then merge or open the PR as the project requires.
4. Report completion with the evidence: which steps were executed and the result of the final verification.

## Continuous Execution

- The plan and its goal are clear → you MUST execute in continuous work mode: run every step through to completion without pausing to check in.
- Step 1 is done and execution has begun → you MUST NOT ask "should I continue?", request permission to proceed, or stop to deliver an unsolicited progress summary between steps.
- Apply best practice to decide what to do next and how to do it, rather than asking the user to sequence or approve the mechanics.
- Between steps you SHOULD narrate at most one short line.
- A genuine blocker (see "When to Stop and Ask for Help") is the only permitted reason to stop before every step is complete → you MUST surface it with the `confirming-with-the-user` skill (plain-language options + your recommendation), get the decision, then resume continuous execution.

## Branch Safety

- You MUST NOT begin implementation on the `main` or `master` branch without explicit user consent.
- The work is not already on a dedicated branch or isolated workspace → you MUST create one, or confirm the existing one, before writing any code.

## When to Stop and Ask for Help

You MUST stop executing immediately when any of the following occurs:

- You hit a blocker (missing dependency, failing test, environment problem).
- A step's instruction is unclear or you do not understand it.
- The plan has a critical gap that prevents you from starting or continuing.
- A verification fails repeatedly.

Then, before surfacing it, you MUST leave the work recoverable without this conversation:

1. Commit the coherent work already finished.
2. Write the blocker — what is blocked, what you tried, what you need — into the host's work-state document if it keeps one, otherwise into the plan file beside the step that stalled.

Then you MUST surface the blocker to the user using the `confirming-with-the-user` skill — plain language, concrete options, your recommendation — get the decision, then resume continuous execution.

You MUST NOT guess, fabricate a missing step, or force your way past a blocker. You MUST NOT silently downgrade a step to a weaker version that you can complete.

## When to Revisit Earlier Steps

You MUST return to Step 1 (Load and Review) when:

- The user updates the plan in response to your feedback.
- The fundamental approach turns out to need rethinking.

A revised plan MUST be re-reviewed from the top before execution resumes. You MUST NOT continue executing against a plan that has materially changed without re-reviewing it.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "Reviewing the whole plan first wastes time." | Read the entire plan and review it critically before any action. |
| "I'll batch these steps to save time." | Execute one step, verify, then the next. |
| "The verification probably passes — I'll mark it done." / "Running every verification slows me down." | Run the verification and read its output before marking the step done. |
| "This step is unclear, but I think it means X." / "Asking the user about this small ambiguity is annoying." | Stop and ask the user. |
| "The plan says X, but Y is better — I'll do Y." / "I understand the intent, so the exact steps don't matter." | Raise the concern with the user; do not silently substitute. |
| "I'll start on main, just this once." | Get explicit consent or create a branch first. |
| "The plan didn't cover this case, so I'll invent a step." / "I can fix the plan's gap myself without asking." | Stop and ask; the plan needs updating. |
| "Tests fail, but it's probably flaky — I'll move on." / "It's faster to keep going than to stop at this blocker." | Stop, investigate, and ask if you cannot resolve it. |

## Checklist

Before reporting the work complete, confirm:

- [ ] I read the entire plan and reviewed it critically before starting.
- [ ] I raised every concern with the user and resolved them before execution.
- [ ] I created a tracked checklist of the plan's steps (host task/todo tool, or an explicit written checklist kept updated in my responses).
- [ ] I am on a dedicated branch/workspace (not `main`/`master` without consent).
- [ ] I executed every step in order, exactly as written.
- [ ] I ran and read the output of every step's verification before marking it done.
- [ ] I worked in continuous mode — no permission-to-proceed pauses between steps; I stopped only for a real blocker, surfaced via confirming-with-the-user.
- [ ] I never guessed past a blocker — I stopped and asked when unclear.
- [ ] I ran the project's full verification at the end and read its output.
- [ ] I integrated the work (finishing-a-development-branch, or the host's branch-completion process).
- [ ] My completion report cites the actual verification result as evidence.
