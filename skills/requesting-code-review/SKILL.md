---
name: requesting-code-review
description: Use when work is complete, a major feature is implemented, a plan task is finished, or before merging — you MUST get a fresh-eyes review of the finished work against its requirements before proceeding.
---

# Requesting Code Review

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

A fresh-eyes review catches issues before they cascade into more work. The reviewer MUST evaluate only the finished work product against its requirements — never your reasoning, your thought process, or your session history. This keeps the review focused on what was actually produced and keeps a self-audit honest by forcing an independent second pass.

**Iron Law: You MUST NOT claim work is reviewed without an independent pass over the diff against its stated requirements.** Re-reading your own justification is not a review.

## Core Principle

Review early, review often. A review at each natural checkpoint costs minutes; an undetected defect that compounds across later work costs far more.

## When to Request Review

You MUST request review:
- After completing a discrete task in a multi-task plan.
- After completing a major feature.
- Before merging to the main branch.

You SHOULD request review (judgment — depends on the cost and risk of the change):
- When stuck and a fresh perspective would help.
- Before a refactor, to establish a baseline.
- After fixing a complex bug.

You MUST NOT skip review on the grounds that the change "is simple," "is small," or "obviously works." Those are exactly the changes where a self-audit is most likely to miss something.

## How to Request

### 1. Capture the git range

The captured range MUST cover the entire body of work under review, not just the latest commit. For a feature-complete or pre-merge review (work that spans multiple commits), you MUST base the range on the merge-base with the main branch:

```bash
BASE_SHA=$(git merge-base HEAD <main-branch>)   # feature / pre-merge review
HEAD_SHA=$(git rev-parse HEAD)
```

Use `BASE_SHA=$(git rev-parse HEAD~1)` ONLY for a single-task checkpoint where exactly one commit is under review. Scoping the range to one commit when the work spans several silently leaves most of the diff unreviewed, so an agent can satisfy the Iron Law's letter while the bulk of the change is never seen.

You MUST review a committed range. If the work is uncommitted, you MUST commit it first (or stash and review the stash) so the reviewer sees a stable, well-defined diff.

### 2. Run the review

A reviewer MUST receive a precisely scoped brief — the diff range, what was built, and what it was supposed to do — and nothing about how you arrived at the result.

**Primary path — dispatch a reviewer subagent.** If the host provides a subagent / task-dispatch capability, you MUST dispatch one independent reviewer agent using the brief in [§ Reviewer Brief](#reviewer-brief) below, with the placeholders filled in. The subagent MUST run read-only (see the brief).

**Fallback path — review in a fresh independent pass yourself.** If the host provides no subagent capability, you MUST perform the review yourself as a deliberate, separate pass. To keep it independent you MUST:
- Treat the diff as if written by someone else. You MUST work only from the requirements and the diff, and MUST NOT rely on your memory of why you wrote each line.
- Read the entire diff (`git diff $BASE_SHA..$HEAD_SHA`) top to bottom before forming any conclusion.
- Apply the full [§ Reviewer Brief](#reviewer-brief) checklist and produce its exact output format.
- Keep the pass read-only: you MUST NOT edit code during the review. Record findings first, then act on them in step 3.

The fallback MUST NOT be a token gesture. A self-review that merely confirms your prior intent violates the Iron Law.

### 3. Act on feedback

- You MUST fix every Critical issue before proceeding.
- You MUST fix every Important issue before proceeding to any further implementation work (the next task, a refactor, or a merge). Deferring it past the current checkpoint leaves the defect to compound into later work.
- You MUST record Minor issues (e.g. in the task notes or an issue tracker) rather than silently dropping them.
- If the reviewer is wrong, you MUST push back with specific technical reasoning — cite the code, the tests, or the requirement that proves the point. You MUST NOT accept an incorrect finding just to close it out, and you MUST NOT dismiss a finding without that reasoning.

## Reviewer Brief

This is the exact brief to give the reviewer (subagent) or to apply to yourself (fallback). Fill every placeholder before use:
- `{DESCRIPTION}` — a brief summary of what was built.
- `{PLAN_OR_REQUIREMENTS}` — what it was supposed to do (the plan text, task text, or requirements).
- `{BASE_SHA}` — the starting commit.
- `{HEAD_SHA}` — the ending commit.

```
You are a Senior Code Reviewer with expertise in software architecture,
design patterns, and best practices. Your job is to review completed work
against its plan or requirements and identify issues before they cascade.

## What Was Implemented

{DESCRIPTION}

## Requirements / Plan

{PLAN_OR_REQUIREMENTS}

## Git Range to Review

Base: {BASE_SHA}
Head: {HEAD_SHA}

    git diff --stat {BASE_SHA}..{HEAD_SHA}
    git diff {BASE_SHA}..{HEAD_SHA}

## Read-Only Review

This review is read-only on this checkout. You MUST NOT mutate the working
tree, the index, HEAD, or branch state in any way. Use `git show`, `git diff`,
and `git log` to inspect history. If you need a working copy of a different
revision, check it out into a separate temporary directory
(e.g. `git worktree add /tmp/review-{HEAD_SHA} {HEAD_SHA}`) — you MUST NOT
move HEAD on this checkout.

## What to Check

Plan alignment:
- Does the implementation match the plan / requirements?
- Are deviations justified improvements, or problematic departures?
- Is all planned functionality present?

Code quality:
- Clean separation of concerns?
- Proper error handling?
- Type safety where applicable?
- DRY without premature abstraction?
- Edge cases handled?

Architecture:
- Sound design decisions?
- Reasonable scalability and performance?
- Security concerns?
- Integrates cleanly with surrounding code?

Testing:
- Tests verify real behavior, not mocks?
- Edge cases covered?
- Integration tests where they matter?
- All tests passing?

Production readiness:
- Migration strategy if schema changed?
- Backward compatibility considered?
- Documentation complete?
- No obvious bugs?

## Calibration

Categorize issues by actual severity. Not everything is Critical.
Acknowledge what was done well before listing issues — accurate praise
helps the implementer trust the rest of the feedback. If you find
significant deviations from the plan, flag them specifically so the
implementer can confirm whether the deviation was intentional. If you find
issues with the plan itself rather than the implementation, say so.

## Output Format

### Strengths
[What's well done? Be specific.]

### Issues

#### Critical (Must Fix)
[Bugs, security issues, data loss risks, broken functionality]

#### Important (Should Fix)
[Architecture problems, missing features, poor error handling, test gaps]

#### Minor (Nice to Have)
[Code style, optimization opportunities, documentation polish]

For each issue:
- File:line reference
- What's wrong
- Why it matters
- How to fix (if not obvious)

### Recommendations
[Improvements for code quality, architecture, or process]

### Assessment

Ready to merge? [Yes | No | With fixes]

Reasoning: [1-2 sentence technical assessment]

## Critical Rules

DO:
- Categorize by actual severity
- Be specific (file:line, not vague)
- Explain WHY each issue matters
- Acknowledge strengths
- Give a clear verdict

DON'T:
- Say "looks good" without checking
- Mark nitpicks as Critical
- Give feedback on code you didn't actually read
- Be vague ("improve error handling")
- Avoid giving a clear verdict
```

## Example

```
[Just completed Task 2: Add verification function]

Capture the range:
  BASE_SHA=a7981ec   (end of Task 1)
  HEAD_SHA=3df7661   (end of Task 2)

Run the review with the brief:
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from the deployment plan
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

Review returns:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: With fixes

Action:
  Fix progress indicators (Important) before proceeding.
  Record the magic-number cleanup (Minor).
  Continue to Task 3.
```

## Example Review Output

```
### Strengths
- Clean database schema with proper migrations (db.ts:15-42)
- Comprehensive test coverage (18 tests, all edge cases)
- Good error handling with fallbacks (summarizer.ts:85-92)

### Issues

#### Important
1. Missing help text in CLI wrapper
   - File: index-conversations:1-31
   - Issue: No --help flag, users won't discover --concurrency
   - Fix: Add --help case with usage examples

2. Date validation missing
   - File: search.ts:25-27
   - Issue: Invalid dates silently return no results
   - Fix: Validate ISO format, throw error with example

#### Minor
1. Progress indicators
   - File: indexer.ts:130
   - Issue: No "X of Y" counter for long operations
   - Impact: Users don't know how long to wait

### Recommendations
- Add progress reporting for user experience
- Consider config file for excluded projects (portability)

### Assessment

Ready to merge: With fixes

Reasoning: Core implementation is solid with good architecture and tests.
Important issues (help text, date validation) are easily fixed and don't
affect core functionality.
```

## Red Flags — STOP

If you catch yourself thinking any of these, you are about to violate this skill. Stop and return to the process above.

| Red flag (what you think) | Reality |
| --- | --- |
| "It's simple, skip review." | Simple changes are where self-audits miss the most. You MUST review. |
| "I'll just re-read my own reasoning." | That is not a review. The pass MUST be independent of your intent. |
| "The Critical issue is probably fine." | You MUST NOT proceed with an unfixed Critical issue. |
| "I'll fix the Important issue later." | You MUST fix Important issues before any further implementation work (next task, refactor, or merge). |
| "The reviewer is wrong, I'll ignore it." | You MUST push back with technical evidence, or fix it. Silent dismissal is not allowed. |
| "No subagent here, so I'll skip the review." | You MUST run the fallback self-review pass. Absence of subagents is not absence of review. |
| "I'll edit while I review." | The review pass MUST be read-only; act on findings only in step 3. |

## Rationalizations — all REJECTED

| Rationalization | Why it fails |
| --- | --- |
| "It obviously works, review is overhead." | "Obvious" correctness is the single most common source of shipped defects. The Iron Law applies. |
| "I already checked it as I wrote it." | Checking-while-writing is not an independent pass. You MUST review the finished diff cold. |
| "The host has no Task tool, so review isn't possible." | The fallback self-review is REQUIRED in that case. There is always a portable path. |
| "I'm the author, I know it's correct." | Author confidence is exactly the bias an independent pass exists to counteract. |
| "Minor issues don't matter, I'll drop them." | Minor issues MUST be recorded, not dropped. Dropping them silently loses real signal. |

## Verification Checklist

Before you treat work as reviewed, confirm every item:

- [ ] The reviewed range is committed and `{BASE_SHA}`/`{HEAD_SHA}` are captured.
- [ ] The review ran via a subagent, OR — if no subagent capability exists — via a deliberate, read-only, independent self-pass.
- [ ] The full diff was read top to bottom against the stated requirements.
- [ ] The review produced the brief's exact output format (Strengths, Issues by severity, Recommendations, Assessment).
- [ ] Every Critical issue is fixed.
- [ ] Every Important issue is fixed before any further implementation work (the next task, a refactor, or a merge).
- [ ] Every Minor issue is recorded.
- [ ] Any disputed finding was answered with specific technical reasoning, not silent dismissal.
