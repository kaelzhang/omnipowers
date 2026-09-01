---
name: test-driven-bug-fixing
description: Use when fixing any bug, defect, crash, exception, regression, or wrong/incorrect output — you MUST reproduce it with a failing test before changing production code
---

# Test-Driven Bug Fixing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- You MUST reproduce the bug with a failing test before you change any production code, and you MUST watch that test fail for the bug's reason. Only then MAY you write the fix.

## When to Use

- You are fixing a defect in existing behavior — a reported bug, a crash, an exception, wrong output, a regression, a "works on my machine" investigation → you MUST apply this skill.
- Nothing is broken and you are adding a capability rather than correcting wrong behavior → this skill does not apply, and you MUST NOT stretch it to cover feature work.
- You MUST NOT downgrade a bug fix to "just a quick change" to avoid this skill; "it's obvious" and "it's one line" are not exceptions.

## The Iron Law

```
NO BUG FIX WITHOUT A FAILING TEST THAT REPRODUCES THE BUG FIRST
```

- You MUST NOT modify production code to fix a bug until a test reproduces that bug and fails.
- The fix was written before the test → you MUST revert it, reproduce the bug with a failing test, then re-apply the fix.
- You MUST NOT keep the fix staged or commented out "for reference" while writing the test.
- You MUST NOT write a test that passes against the buggy code and call it a regression test.

## Reproduce → Fix → Harden

### REPRODUCE — write a failing test that triggers the bug

- You MUST reconstruct the triggering input, data, and state in the test fixture.
- You MUST assert the *correct* behavior — the exact value, error message, status, or count the bug report names — and you MUST NOT assert the buggy behavior or a vague "it works".
- Each test MUST cover one defect and MUST be named after the bug.

### Verify it fails — for the bug's reason

This step is REQUIRED. You MUST NOT skip it.

- You MUST run the test through the host project's own test runner, following that project's test-file conventions.
- You MUST confirm the test **fails** rather than merely errors out, that it fails **the way the bug manifests** (the wrong output, the missing error, the crash), and that it fails because of the defect — not because of a typo or a wrong import.
- The test passes → it does NOT reproduce the bug; you MUST fix the test until it does.
- The failure differs from the bug → you have NOT reproduced this bug yet; you MUST keep working.

### Find the root cause — before fixing

- You MUST trace from the failing assertion to the line that produces the wrong result.
- You MUST fix at the level where the cause lives, not where the symptom surfaces.
- The root cause is unknown → you MUST keep investigating, and you MUST NOT patch a symptom you do not understand.

### FIX — minimal change at the root cause

- You MUST fix the root cause, and you MUST NOT patch the symptom.
- You MUST make the minimal change; in the same change you MUST NOT refactor unrelated code, add features, or fix unrelated bugs. Another site of the same root cause is not an unrelated bug — see SWEEP.
- You MUST apply the fix to the host project's actual production implementation — the code that ships and that your reproducing test exercises.
- You cannot locate that implementation → you MUST keep searching for it, and you MUST NOT substitute a standalone "corrected" function, a snippet, or sample code as the fix.

### Verify it passes

This step is REQUIRED.

- You MUST confirm that the reproducing test now **passes**, that **all other tests still pass**, and that output is pristine — no new errors or warnings.
- The reproducing test still fails → you MUST fix the code, not the test.
- Other tests broke → you MUST address those side effects now.

### SWEEP — every other site of the same root cause

The fix is verified:

- You MUST search the codebase for every other site that shares this root cause — the same call pattern, the same missing guard, the same wrong assumption, the same copied block — and you MUST state which searches you ran. A search you did not run MUST NOT be reported as "no other sites".
- A site found has the defect → it is the same bug, and you MUST fix it in this change, covered by a test that fails without the fix. One test MAY cover several sites. These fixes are part of this cycle → you MUST NOT restart the cycle for each of them.
- A site found rests on the same assumption but cannot fail today → you MUST make it safe now, or record it where the host keeps follow-up work and name it in your report.
- The root cause exists at exactly one site → you MUST say so, and the sweep is done.
- The sweep is bounded by the cause: you MUST run only the searches the root cause defines, and you MUST NOT audit unrelated code.

### HARDEN — cover the defect class

The suite is green:

- You SHOULD add tests for adjacent cases of the same defect (boundary, null, zero, concurrent) wherever they could plausibly fail.
- You MAY clean up the fix (names, duplication).
- You MUST keep every test green; refactoring MUST NOT change behavior.

## When the Regression Test Is Hard to Write

| Friction | What to do |
|---|---|
| The test needs elaborate setup — the unit does too much / is too coupled | Extract helpers; consider splitting the unit. |
| You must mock almost everything — the code depends on concretes, not interfaces | Inject the dependency instead of reaching for it. |
| You cannot isolate the bug in a test — the responsibility is smeared across layers | Narrow the seam; test at the level the defect lives. |

- Friction does not waive the Iron Law → you MUST still write the reproducing test, and the fix may need a small structural change to make that test writable.
- No correct seam exists for the regression test (the only way to test would couple to internals) → you MUST record the seam gap and raise it with the user after the fix lands, and you MUST NOT skip the test or test through internals.

## The Only Exception — when you cannot reproduce it

The reproducing test is REQUIRED. You MAY skip it ONLY when reproduction is genuinely impossible after real effort, and only after doing all of the following before treating the fix as done:

1. You MUST summarize the complete reasons reproduction is impossible.
2. You MUST obtain the user's explicit permission to proceed without a reproducing test.
3. You MUST add a comment in the relevant production code recording that no regression test exists and why.

- You MUST NOT skip the reproducing test for any other reason — not because the fix is "obvious", "too small", urgent, or because no tests exist nearby.
- Reproduction is hard, or real effort is not yet exhausted → a reproducing test is still REQUIRED; you MUST keep investigating, and you MUST NOT guess at the fix.
- You reproduced the bug manually → a reproducing test is still REQUIRED.
- The bug is in third-party code → you MUST test your usage and pin the behavior you depend on.

## Red Flags — STOP and start over

Any of these is true → you MUST revert the fix, reproduce with a failing test, then fix:

- The fix was written before a reproducing test.
- The "regression test" passes against the buggy code.
- The regression test was added after the fix.
- You cannot reproduce the bug but are "pretty sure" the fix is right, without having met the "Only Exception" bar.
- The symptom is patched without locating the cause.
- A standalone "corrected" function or snippet is submitted as the fix instead of a patch to the real implementation.
- The fix is speculative, for a bug you cannot trigger.
- "This bug is different because..."

## Testing Anti-Patterns

When you write the regression test or add mocks, you MUST read @testing-anti-patterns.md and avoid:

- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

## Verification Checklist

You MUST be able to check every box before calling the bug fixed:

- [ ] Reproduced the bug with a test that failed first
- [ ] The test failed the way the bug manifests (right reason)
- [ ] Located the root cause; fixed the cause, not the symptom
- [ ] Made the minimal fix (no unrelated changes)
- [ ] The reproducing test now passes
- [ ] All other tests still pass; output pristine
- [ ] The regression test remains in the suite
- [ ] Swept for other sites of the same root cause, naming the searches run
- [ ] Every site found is fixed in this change, made safe, or recorded as follow-up
- [ ] Adjacent cases of the same defect are covered, or their absence is justified

You cannot check every box → the bug is not fixed; you MUST start over. The only permitted gap is a missing reproducing test under the "Only Exception" conditions above.
