---
name: requesting-code-review
description: Use when work is complete or you want a code review — a feature or plan task is finished, a complex bug is fixed, or before a refactor, commit, push, or merge — you MUST get a fresh-eyes review of the finished diff against its requirements before proceeding.
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

**Primary path — dispatch a reviewer subagent.** If the host provides a subagent / task-dispatch capability, you MUST dispatch one independent reviewer agent using the brief in `@reviewer-brief.md`, with the placeholders filled in. The subagent MUST run read-only (see the brief).

**Fallback path — review in a fresh independent pass yourself.** If the host provides no subagent capability, you MUST perform the review yourself as a deliberate, separate pass. To keep it independent you MUST:
- Treat the diff as if written by someone else. You MUST work only from the requirements and the diff, and MUST NOT rely on your memory of why you wrote each line.
- Read the entire diff (`git diff $BASE_SHA..$HEAD_SHA`) top to bottom before forming any conclusion.
- Apply the full brief in `@reviewer-brief.md` and produce its exact output format.
- Keep the pass read-only: you MUST NOT edit code during the review. Record findings first, then act on them in step 3.

The fallback MUST NOT be a token gesture. A self-review that merely confirms your prior intent violates the Iron Law.

### 3. Act on feedback

- You MUST fix every Critical issue before proceeding.
- You MUST fix every Important issue before proceeding to any further implementation work (the next task, a refactor, or a merge). Deferring it past the current checkpoint leaves the defect to compound into later work.
- You MUST record Minor issues (e.g. in the task notes or an issue tracker) rather than silently dropping them.
- If the reviewer is wrong, you MUST push back with specific technical reasoning — cite the code, the tests, or the requirement that proves the point. You MUST NOT accept an incorrect finding just to close it out, and you MUST NOT dismiss a finding without that reasoning.

## Reviewer Brief — `@reviewer-brief.md`

The reviewer prompt (what to check, calibration, the exact output format, the DO/DON'T rules) and a sample completed review live in the same-directory file `@reviewer-brief.md`. They are needed only when you actually run a review, so they are kept out of this always-loaded body. At **step 2** you MUST read `@reviewer-brief.md` and use it as the reviewer's prompt, filling every placeholder first:

- `{DESCRIPTION}` — a brief summary of what was built.
- `{PLAN_OR_REQUIREMENTS}` — what it was supposed to do (the plan text, task text, or requirements).
- `{BASE_SHA}` — the starting commit.
- `{HEAD_SHA}` — the ending commit.

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
