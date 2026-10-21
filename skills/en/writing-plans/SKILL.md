---
name: writing-plans
description: Use when asked to plan, break down, or decompose a multi-step feature, spec, design, or ticket before touching code (any "write/create a plan" or "plan this out" request) — you MUST produce a complete, self-contained, bite-sized implementation plan with zero placeholders before any code is written
---

# Writing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- When writing a plan → you MUST address a skilled developer with zero codebase context, questionable taste, near-zero toolset and problem-domain knowledge, and no command of good test design.
- For that implementer → the plan MUST supply the codebase, toolset, problem-domain, and test-design knowledge without assuming it.
- For every plan → the plan MUST document everything that implementer needs, for every task: which files to touch, the actual code, the actual tests, the docs to check, and how to verify.
- When planning a feature → you MUST decompose the whole feature into bite-sized tasks.
- Throughout planning and execution → DRY, YAGNI, TDD, and frequent commits are REQUIRED.
- At the start of plan-writing → you MUST announce: "I'm using the writing-plans skill to create the implementation plan."

## Iron Law

- For every code step → the step MUST contain the actual code.
- For every test step → the step MUST contain the actual test.
- For every command step → the step MUST contain the exact command and its expected output.
- You cannot write the concrete content for a step → you MUST resolve the unknown before writing that step.
- You cannot write the concrete content for a step → you MUST NOT defer it into the plan as a placeholder.

## Where to Save the Plan

Plan — a `work-state` artifact with location resolution governed by `using-omnipowers` and fallback `.omnipowers/plans/YYYY-MM-DD-<feature-name>.md`.
- Resolved to 1 or 2 → you MUST NOT ask.
- Parent directories missing → you MUST create them.
- The host already keeps a plan document → you MUST write into it rather than beside it.

## Scope Check

- The spec covers multiple independent subsystems → you MUST split it into separate plans, one per subsystem, and MUST state this to the user.
- The spec covers multiple independent subsystems → each plan MUST produce working, testable software on its own.
- The spec covers multiple independent subsystems → you MUST NOT bundle them into a single plan.

## File Structure

Before defining any task → you MUST map out which files will be created or modified and what each is responsible for.

- For each file → the file MUST have one clear responsibility, with well-defined boundaries and interfaces.
- File-size limits — the rule owned by `committing-work`.
- Files change together → they MUST live together.
- When splitting files → you MUST split by responsibility, not by technical layer.
- When planning in an existing codebase → you MUST follow established patterns.
- The existing codebase uses large files → you MUST NOT unilaterally restructure it.
- A file you are already modifying has grown unwieldy → you MAY include a split for it in the plan.

For each task → the task MUST produce self-contained changes that make sense independently.

## Task Right-Sizing

Task — the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate.

- When defining tasks → you MUST fold setup, configuration, scaffolding, and documentation steps into the task whose deliverable needs them.
- When separating tasks → you MUST split two tasks apart only where a reviewer could meaningfully reject one while approving its neighbor.
- For each task → the task MUST end with an independently testable deliverable.
- When defining tasks → you SHOULD slice tasks vertically (tracer bullets): each task cuts end-to-end through the layers to produce observable behavior, rather than building one horizontal layer at a time.
- When defining tasks → you MUST size each task to fit ONE fresh context window: one implementer session holding the brief, the touched files, and the tests at once.
- The work is a wide mechanical refactor (a rename or API migration touching many files) → vertical slicing does not apply; read `@wide-refactors.md` and sequence it expand–contract instead.
- For every task → the task MUST declare its dependency edges with a `Blocked by:` line (task numbers, or `none`).
- When ordering tasks → the plan's execution order MUST respect the declared dependency edges.
- A task is claimed independent → it MUST list `Blocked by: none`.

## Bite-Sized Task Granularity

- For each step → the step MUST be a single concrete action — one test, one minimal implementation, one command, or one commit.
- A step bundles multiple actions → it MUST be split.
- When sizing steps → steps SHOULD be small enough to finish in a few minutes.
- For each task → its steps MUST follow the TDD cycle, one step each:
  - "Write the failing test"
  - "Run it to confirm it fails"
  - "Implement the minimal code to make the test pass"
  - "Run the tests and confirm they pass"
  - "Commit"

## Plan Document Header

For every plan → the plan MUST start with this header:

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

- When populating Global Constraints → values MUST be copied verbatim from the spec.
- When copying a version floor, a name, or a copy string → you MUST NOT paraphrase it.

## Task Structure

For every task → the task MUST follow this structure:

````markdown
### Task N: [Component Name]

**Blocked by:** [task numbers this task depends on, or `none`]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types]

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
git commit -m "feat: add specific feature" -- tests/path/test.py src/path/file.py
```
````

- When specifying file paths → the paths MUST be exact.
- For each task → the `Interfaces` block MUST list exact signatures.
- When selecting the test runner, language, and commands → you MUST use the host project's actual test runner, language, and commands.
- Commit shape — the host's convention.
- The host declares a `vcs` convention — a row in its `Omnipowers` section, a contributor guide, a commit standard → every task's commit step MUST follow it, including how files are staged and how the message is formed.

## Red Flags

- For every step → the step MUST contain the actual content an engineer needs.
- When writing a plan → you MUST NOT write any pattern in this table:

| Red flag in your plan | Required fix |
|---|---|
| "TBD" / "TODO" / "implement later" / "fill in details" | Resolve it now; write the concrete content |
| "Add appropriate error handling" / "add validation" / "handle edge cases" | Show the exact handling code |
| "Write tests for the above" without the actual test code | Write the actual test code |
| "Similar to Task N" | Repeat the full code |
| Step says what but not how | Add the code block or exact command |
| A type, function, or method referenced but defined in no task | Define it in an earlier task's `Produces` and body |
| Name differs between tasks (`clearLayers` vs `clearFullLayers`) | Make the names identical everywhere |
| A vague file path | Write the exact path |
| A task too large to review independently | Right-size it |
| Multiple independent subsystems in one plan | Split into one plan per subsystem |

## Self-Review

After writing the complete plan → you MUST review it against the spec with fresh eyes, running this checklist yourself:

1. **Spec coverage:** For each section or requirement in the spec → you MUST point to a task that implements it, and MUST list and close any gap by adding the missing task.
2. **Placeholder scan:** During self-review → you MUST search the plan for every pattern in the Red Flags table and fix each occurrence.
3. **Type consistency:** During self-review → the types, method signatures, and property names used in later tasks MUST match those defined in earlier tasks.
   A mismatch is found → it MUST be reconciled.

Self-review finds issues → you MUST fix them inline. A fix adds or renames a task, step, type, or symbol → you MUST re-run checks 2 and 3 over the changed material.

## Execution Handoff

- After saving the plan → you MUST report the saved path and present the execution options to the user, then wait for the user's choice.
- The user has not selected an execution option → you MUST NOT begin executing the plan.

**Report template:** "Plan complete and saved to `<the path you resolved>`. Two execution options:"

1. **Per-task isolated execution** — implementation of one task at a time, each in a fresh context, with a review gate between tasks.
2. **Inline batch execution** — implementation of the tasks in this session, with pauses at checkpoints for review.

- The user selects per-task isolated execution and the host environment provides a mechanism for dispatching an isolated worker per task (a subagent or parallel-agent facility) → you MAY use it: one worker per task, with a review of each task's diff before the next task begins.
- The user selects per-task isolated execution and the host provides no such mechanism → you MUST degrade to the portable inline equivalent: implement each task to completion, run its tests, review its diff, and commit before reading the next task.
- The user selects per-task isolated execution and the host provides no such mechanism → you MUST NOT read ahead into later tasks while implementing the current one.

After the user selects either execution option → the implementer MUST execute strictly task-by-task in order, MUST complete the TDD cycle for each task, and MUST commit before moving on.
