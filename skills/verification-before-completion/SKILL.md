---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, passing, or ready — or before committing, pushing, or opening a PR — you MUST run the verification and read its output before making any success claim; evidence before assertions, always
---

# Verification Before Completion

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

- Verifying command not run in this session, or its output not read → MUST NOT state that the thing it would prove passes, is fixed, or is complete.
- The Iron Law has no exception.

## The Gate (MANDATORY before any success claim)

About to state any status, or express satisfaction → MUST, in order:

1. **Identify** the command or check that would prove the claim.
2. **Run** it fresh and in full — never a partial run, never a remembered one.
3. **Read** the full output: the exit code and the actual pass/fail counts.
4. **Compare** the output to the claim. Output confirms the claim → state the claim WITH the evidence. Output does not confirm it → state the actual status with the evidence.

MUST NOT skip a step.

## What Each Claim Requires

| Claim | Proof REQUIRED | Not sufficient |
|---|---|---|
| Tests pass | the test command's output this session: 0 failures | a previous run, "should pass" |
| Linter / types clean | the tool's output: 0 errors | a partial check, extrapolation |
| Build succeeds | the build command: exit 0 | "the linter passed", "logs look fine" |
| Bug fixed | the original symptom re-tested: passes | code changed, assumed fixed |
| Regression test works | watched it fail before the fix and pass after | it passes once |
| Requirements met | a line-by-line check against them | "the tests pass" |
| Delegated / generated work done | inspected the actual diff and artifacts | a "success" report |

## Red Flags — STOP

Notice any of these → MUST stop and verify:

- "should", "probably", or "seems to" about the result
- confidence in the result standing in for a fresh run
- expressing satisfaction before verifying ("Great!", "Perfect!", "Done!")
- about to commit, push, or open a PR without a fresh check
- trusting a reported success instead of checking the artifacts yourself
- relying on a partial check, or on a passing linter as proof of the build or the tests
- "just this once", or being tired and wanting it over
- ANY wording that implies success when the check has not been run

## Scope

The Gate applies before ANY claim or implication of success, completion, or correctness — exact phrases, paraphrases, synonyms, and implications alike — and before committing, opening a PR, marking a task done, or moving to the next task.
