---
name: fixing-bugs
description: Use when encountering or fixing any bug, crash, exception, test failure (including flaky/intermittent), regression, wrong output, build or performance problem, or other unexpected behavior — "修 bug", "回归测试", "排查" — you MUST reproduce it red and name the root cause before you change production code
---

# Fixing Bugs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
REPRODUCE IT RED — NAME THE ROOT CAUSE — ONLY THEN CHANGE PRODUCTION CODE
```

- You MUST NOT modify production code until a test reproduces the bug and you have watched it fail for the bug's reason.
- Before you can state the root cause → you MUST NOT propose or apply a fix.
- The fix was written first → you MUST take it out of the working tree, reproduce the bug with a failing test against the unfixed code, then put the fix back and watch the test pass. You MUST NOT leave it in place, staged, or commented out while you write the test.
- You MUST NOT write a test that passes against the buggy code and call it a regression test.

## When to Use

- Any technical failure — a bug, a crash, an exception, wrong output, a regression, a test failure, a performance problem, a build failure, an integration issue, a "works on my machine" report → you MUST apply this skill.
- The issue "seems simple", is "one line", or you are in a hurry → you MUST NOT skip this skill.
- Nothing is broken and you are adding a capability → you MUST NOT stretch this skill to cover feature work.

## REPRODUCE — a failing test that triggers the bug

- You MUST produce a command, test, or script that runs red for the bug's reason, and you MUST have observed its red output before going further.
- During reproduction → you MUST reconstruct the triggering input, data, and state in the fixture and assert the correct behavior — the exact value, error message, status, or count the report names.
- During reproduction → you MUST NOT assert the buggy behavior or a vague "it works".
- Each reproducing test MUST cover one defect and MUST be named after the behavior it pins, readable as a sentence.
- You MUST run it through the host project's own test runner, following that project's test-file conventions.

No obvious loop is available → read `@building-a-feedback-loop.md` and apply it.

- The problem is a **performance** problem → the loop MUST be a measurement with a captured baseline, not logs.

A test waits on an arbitrary delay → read `@condition-based-waiting.md` and apply it.

- No loop can be built after real effort → you MUST escalate through the `confirming-with-the-user` skill with a record of what you attempted and a concrete ask — exact logs, reproduction steps, environment details, or access.

### Verify it fails — for the bug's reason

Verifying failure for the bug's reason is REQUIRED. You MUST NOT skip verification of that failure.

- You MUST confirm the test **fails** rather than merely errors out, that it fails **the way the bug manifests**, and that the defect causes the failure — not a typo or a wrong import.
- The reproducing test passes → you MUST fix that test until it goes red for the bug's reason.
- The failure differs from the bug → you MUST keep working.

## ROOT CAUSE — before any fix

- You MUST trace from the failing assertion to the line that produces the wrong result, and you MUST fix at the level where the cause lives, not where the symptom surfaces.

The cause is not evident from the failing test → read `@investigating.md` and apply it.

- The root cause is unknown → you MUST keep investigating.
- The root cause is unknown → you MUST NOT patch a symptom you do not understand, and you MUST NOT pretend to understand.

## FIX — minimal change at the cause

- During the fix → you MUST fix the root cause.
- During the fix → you MUST NOT patch the symptom.
- During the fix → you MUST make the minimal change.
- In the same change → you MUST NOT refactor unrelated code, add features, or fix unrelated bugs.
- You MUST apply the fix to the host project's actual production implementation — the code that ships and that your reproducing test exercises.
- You cannot locate that implementation → you MUST keep searching for it.
- You cannot locate that implementation → you MUST NOT substitute a standalone "corrected" function, a snippet, or sample code as the fix.

### Verify it passes

Verifying that the reproducing test passes is REQUIRED.

- You MUST confirm the reproducing test now **passes** and the tests covering the changed area still pass, with pristine output — no new errors or warnings.
- The reproducing test still fails → you MUST fix the code, not the test.
- Other tests broke → you MUST fix the code.
- During verification → a grep for your probe tag MUST return nothing, throwaway harnesses and repro scripts MUST be deleted or promoted into real tests deliberately, and the change description MUST state the confirmed root cause in one line.

## A test states a requirement

- A test that should be passing fails → you MUST fix the code. You MUST NOT weaken the assertion, narrow the input, delete the test, skip it, or mark it expected-to-fail.
- A test looks wrong to you but contradicts nothing the user has stated → you MUST NOT change it until you have quoted the requirement you believe it violates and obtained the user's explicit approval.

## SWEEP — every other site of the same root cause

- The fix is verified → you MUST search the codebase for every other site that shares this root cause — the same call pattern, the same missing guard, the same wrong assumption, the same copied block — and you MUST state which searches you ran. A search you did not run MUST NOT be reported as "no other sites".
- A site found has the defect → you MUST fix it in this change, covered by a test that fails without the fix. One test MAY cover several sites. For fixes at sites found by the sweep → you MUST NOT restart the cycle for each of them.
- A site found rests on the same assumption but cannot fail today → you MUST make it safe now, or record it where the host keeps follow-up work and name it in your report.
- The root cause exists at exactly one site → you MUST say so.
- During the sweep → you MUST run only the searches the root cause defines, and you MUST NOT audit unrelated code.

## HARDEN — cover the defect class

- The suite is green → you SHOULD add tests for adjacent cases of the same defect (boundary, null, zero, concurrent) wherever they could plausibly fail.
- The suite is green and the bug was an invalid value reaching a dangerous operation → you SHOULD guard each layer that value crosses.

The suite is green and the bug was an invalid value reaching a dangerous operation → read `@defense-in-depth.md` and apply it.

- The suite is green → you MAY clean up the fix (names, duplication).
- During cleanup → you MUST keep every test green.
- During refactoring → you MUST NOT change behavior.
- The bug reached users or production, has recurred, or the sweep found it at two or more sites → a cheap hardening (a validation, an assertion, a lint rule) MAY follow as its own change.
- The bug reached users or production, has recurred, or the sweep found it at two or more sites → you MUST NOT bundle the prevention work into the fix itself.

## When the Regression Test Is Hard to Write

The test needs elaborate setup, near-total mocking, or you cannot isolate the bug at one seam → read `@hard-to-test.md` and apply it.

## The Only Exception — when you cannot reproduce it

The reproducing test is REQUIRED.

You MAY skip the reproducing test ONLY when reproduction is genuinely impossible after real effort, and only after completing all three requirements below before treating the fix as done:

1. You MUST summarize the complete reasons reproduction is impossible.
2. You MUST obtain the user's explicit permission to proceed without a reproducing test.
3. You MUST add a comment in the relevant production code recording that no regression test exists and why.

- Outside the Only Exception → you MUST NOT skip the reproducing test, including for a fix judged "obvious", "too small", or urgent, or when no tests exist nearby.
- Reproduction is hard, or real effort is not yet exhausted → a reproducing test is still REQUIRED.
- Reproduction is hard, or real effort is not yet exhausted → you MUST keep investigating.
- Reproduction is hard, or real effort is not yet exhausted → you MUST NOT guess at the fix.
- You reproduced the bug manually → a reproducing test is still REQUIRED.
- The bug is in third-party code → you MUST test your usage and pin the behavior you depend on.

## Testing Anti-Patterns

The regression test needs a mock, stub, fake, or test-only hook → you MUST read `@testing-anti-patterns.md` and avoid testing mock behavior instead of real behavior, adding test-only methods to production classes, and mocking without understanding dependencies.

## Red Flags — STOP

Any red flag below → you MUST revert the fix, reproduce with a failing test, name the cause, then fix:

- "Quick fix now, investigate later" / "Just try changing X and see" / "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "It's one line, I'll skip the test and check by hand"
- "I reproduced it manually, that counts"
- "That assertion is too strict / this test is outdated — I'll adjust it"
- "Here's the corrected function" — a snippet in place of a patch to the real implementation
- "This bug is different because..."
- "One more try" after three failed fixes, or each fix exposing a new problem elsewhere

You are about to try a fix after three failed fixes, or each fix exposes a new problem elsewhere → read `@investigating.md` and apply it.

## Verification Checklist

You MUST be able to check every box before calling the bug fixed:

- [ ] Reproduced the bug with a test that failed first, the way the bug manifests
- [ ] Located the root cause; fixed the cause, not the symptom
- [ ] Made the minimal fix (no unrelated changes)
- [ ] The reproducing test passes; the full suite passed once, after the last code change; output pristine
- [ ] No test was weakened, narrowed, skipped, or deleted to reach green
- [ ] Probes removed and their removal verified; the change description names the root cause
- [ ] The regression test remains in the suite
- [ ] Swept for other sites of the same root cause, naming the searches run
- [ ] Every site found is fixed in this change, made safe, or recorded as follow-up
- [ ] Adjacent cases of the same defect are covered, or their absence is justified

You cannot check every box, except a missing reproducing test under the Only Exception conditions above → you MUST start over.
