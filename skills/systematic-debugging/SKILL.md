---
name: systematic-debugging
description: Use when encountering any bug, crash, test failure (including flaky/intermittent), build or performance problem, or other unexpected behavior — you MUST find the root cause before proposing or making any fix
---

# Systematic Debugging

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

You MUST find the root cause — why the failure happens — before you change anything.

## The Iron Law

```
NO FIX WITHOUT ROOT-CAUSE INVESTIGATION FIRST
```

You MUST NOT propose or apply a fix until you have completed Phase 1 and can state the root cause. "It's probably X" is not a root cause.

## When to Use

- Any technical failure — a test failure, a bug, unexpected behavior, a performance problem, a build failure, an integration issue → you MUST use this skill.
- An emergency, an "obvious quick fix", or a previous fix that failed → this skill applies especially.
- You MUST NOT skip it because the issue "seems simple" or because you are in a hurry.

## The Four Phases

You MUST complete each phase before the next.

### Phase 1 — Root-cause investigation (REQUIRED before any fix)

You MUST:

1. **Read the error completely.** Read the full message and stack trace; note line numbers, file paths, error codes. You MUST NOT skip past warnings.
2. **Build a feedback loop that demonstrates the failure.**
   - You MUST produce a command, test, or script that runs red for the bug's reason, and you MUST have observed its red output before proceeding.
   - No obvious loop is available → read `@building-a-feedback-loop.md` and apply it (construction routes, loop tightening, non-deterministic-bug amplification).
   - The problem is a **performance** problem → the loop MUST be a measurement with a captured baseline, not logs.
   - The failure is intermittent → suspect a timing race rather than the code under test. A test waits on an arbitrary delay → the root-cause fix is to wait on the real condition instead; read `@condition-based-waiting.md` and apply it.
   - No loop can be built after real effort → you MAY stop and escalate ONLY with a record of what you attempted and a concrete ask (exact logs, reproduction steps, environment details, or access you need), presented via the `confirming-with-the-user` skill. You MUST NOT guess at a fix for a failure you cannot trigger.
3. **Check recent changes.** Inspect the diff, recent commits, new dependencies, config, and environment differences for what could have introduced it.
4. **Instrument multi-component systems.** The failure crosses component boundaries → before proposing a fix you MUST add diagnostic logging at each boundary (what enters, what exits, config/state at each layer), run once, and read the evidence to locate WHICH layer fails. You MUST NOT guess which layer is at fault. The boundary falls outside the area you are authorized to change → the instrumentation MUST stay observation-only: behavior unchanged, every edit carrying a searchable tag, nothing committed, and every probe removed and its removal verified before the work ends. The fix is never made under that latitude — it goes to whoever owns that area, through the host's own mechanism.
5. **Trace the bad value to its source.** The error surfaces deep in the call stack → you MUST trace backward: where did the bad value originate, and what passed it in? Keep going up until you reach the origin, and fix at the source, not where the symptom appears. The chain is long, or you cannot follow it by reading code → read `@root-cause-tracing.md` and apply it.

### Phase 2 — Pattern analysis

You MUST: find similar working code in the same codebase; if you are following a reference or pattern, read it **completely** (you MUST NOT skim); list **every** difference between the working and broken cases (you MUST NOT dismiss a difference as "that can't matter"); and identify the dependencies, config, and assumptions the code relies on.

### Phase 3 — Hypothesis and test

You MUST:

1. **Enumerate before testing.** List 3–5 candidate hypotheses and rank them by likelihood BEFORE testing any. Each hypothesis MUST state a falsifiable prediction — for example, "if X is the cause, then probe P will show Q". The bug is substantial → you SHOULD share the ranked list with the user as a non-blocking checkpoint: keep working; their reply may re-rank.
2. Test the top hypothesis with the **smallest** possible change — one hypothesis at a time, one variable at a time. You MUST NOT change several things at once.
3. **Probe discipline.** Every probe you add MUST map to a specific hypothesis's prediction; you MUST NOT "log everything and grep". You SHOULD prefer a debugger or REPL over log statements where the host environment allows. Every temporary probe MUST carry one unique tag prefix (e.g. `DBG-<slug>`) so removal is verifiable later.
4. The hypothesis is confirmed → Phase 4. It is not → move to the next ranked hypothesis; you MUST NOT pile another fix on top of a failed one.
5. You do not understand something → you MUST say so and investigate further; you MUST NOT pretend to understand.

### Phase 4 — Implementation

You MUST:

1. **Run the fix cycle.** The `test-driven-bug-fixing` skill owns it: a failing test that reproduces the bug before any production change, the minimal fix at the cause, verification that it passes and nothing else broke, and the sweep for every other site sharing that cause. You MUST use it, and you MUST NOT weaken any of its rules here. It is not installed → run that same cycle yourself, in that order.
2. **Clean up as part of verification.** A grep for your probe tag MUST return nothing; throwaway harnesses and repro scripts MUST be deleted, or promoted into real tests deliberately; the change description MUST state the confirmed root cause in one line.
3. **Harden the value's path.** The fix is verified AND the bug was an invalid value reaching a dangerous operation → you SHOULD guard each layer that value crosses, so the class becomes structurally impossible; read `@defense-in-depth.md` and apply it.
4. **Ask the prevention question — after the fix lands.** What would have made this bug impossible or caught it earlier? A cheap hardening (a validation, an assertion, a lint rule) MAY follow as its own change; an architectural answer goes to the user via the `confirming-with-the-user` skill. You MUST NOT bundle the prevention work into the fix itself.
5. **The fix failed → STOP and count.** Fewer than 3 fixes tried → return to Phase 1 with the new information. **3 or more tried → you MUST stop fixing and question the architecture** (below).

### When 3+ fixes have failed — question the architecture

Three or more failed fixes → you MUST stop attempting fixes and raise the architectural question with the user: is this pattern sound, or are we fixing symptoms of a wrong design? The signal is strongest when each fix exposes a new coupling or shared-state problem elsewhere, or each fix needs "massive refactoring". You MUST NOT attempt fix #4 without that discussion.

## Red Flags — STOP and return to Phase 1

If you catch any of these, you MUST stop and restart at Phase 1:

- "Quick fix now, investigate later"
- "Just try changing X and see"
- Several changes at once, then run tests
- "Skip the test, I'll check manually"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- Listing fixes before tracing the data flow
- "One more fix attempt" after 3 failed fixes (a 4th attempt — stop and question the architecture)
- Each fix exposing a new problem elsewhere (→ question the architecture)

## When Investigation Finds No Code Root Cause

A thorough investigation shows the cause is genuinely environmental, timing-dependent, or external → you MUST: document what you investigated; implement appropriate handling (retry / timeout / a clear error); and add logging for future diagnosis. This is the only path on which the reproducing test may be skipped, and only through the escape the fix cycle defines. You MUST first be sure you actually finished Phase 1.
