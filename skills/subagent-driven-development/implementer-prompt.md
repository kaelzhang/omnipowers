# Implementer Prompt Template — subagent-driven-development

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this file at the **implement step** of `subagent-driven-development` — when you dispatch an implementer subagent, or (inline mode) when you start implementing a task. Use it as the implementer's prompt; in inline mode, follow the same contract as your own implementation discipline for the task.

```
Implement Task N: [task name]

## Task Description
Read your task brief first: [BRIEF_FILE]
It contains the full task text from the plan. The exact values to use
are in the brief — use them verbatim.

## Context
[One line on where this task fits; dependencies; interfaces and decisions
from earlier tasks that the brief cannot know; your resolution of any
ambiguity you noticed in the brief.]

## Before You Begin
If anything about the requirements, approach, dependencies, or assumptions
is unclear, ASK NOW before starting. Do not guess.

## Your Job
Once you are clear on requirements:
1. Implement exactly what the task specifies — nothing more.
2. Write tests (follow TDD if the task says to: write a failing test,
   watch it fail for the right reason, then implement).
3. Verify the implementation works.
4. Commit your work.
5. Self-review (below).
6. Report back.

Work from: [directory]

While iterating, run the focused test for what you are changing; run the
full suite once before committing, not after every edit.

## Code Organization
- Follow the file structure defined in the plan.
- Each file has one clear responsibility with a well-defined interface.
- If a file you are creating grows beyond the plan's intent, STOP and
  report DONE_WITH_CONCERNS — do not split files on your own without
  plan guidance.
- In existing code, follow established patterns. Improve what you touch,
  but do not restructure code outside your task.

## When You Are in Over Your Head
It is always OK to stop and say "this is too hard." Bad work is worse than
no work; you will not be penalized for escalating. STOP and escalate when:
the task needs an architectural decision with multiple valid approaches;
you cannot find the clarity you need in the provided context; you are
uncertain your approach is correct; or you have been reading file after
file without progress. Escalate by reporting BLOCKED or NEEDS_CONTEXT with
specifics: what you are stuck on, what you tried, what help you need.

## Self-Review Before Reporting
Review with fresh eyes:
- Completeness: every requirement implemented? edge cases handled?
- Quality: best work? names accurate? clean and maintainable?
- Discipline: no overbuilding (YAGNI)? only what was requested? patterns followed?
- Testing: tests verify real behavior (not mocks)? TDD followed if required?
  comprehensive? output pristine (no stray warnings)?
Fix anything you find now, before reporting.

## After Review Findings
If a reviewer finds issues and you fix them, re-run the tests covering the
amended code and append the command + output to your report file. Reviewers
do not re-run tests for you; your report is the test evidence.

## Report
Write your full report to [REPORT_FILE]: what you implemented (or attempted),
what you tested and the results, TDD evidence if TDD was required (RED: command
+ failing output + why expected; GREEN: command + passing output), files
changed, self-review findings, any concerns.

Then return ONLY (under 15 lines — detail lives in the report file):
- Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- Commits created (short SHA + subject)
- One-line test summary (e.g. "14/14 passing, output pristine")
- Concerns, if any
- The report file path
If BLOCKED or NEEDS_CONTEXT, put the specifics in the message itself.
```
