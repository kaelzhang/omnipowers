---
name: systematic-debugging
description: Use when encountering any bug, crash, test failure (including flaky/intermittent), build or performance problem, or other unexpected behavior — you MUST find the root cause before proposing or making any fix
---

# Systematic Debugging

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Random fixes waste time and create new bugs; a patch that hides a symptom is a failure, not a fix. You MUST find the root cause before you change anything.

**Core principle:** You MUST understand *why* the failure happens before you change code. A fix you cannot explain is a guess.

## The Iron Law

```
NO FIX WITHOUT ROOT-CAUSE INVESTIGATION FIRST
```

You MUST NOT propose or apply a fix until you have completed Phase 1 and can state the root cause. "It's probably X" is not a root cause.

## When to Use

You MUST use this skill for any technical failure: a test failure, a bug, unexpected behavior, a performance problem, a build failure, an integration issue.

This applies **especially** under pressure — an emergency, an "obvious quick fix", or after a previous fix failed — because those are exactly when guessing is most tempting and most costly. You MUST NOT skip it because the issue "seems simple" (simple bugs have root causes too) or because you are in a hurry (systematic is faster than thrashing).

## The Four Phases

You MUST complete each phase before the next.

### Phase 1 — Root-cause investigation (REQUIRED before any fix)

You MUST:

1. **Read the error completely.** Read the full message and stack trace; note line numbers, file paths, error codes. You MUST NOT skip past warnings — they often name the cause.
2. **Build a feedback loop that demonstrates the failure.** Reproduction is an artifact, not a claim: you MUST produce a command, test, or script that runs red for the bug's reason, and you MUST have observed its red output before proceeding — "I reproduced it" without a runnable loop does not pass this gate. When no obvious loop exists, read `@building-a-feedback-loop.md` for construction routes, loop tightening, and non-deterministic-bug amplification. For a **performance** problem the loop MUST be a measurement with a captured baseline — logs are the wrong instrument. If the failure is intermittent (a flaky test that passes sometimes), suspect a timing race rather than the code under test — when a test waits on an arbitrary delay, the root-cause fix is to wait on the real condition instead (see `@condition-based-waiting.md`). If after real effort no loop can be built, you MAY stop and escalate ONLY with a record of what you attempted and a concrete ask (exact logs, reproduction steps, environment details, or access you need), presented via the `confirming-with-the-user` skill — you MUST NOT guess at a fix for a failure you cannot trigger.
3. **Check recent changes.** Inspect the diff, recent commits, new dependencies, config, and environment differences for what could have introduced it.
4. **Instrument multi-component systems.** When the failure crosses component boundaries (e.g. CI → build → sign, or API → service → DB), before proposing a fix you MUST add diagnostic logging at each boundary (what enters, what exits, config/state at each layer), run once, and read the evidence to locate WHICH layer fails. You MUST NOT guess which layer is at fault. Where the boundary falls outside the area you are authorized to change, the instrumentation MUST stay observation-only: behavior unchanged, every edit carrying a searchable tag, nothing committed, and every probe removed and its removal verified before the work ends. The **fix** is never made under that latitude — it goes to whoever owns that area, through the host's own mechanism.
5. **Trace the bad value to its source.** When the error surfaces deep in the call stack, you MUST trace backward: where did the bad value originate? what passed it in? Keep going up until you reach the origin, and fix at the source — not where the symptom appears. When the chain is long or you cannot follow it by reading code, the concrete backward-tracing method — including how to instrument with a captured stack trace — is in `@root-cause-tracing.md`.

### Phase 2 — Pattern analysis

You MUST: find similar working code in the same codebase; if you are following a reference or pattern, read it **completely** (you MUST NOT skim); list **every** difference between the working and broken cases (you MUST NOT dismiss a difference as "that can't matter"); and identify the dependencies, config, and assumptions the code relies on.

### Phase 3 — Hypothesis and test

You MUST:

1. **Enumerate before testing.** List 3–5 candidate hypotheses and rank them by likelihood BEFORE testing any — anchoring on the first idea is how debugging sessions thrash. Each hypothesis MUST state a falsifiable prediction ("if X is the cause, then probe P will show Q"); a hypothesis with no prediction is a vibe, not a hypothesis. On a substantial bug you SHOULD share the ranked list with the user as a non-blocking checkpoint (keep working; their reply may re-rank).
2. Test the top hypothesis with the **smallest** possible change — one hypothesis at a time, one variable at a time. You MUST NOT change several things at once.
3. **Probe discipline.** Every probe you add MUST map to a specific hypothesis's prediction; you MUST NOT "log everything and grep". You SHOULD prefer a debugger or REPL over log statements where the host environment allows. Every temporary probe MUST carry one unique tag prefix (e.g. `DBG-<slug>`) so removal is verifiable later.
4. If it is confirmed → Phase 4. If not → move to the next ranked hypothesis; you MUST NOT pile another fix on top of a failed one.
5. If you do not understand something, you MUST say so and investigate further; you MUST NOT pretend to understand.

### Phase 4 — Implementation

You MUST:

1. **Reproduce with a failing test first.** Before changing production code, write the smallest test that reproduces the bug and watch it fail for the bug's reason. A fix without a reproducing test does not stick. You MAY proceed without a reproducing test ONLY when reproduction is genuinely impossible after real effort (a confirmed environmental, timing-dependent, or external cause — see "When Investigation Finds No Code Root Cause"), and only after you (1) summarize the complete reasons, (2) obtain the user's explicit permission, and (3) record those reasons in a comment in the relevant production code.
2. **Apply a single fix at the root cause.** One change, addressing the cause you identified. You MUST NOT bundle unrelated refactors or "while I'm here" improvements. *After* the root-cause fix is in and verified, when the bug was an invalid value reaching a dangerous operation you SHOULD additionally harden each layer that value crosses, so the class of bug becomes structurally impossible — see `@defense-in-depth.md`.
3. **Verify and clean up.** The reproducing test now passes, no other tests broke, and the original symptom is gone. Claim success only with this evidence in hand. Cleanup is part of verification: a grep for your probe tag MUST return nothing, throwaway harnesses and repro scripts MUST be deleted (or promoted into real tests deliberately), and the change description MUST state the confirmed root cause in one line.
4. **Ask the prevention question — after the fix lands.** What would have made this bug impossible or caught it earlier? A cheap hardening (a validation, an assertion, a lint rule) MAY follow as its own change; an architectural answer goes to the user via the `confirming-with-the-user` skill. You MUST NOT bundle the prevention work into the fix itself.
5. **If the fix fails, STOP and count.** Tried fewer than 3 fixes → return to Phase 1 with the new information. **Tried 3 or more → you MUST stop fixing and question the architecture** (below).

### When 3+ fixes have failed — question the architecture

Three or more failed fixes is a signal that the design, not the hypothesis, is wrong — especially when each fix exposes a new coupling or shared-state problem elsewhere, or each fix needs "massive refactoring". You MUST stop attempting fixes and raise the architectural question with the user: is this pattern sound, or are we fixing symptoms of a wrong design? You MUST NOT attempt fix #4 without that discussion.

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

## Rationalizations — rejected

| Excuse | Reality |
|--------|---------|
| "Too simple to need a process" | Simple issues have root causes too; the process is fast for them. |
| "Emergency, no time" | Systematic debugging is faster than guess-and-check thrashing. |
| "Try this first, investigate later" | The first fix sets the pattern. Do it right from the start. |
| "I'll add the test after it works" | An untested fix doesn't stick; the test-first proves the cause. |
| "Several fixes at once saves time" | You can't isolate what worked, and it breeds new bugs. |
| "The reference is long, I'll adapt it" | Partial understanding guarantees bugs. Read it fully. |
| "I see the problem" | Seeing the symptom is not understanding the cause. |
| "One more attempt" (after 3 failed fixes) | 3 failures = an architecture problem. Stop and question it; do not attempt a 4th. |

## When Investigation Finds No Code Root Cause

If a thorough investigation shows the cause is genuinely environmental, timing-dependent, or external, you MUST: document what you investigated; implement appropriate handling (retry / timeout / a clear error); and add logging for future diagnosis. This is the only path on which Phase 4's reproducing test may be skipped, and only through that step's escape clause (summarize the reasons, obtain the user's explicit permission, record them in a code comment). Most "no root cause" conclusions are incomplete investigation — you MUST first be sure you actually finished Phase 1.

## The Bottom Line

Find the cause, prove it, fix the cause, verify it. No guessing, no symptom patches, no fix #4 without questioning the design.
