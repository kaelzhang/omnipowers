---
name: fixing-bugs
description: Use when encountering or fixing any bug, crash, exception, test failure (including flaky/intermittent), regression, wrong output, build or performance problem, or other unexpected behavior — you MUST reproduce it red and name the root cause before you change production code
---

# Fixing Bugs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
REPRODUCE IT RED — NAME THE ROOT CAUSE — ONLY THEN CHANGE PRODUCTION CODE
```

- You MUST NOT modify production code until a test reproduces the bug and you have watched it fail for the bug's reason.
- You MUST NOT propose or apply a fix until you can state the root cause. "It's probably X" is not a root cause.
- The fix was written first → you MUST revert it, reproduce the bug with a failing test, then re-apply it. You MUST NOT keep it staged or commented out "for reference" while you write the test.
- You MUST NOT write a test that passes against the buggy code and call it a regression test.

## When to Use

- Any technical failure — a bug, a crash, an exception, wrong output, a regression, a test failure, a performance problem, a build failure, an integration issue, a "works on my machine" report → you MUST apply this skill.
- An emergency, an "obvious quick fix", or a previous fix that failed → it applies especially. You MUST NOT skip it because the issue "seems simple", because it is "one line", or because you are in a hurry.
- Nothing is broken and you are adding a capability → this skill does not apply, and you MUST NOT stretch it to cover feature work.

## REPRODUCE — a failing test that triggers the bug

- You MUST produce a command, test, or script that runs red for the bug's reason, and you MUST have observed its red output before going further.
- You MUST reconstruct the triggering input, data, and state in the fixture, assert the *correct* behavior — the exact value, error message, status, or count the report names — and you MUST NOT assert the buggy behavior or a vague "it works". Each test MUST cover one defect and MUST be named after the bug.
- You MUST run it through the host project's own test runner, following that project's test-file conventions.
- No obvious loop is available → read `@building-a-feedback-loop.md` and apply it.
- The problem is a **performance** problem → the loop MUST be a measurement with a captured baseline, not logs.
- The failure is intermittent → suspect a timing race rather than the code under test. A test waits on an arbitrary delay → the root-cause fix is to wait on the real condition; read `@condition-based-waiting.md` and apply it.
- No loop can be built after real effort → you MUST escalate through the `confirming-with-the-user` skill with a record of what you attempted and a concrete ask — exact logs, reproduction steps, environment details, or access. Proceeding without the test then requires "The Only Exception" below.

### Verify it fails — for the bug's reason

This step is REQUIRED. You MUST NOT skip it.

- You MUST confirm the test **fails** rather than merely errors out, that it fails **the way the bug manifests**, and that it fails because of the defect — not a typo or a wrong import.
- The test passes → it does NOT reproduce the bug; you MUST fix the test until it does.
- The failure differs from the bug → you have NOT reproduced this bug; you MUST keep working.

## ROOT CAUSE — before any fix

- You MUST trace from the failing assertion to the line that produces the wrong result, and you MUST fix at the level where the cause lives, not where the symptom surfaces.
- The cause is not evident from the failing test → read `@investigating.md` and apply it. It carries reading the error, recent changes, cross-boundary instrumentation, backward tracing, pattern analysis, ranked hypotheses, probe discipline, and what to do when three fixes have failed.
- The root cause is unknown → you MUST keep investigating. You MUST NOT patch a symptom you do not understand, and you MUST NOT pretend to understand.

## FIX — minimal change at the cause

- You MUST fix the root cause, and you MUST NOT patch the symptom.
- You MUST make the minimal change; in the same change you MUST NOT refactor unrelated code, add features, or fix unrelated bugs. Another site of the same root cause is not an unrelated bug — see SWEEP.
- You MUST apply the fix to the host project's actual production implementation — the code that ships and that your reproducing test exercises.
- You cannot locate that implementation → you MUST keep searching for it, and you MUST NOT substitute a standalone "corrected" function, a snippet, or sample code as the fix.

### Verify it passes

This step is REQUIRED.

- You MUST confirm the reproducing test now **passes**, that **all other tests still pass**, and that output is pristine — no new errors or warnings.
- The reproducing test still fails → you MUST fix the code, not the test.
- Other tests broke → you MUST address those side effects now.
- Cleanup is part of verification: a grep for your probe tag MUST return nothing, throwaway harnesses and repro scripts MUST be deleted or promoted into real tests deliberately, and the change description MUST state the confirmed root cause in one line.

## SWEEP — every other site of the same root cause

The fix is verified:

- You MUST search the codebase for every other site that shares this root cause — the same call pattern, the same missing guard, the same wrong assumption, the same copied block — and you MUST state which searches you ran. A search you did not run MUST NOT be reported as "no other sites".
- A site found has the defect → it is the same bug, and you MUST fix it in this change, covered by a test that fails without the fix. One test MAY cover several sites. These fixes are part of this cycle → you MUST NOT restart the cycle for each of them.
- A site found rests on the same assumption but cannot fail today → you MUST make it safe now, or record it where the host keeps follow-up work and name it in your report.
- The root cause exists at exactly one site → you MUST say so, and the sweep is done.
- The sweep is bounded by the cause: you MUST run only the searches the root cause defines, and you MUST NOT audit unrelated code.

## HARDEN — cover the defect class

The suite is green:

- You SHOULD add tests for adjacent cases of the same defect (boundary, null, zero, concurrent) wherever they could plausibly fail.
- The bug was an invalid value reaching a dangerous operation → you SHOULD guard each layer that value crosses, so the class becomes structurally impossible; read `@defense-in-depth.md` and apply it.
- You MAY clean up the fix (names, duplication). You MUST keep every test green; refactoring MUST NOT change behavior.
- **Ask the prevention question — after the fix lands.** What would have made this bug impossible or caught it earlier? A cheap hardening (a validation, an assertion, a lint rule) MAY follow as its own change; an architectural answer goes to the user via the `confirming-with-the-user` skill. You MUST NOT bundle the prevention work into the fix itself.

## When the Regression Test Is Hard to Write

| Friction | What to do |
|---|---|
| The test needs elaborate setup — the unit does too much / is too coupled | Extract helpers; consider splitting the unit. |
| You must mock almost everything — the code depends on concretes, not interfaces | Inject the dependency instead of reaching for it. |
| You cannot isolate the bug in a test — the responsibility is smeared across layers | Narrow the seam; test at the level the defect lives. |

- Friction does not waive the Iron Law → you MUST still write the reproducing test, and the fix may need a small structural change to make that test writable.
- No correct seam exists (the only way to test would couple to internals) → you MUST record the seam gap and raise it with the user after the fix lands, and you MUST NOT skip the test or test through internals.

## The Only Exception — when you cannot reproduce it

The reproducing test is REQUIRED. You MAY skip it ONLY when reproduction is genuinely impossible after real effort, and only after doing all of the following before treating the fix as done:

1. You MUST summarize the complete reasons reproduction is impossible.
2. You MUST obtain the user's explicit permission to proceed without a reproducing test.
3. You MUST add a comment in the relevant production code recording that no regression test exists and why.

- You MUST NOT skip the reproducing test for any other reason — not because the fix is "obvious", "too small", urgent, or because no tests exist nearby.
- Reproduction is hard, or real effort is not yet exhausted → a reproducing test is still REQUIRED; you MUST keep investigating, and you MUST NOT guess at the fix.
- You reproduced the bug manually → a reproducing test is still REQUIRED.
- The bug is in third-party code → you MUST test your usage and pin the behavior you depend on.

## Testing Anti-Patterns

When you write the regression test or add mocks, you MUST read `@testing-anti-patterns.md` and avoid testing mock behavior instead of real behavior, adding test-only methods to production classes, and mocking without understanding dependencies.

## Red Flags — STOP

Any of these → you MUST revert the fix, reproduce with a failing test, name the cause, then fix:

- "Quick fix now, investigate later" / "Just try changing X and see" / "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- The fix was written before a reproducing test, or the regression test was added after the fix.
- The "regression test" passes against the buggy code.
- The symptom is patched without locating the cause.
- Listing fixes before tracing the data flow, or several changes at once and then running tests.
- "Skip the test, I'll check manually."
- A standalone "corrected" function or snippet submitted instead of a patch to the real implementation.
- The fix is speculative, for a bug you cannot trigger, without having met the Only Exception bar.
- "This bug is different because..."
- One more fix attempt after 3 failed fixes, or each fix exposing a new problem elsewhere → read `@investigating.md` and question the architecture.

## Verification Checklist

You MUST be able to check every box before calling the bug fixed:

- [ ] Reproduced the bug with a test that failed first, the way the bug manifests
- [ ] Located the root cause; fixed the cause, not the symptom
- [ ] Made the minimal fix (no unrelated changes)
- [ ] The reproducing test now passes; all other tests still pass; output pristine
- [ ] Probes removed and their removal verified; the change description names the root cause
- [ ] The regression test remains in the suite
- [ ] Swept for other sites of the same root cause, naming the searches run
- [ ] Every site found is fixed in this change, made safe, or recorded as follow-up
- [ ] Adjacent cases of the same defect are covered, or their absence is justified

You cannot check every box → the bug is not fixed; you MUST start over. The only permitted gap is a missing reproducing test under the Only Exception conditions above.
