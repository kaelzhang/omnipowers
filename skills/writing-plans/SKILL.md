---
name: writing-plans
description: Use when asked to plan, break down, or decompose a multi-step feature, spec, design, or ticket before touching code (any "write/create a plan" or "plan this out" request) — you MUST produce a complete, self-contained, bite-sized implementation plan with zero placeholders before any code is written
---

# Writing Plans

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- You MUST write the plan for an implementer assumed to be a skilled developer with zero context for this codebase, questionable taste, near-zero knowledge of this toolset and problem domain, and no command of good test design. The plan MUST supply that knowledge, never assume it.
- The plan MUST document everything that implementer needs, for every task: which files to touch, the actual code, the actual tests, the docs to check, and how to verify.
- You MUST decompose the whole feature into bite-sized tasks.
- DRY, YAGNI, TDD, and frequent commits are REQUIRED throughout.
- At the start of plan-writing you MUST announce: "I'm using the writing-plans skill to create the implementation plan."

## Iron Law

**A PLAN STEP THAT DESCRIBES WHAT TO DO WITHOUT SHOWING HOW IS A PLAN FAILURE.**

- Every code step MUST contain the actual code.
- Every test step MUST contain the actual test.
- Every command step MUST contain the exact command and its expected output.
- You cannot write the concrete content for a step → you MUST resolve the unknown before writing that step, and you MUST NOT defer it into the plan as a placeholder.

## Where to Save the Plan

A plan is **work state**. You MUST resolve its location in this order, stopping at the first that applies:

1. a location the user states in this session;
2. the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `work-state` row;
3. where the host already records the plan for work in progress, when that is unambiguous;
4. the fallback `.omnipowers/plans/YYYY-MM-DD-<feature-name>.md`.

- Resolved to 3 or 4 → you MUST confirm with the user before the project's first plan is written.
- Resolved to 1 or 2 → you MUST NOT ask.
- Parent directories missing → you MUST create them.
- The host already keeps a plan document → you MUST write into it rather than beside it.

## Scope Check

The spec covers multiple independent subsystems → you MUST split it into separate plans, one per subsystem, and MUST state this to the user. Each plan MUST produce working, testable software on its own. You MUST NOT bundle independent subsystems into a single plan.

## File Structure

Before defining any task, you MUST map out which files will be created or modified and what each is responsible for. Decomposition decisions are locked in here.

- Each file MUST have one clear responsibility, with well-defined boundaries and interfaces.
- You SHOULD prefer smaller, focused **code** files over large ones that do too much. Line count is a **smell, not a hard cap**: past a few hundred lines, check a code file's cohesion; past ~1000 it is a strong smell — a genuinely single-responsibility file MAY exceed it, and the host codebase's own norms override any absolute number.
- The length concern applies to **code units judged by responsibility only**. It does NOT apply to **documentation** (Markdown / docs — judged by structure and navigability; split only when length hurts navigation or the document has grown to span separable topics, a looser ~2000-line reference) or to **data / generated / config files** (JSON/YAML data, fixtures, snapshots, lockfiles, migrations, large static maps — you SHOULD NOT split them for length).
- The host project declares a hard file-size policy → that threshold overrides both exemptions for the file types it names.
- Files that change together MUST live together. You MUST split by responsibility, not by technical layer.
- In an existing codebase you MUST follow established patterns, and MUST NOT unilaterally restructure a codebase that uses large files.
- A file you are already modifying has grown unwieldy → you MAY include a split for it in the plan; the split is a separate refactor rather than incidental to the change → it belongs in its own plan.

Each task MUST produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate.

- You MUST fold setup, configuration, scaffolding, and documentation steps into the task whose deliverable needs them.
- You MUST split two tasks apart only where a reviewer could meaningfully reject one while approving its neighbor.
- Each task MUST end with an independently testable deliverable.
- You SHOULD slice tasks vertically (tracer bullets): each task cuts end-to-end through the layers to produce observable behavior, rather than building one horizontal layer at a time.
- You MUST size each task to fit ONE fresh context window — one implementer session holding the brief, the touched files, and the tests at once; a task that cannot is two tasks.
- The work is a wide mechanical refactor (a rename or API migration touching many files) → vertical slicing does not apply; read `@wide-refactors.md` and sequence it expand–contract instead.
- Every task MUST declare its dependency edges with a `Blocked by:` line (task numbers, or `none`). The plan's execution order MUST respect these edges, and a task claimed independent MUST list `Blocked by: none`.

## Bite-Sized Task Granularity

- Each step MUST be a single concrete action — one test, one minimal implementation, one command, or one commit.
- A step that bundles multiple actions MUST be split.
- Steps SHOULD be small enough to finish in a few minutes; exact size varies by action.
- A task's steps MUST follow the TDD cycle, one step each:
  - "Write the failing test"
  - "Run it to confirm it fails"
  - "Implement the minimal code to make the test pass"
  - "Run the tests and confirm they pass"
  - "Commit"

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
git commit -m "feat: add specific feature"
```
````

- File paths MUST be exact.
- The `Interfaces` block MUST list exact signatures.
- The language and runner shown (pytest, Python) are illustrative → you MUST use the host project's actual test runner, language, and commands.
- The commit shape shown is illustrative: committing is the host's convention, not this skill's.
- The host declares a `vcs` convention — a row in its `Omnipowers` section, a contributor guide, a commit standard → every task's commit step MUST follow it, including how files are staged and how the message is formed.

## Red Flags — STOP if you write any of these

Every step MUST contain the actual content an engineer needs. Each pattern below is a plan failure and you MUST NOT write it:

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

After writing the complete plan, you MUST review it against the spec with fresh eyes, running this checklist yourself:

1. **Spec coverage:** For each section or requirement in the spec, you MUST point to a task that implements it, and MUST list and close any gap by adding the missing task.
2. **Placeholder scan:** You MUST search the plan for every pattern in the Red Flags table and fix each occurrence.
3. **Type consistency:** The types, method signatures, and property names used in later tasks MUST match those defined in earlier tasks, and any mismatch MUST be reconciled.

You MUST fix issues inline. A fix adds or renames a task, step, type, or symbol → you MUST re-run checks 2 and 3 over the changed material.

## Execution Handoff

After saving the plan, you MUST report the saved path and present the execution options to the user, then wait for the user's choice. You MUST NOT begin executing the plan without the user's selection.

**Report:** "Plan complete and saved to `<the path you resolved>`. Two execution options:"

1. **Per-task isolated execution** — implement one task at a time, each in a fresh context, with a review gate between tasks. The host environment provides a mechanism for dispatching an isolated worker per task (a subagent or parallel-agent facility) → you MAY use it: one worker per task, with a review of each task's diff before the next task begins. The host provides no such mechanism → you MUST degrade to the portable inline equivalent: implement each task to completion, run its tests, review its diff, and commit before reading the next task; you MUST NOT read ahead into later tasks while implementing the current one.
2. **Inline batch execution** — implement the tasks in this session, pausing at checkpoints for review.

Whichever option is chosen, the implementer MUST execute strictly task-by-task in order, MUST complete the TDD cycle for each task, and MUST commit before moving on.
