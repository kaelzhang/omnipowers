---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code — you MUST produce a complete, self-contained, bite-sized implementation plan with zero placeholders before any code is written
---

# Writing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A plan is written for an implementer who has zero context for this codebase and questionable taste. The plan MUST document everything that implementer needs: which files to touch for each task, the actual code, the actual tests, the docs to check, and how to verify. The whole feature MUST be decomposed into bite-sized tasks. DRY, YAGNI, TDD, and frequent commits are REQUIRED throughout.

The implementer MUST be assumed to be a skilled developer who knows almost nothing about this toolset or problem domain, and who does not know good test design well. The plan therefore MUST supply, not assume, that knowledge.

At the start of plan-writing, you MUST announce: "I'm using the writing-plans skill to create the implementation plan."

## Iron Law

**A PLAN STEP THAT DESCRIBES WHAT TO DO WITHOUT SHOWING HOW IS A PLAN FAILURE.**

Every code step MUST contain the actual code. Every test step MUST contain the actual test. Every command step MUST contain the exact command and its expected output. If you cannot write the concrete content for a step, you MUST resolve the unknown before writing the step — you MUST NOT defer it into the plan as a placeholder.

## Where to Save the Plan

Plans MUST be saved under the host project at `.omnipowers/plans/YYYY-MM-DD-<feature-name>.md`. If the user specifies a different plan location, that preference overrides this default. You MUST create any missing parent directories before writing.

## Scope Check

If the spec covers multiple independent subsystems, you MUST split it into separate plans — one per subsystem — and state this to the user. Each plan MUST produce working, testable software on its own. You MUST NOT bundle independent subsystems into a single plan.

## File Structure

Before defining any task, you MUST map out which files will be created or modified and what each is responsible for. Decomposition decisions are locked in here.

- Each file MUST have one clear responsibility, with well-defined boundaries and interfaces.
- You MUST prefer smaller, focused files over large files that do too much. Reasoning and edits are more reliable when a file fits in context at once.
- Files that change together MUST live together. You MUST split by responsibility, not by technical layer.
- In an existing codebase, you MUST follow established patterns. You MUST NOT unilaterally restructure a codebase that uses large files. If a file you are already modifying has grown unwieldy, you MAY include a split for that file in the plan — this is a judgment call because it depends on whether the split is incidental to the change or a separate refactor that belongs in its own plan.

This structure informs task decomposition. Each task MUST produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate. When drawing task boundaries you MUST fold setup, configuration, scaffolding, and documentation steps into the task whose deliverable needs them. You MUST split two tasks apart only where a reviewer could meaningfully reject one while approving its neighbor. Each task MUST end with an independently testable deliverable.

## Bite-Sized Task Granularity

Each step MUST be a single concrete action — one test, one minimal implementation, one command, or one commit. A step that bundles multiple actions MUST be split, because a step the implementer cannot complete and check off in one motion hides progress and defeats the checkbox tracking. Steps SHOULD be small enough to finish in a few minutes; the exact size varies by action, so this is a guideline, not a hard threshold. A task's steps MUST follow the TDD cycle:

- "Write the failing test" — one step
- "Run it to confirm it fails" — one step
- "Implement the minimal code to make the test pass" — one step
- "Run the tests and confirm they pass" — one step
- "Commit" — one step

## Plan Document Header

Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

> **For implementers:** Implement this plan task-by-task. Complete and verify each task before starting the next. Steps use checkbox (`- [ ]`) syntax for tracking; check each off only after the step is done — for a command step, after the command has run and produced the expected output; for a code or test step, after the content is written as specified.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

Values in Global Constraints MUST be copied verbatim from the spec. You MUST NOT paraphrase a version floor, a name, or a copy string.

## Task Structure

Every task MUST follow this structure:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

File paths MUST be exact. The `Interfaces` block MUST list exact signatures, because the implementer of a task sees only their own task and learns neighboring names and types from this block alone. The example language (pytest, Python) is illustrative — you MUST use the host project's actual test runner, language, and commands.

## No Placeholders

Every step MUST contain the actual content an engineer needs. The following are plan failures and you MUST NOT write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases" — the specific handling MUST be shown
- "Write tests for the above" without the actual test code
- "Similar to Task N" — the code MUST be repeated, because the implementer may read tasks out of order
- A step that describes what to do without showing how — code steps MUST include the code block
- A reference to any type, function, or method not defined in any task

## Red Flags — STOP if you write any of these

| Red flag in your plan | Why it fails | Required fix |
|---|---|---|
| "TBD" / "TODO" / "fill in later" | The implementer cannot execute an unknown | Resolve it now; write the concrete content |
| "Add appropriate error handling" | "Appropriate" is undefined to a zero-context implementer | Show the exact error-handling code |
| "Similar to Task N" | Tasks may be read out of order | Repeat the full code |
| Function used in a later task, defined nowhere | Implementer hits an undefined symbol | Define it in an earlier task's `Produces` and body |
| Name differs between tasks (`clearLayers` vs `clearFullLayers`) | Silent integration bug | Make the names identical everywhere |
| Step says what but not how | Not executable without invention | Add the code block or exact command |
| Multiple independent subsystems in one plan | No single working deliverable | Split into one plan per subsystem |

## Rationalizations — all are forbidden

| Rationalization | Reality |
|---|---|
| "The implementer can figure out the error handling" | The implementer has zero context and questionable taste by assumption — they cannot. Show it. |
| "I'll just write 'similar to Task 3' to save space" | Tasks are read out of order. Repeat the code. |
| "This step is obvious, no command needed" | If it is obvious, writing the command costs nothing. Write it. |
| "I can leave the exact path vague" | Vague paths produce wrong edits. Every path MUST be exact. |
| "It's one big task, splitting is overhead" | A task that cannot be reviewed independently hides defects. Right-size it. |
| "I'll resolve this unknown during implementation" | Unknowns resolved mid-implementation derail the TDD cycle. Resolve before writing the step. |

## Self-Review

After writing the complete plan, you MUST review it against the spec with fresh eyes. This is a checklist you run yourself.

1. **Spec coverage:** For each section or requirement in the spec, you MUST point to a task that implements it. You MUST list and close any gap by adding the missing task.
2. **Placeholder scan:** You MUST search the plan for every pattern in "No Placeholders" and the Red Flags table, and fix each occurrence.
3. **Type consistency:** The types, method signatures, and property names used in later tasks MUST match those defined in earlier tasks. A function named `clearLayers()` in one task and `clearFullLayers()` in another is a bug and MUST be reconciled.

You MUST fix issues inline. If a fix adds or renames a task, step, type, or symbol, you MUST re-run checks 2 and 3 over the changed material, because a fix can itself introduce a new placeholder or a new name mismatch that a single pass will not catch.

## Execution Handoff

After saving the plan, you MUST report the saved path and present the execution options to the user, then wait for the user's choice. You MUST NOT begin executing the plan without the user's selection.

**Report:** "Plan complete and saved to `.omnipowers/plans/<filename>.md`. Two execution options:"

1. **Per-task isolated execution** — implement one task at a time, each in a fresh context, with a review gate between tasks. If the host environment provides a mechanism for dispatching an isolated worker per task (for example, a subagent or parallel-agent facility), you MAY use it: one worker per task, with a review of each task's diff before the next task begins. If the host provides no such mechanism, you MUST degrade gracefully to the portable inline equivalent — implement each task to completion, run its tests, review its diff, and commit, before reading the next task; you MUST NOT read ahead into later tasks while implementing the current one, which preserves the zero-context-per-task discipline.
2. **Inline batch execution** — implement the tasks in this session, pausing at checkpoints for review.

Whichever option is chosen, the implementer MUST execute strictly task-by-task in order, MUST complete the TDD cycle for each task, and MUST commit before moving on.
