# Investigating a Root Cause

> Normative keywords — MUST, MUST NOT, SHOULD, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Read this when the cause is not evident from the failing test. You MUST complete it before any fix.

## Gather the evidence

1. **Read the error completely.** The full message and stack trace; line numbers, file paths, error codes. You MUST NOT skip past warnings.
2. **Check recent changes.** Inspect the diff, recent commits, new dependencies, config, and environment differences for what could have introduced it.
3. **Instrument across component boundaries.** The failure crosses components → before proposing a fix you MUST add diagnostic logging at each boundary — what enters, what exits, config and state at each layer — run once, and read the evidence to locate WHICH layer fails. You MUST NOT guess which layer is at fault.
   - The boundary falls outside the area you are authorized to change → the instrumentation MUST stay observation-only: behavior unchanged, every edit carrying a searchable tag, nothing committed, every probe removed and its removal verified before the work ends. The fix itself is never made under that latitude; it goes to whoever owns that area, through the host's own mechanism.
4. **Trace the bad value to its source.** The error surfaces deep in the call stack → you MUST trace backward: where the bad value originated, and what passed it in. Keep going up until you reach the origin. The chain is long, or you cannot follow it by reading code → read `@root-cause-tracing.md` and apply it.

## Compare against what works

You MUST find similar working code in the same codebase; read any reference or pattern you are following **completely**, never skimmed; list **every** difference between the working and broken cases, and you MUST NOT dismiss a difference as "that can't matter"; and identify the dependencies, config, and assumptions the code relies on.

## Hypothesis and test

1. **Enumerate before testing.** List 3–5 candidate hypotheses and rank them by likelihood BEFORE testing any. Each MUST state a falsifiable prediction — "if X is the cause, probe P will show Q". The bug is substantial → you SHOULD share the ranked list with the user as a non-blocking checkpoint: keep working; their reply may re-rank.
2. Test the top hypothesis with the **smallest** possible change — one hypothesis at a time, one variable at a time. You MUST NOT change several things at once.
3. **Probe discipline.** Every probe MUST map to a specific hypothesis's prediction; you MUST NOT "log everything and grep". You SHOULD prefer a debugger or REPL where the host allows. Every temporary probe MUST carry one unique tag prefix (e.g. `DBG-<slug>`) so removal is verifiable later.
4. The hypothesis is confirmed → return to the fix cycle. It is not → move to the next ranked hypothesis; you MUST NOT pile another fix on top of a failed one.

## When 3+ fixes have failed — question the architecture

Three or more failed fixes → you MUST stop attempting fixes and raise the architectural question with the user: is this pattern sound, or are we fixing symptoms of a wrong design? The signal is strongest when each fix exposes a new coupling or shared-state problem elsewhere, or each fix needs "massive refactoring". You MUST NOT attempt fix #4 without that discussion.

## When there is no code root cause

A thorough investigation shows the cause is genuinely environmental, timing-dependent, or external → you MUST document what you investigated, implement appropriate handling (retry, timeout, or a clear error), and add logging for future diagnosis. This is the only path on which the reproducing test may be skipped, and only through the Only Exception the fix cycle defines. You MUST first be sure this investigation is actually finished.
