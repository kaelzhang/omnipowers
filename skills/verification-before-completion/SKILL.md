---
name: verification-before-completion
description: Use once per session, the first time you are about to claim work is complete, fixed, passing, or ready, or to commit, push, or open a PR, or when asked to verify or measure something yourself ("实测", "验证"); it then governs every later claim — you MUST run the verification and read its output before any success claim; evidence before assertions, always
---

# Verification Before Completion

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

- Verifying command not run in this session, or its output not read → MUST NOT state that the thing it would prove passes, is fixed, or is complete.

## The Gate

Gate event — about to state any status, express satisfaction, claim or imply success, completion, or correctness, commit, open a PR, mark a task done, or move to the next task.

Standing evidence — a check that passed on this exact tree in this session, until a file it covered changes.

Gate event → MUST, in order:

1. **Identify** the command or check that would prove the claim.
2. **Run** it to completion or reuse standing evidence; never cut a run short or use a remembered run. **Match** its scope to the claim: the smallest sufficient check for a commit's coherence, the suite for "tests pass".
3. **Read** the full output: the exit code and the actual pass/fail counts.
4. **Compare** the output to the claim:
   - Output confirms the claim → state the claim WITH the evidence.
   - Output does not confirm it → state the actual status with the evidence.

- A skill or phase requests a check with standing evidence → MUST NOT re-run it for the asking.
- Gate event → MUST NOT skip a step.

## The Exit Code You Read Must Be the Command's

- A command's result is needed → the command MUST NOT run inside a pipeline.
- A command's result is needed → MUST redirect the command's own output to a file, read its own exit code, then read the file:

```bash
<command> > <file> 2>&1; echo "exit: $?"
```

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
- reading a check's result through a pipe (`| tail`, `| grep`, `| head`)
- "just this once", or being tired and wanting it over
- ANY wording that implies success when the check has not been run
