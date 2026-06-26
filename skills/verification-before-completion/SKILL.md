---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, passing, or ready — or before committing, pushing, or opening a PR — you MUST run the verification and read its output before making any success claim; evidence before assertions, always
---

# Verification Before Completion

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Claiming work is done without verifying it is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always. You MUST NOT state that something passes, is fixed, or is complete until you have run the check and read its output in the current session.

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

If you have not run the verifying command in this session and read its output, you MUST NOT claim the thing it would prove.

## The Gate (MANDATORY before any success claim)

Before you state any status — or express satisfaction — you MUST:

1. **Identify** the command or check that would prove the claim.
2. **Run** it fresh and in full, not a partial or remembered run.
3. **Read** the full output — the exit code and the actual pass/fail counts.
4. **Compare** the output to the claim. If it does not confirm the claim, you MUST state the actual status with the evidence. If it does, state the claim WITH the evidence.

Skipping any step is claiming without proof; you MUST NOT do it.

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

You MUST stop and verify if you notice:

- "should", "probably", or "seems to" about the result
- expressing satisfaction before verifying ("Great!", "Perfect!", "Done!")
- about to commit, push, or open a PR without a fresh check
- trusting a reported success instead of checking the artifacts yourself
- relying on a partial check
- "just this once", or being tired and wanting it over
- ANY wording that implies success when you have not run the check

## Rationalizations — rejected

| Excuse | Reality |
|--------|---------|
| "Should work now" | Run the check. |
| "I'm confident" | Confidence is not evidence. |
| "Just this once" | No exceptions. |
| "The linter passed" | The linter is not the compiler or the tests. |
| "It was reported as success" | Verify it independently against the artifacts. |
| "I'm tired" | Exhaustion is not an exemption. |
| "A partial check is enough" | Partial proves nothing about the whole. |
| "Different words, so the rule doesn't apply" | Spirit over letter — any implication of success counts. |

## Scope

This applies before ANY claim or implication of success, completion, or correctness — exact phrases, paraphrases, synonyms, and implications alike — and before committing, opening a PR, marking a task done, or moving to the next task.

## The Bottom Line

Run the command. Read the output. THEN state the result. No shortcuts; this is non-negotiable.
