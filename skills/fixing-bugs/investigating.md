# Investigating a Root Cause

> Normative keywords — MUST, MUST NOT, SHOULD, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

The cause is not evident from the failing test → you MUST complete this investigation before any fix.

## Gather the evidence

- When reading the error → you MUST NOT skip past warnings.
- The failure crosses components → before proposing a fix you MUST add diagnostic logging at each boundary — what enters, what exits, config and state at each layer — run once, and read the evidence to locate which layer fails.
- The failure crosses components → you MUST NOT guess which layer is at fault.
- The boundary falls outside the area you are authorized to change → the instrumentation MUST stay observation-only: behavior unchanged, every edit carrying a searchable tag, nothing committed, every probe removed and its removal verified before the work ends.
- The error surfaces deep in the call stack → you MUST trace backward: where the bad value originated, and what passed it in.

The call chain is long, or you cannot follow it by reading code → read `@root-cause-tracing.md` and apply it.

## Compare against what works

You MUST find similar working code in the same codebase, read any reference or pattern you are following completely, list every difference between the working and broken cases, and identify the dependencies, config, and assumptions the code relies on.

When comparing differences → you MUST NOT dismiss a difference as "that can't matter".

## Hypothesis and test

- Each candidate hypothesis MUST state a falsifiable prediction — "if X is the cause, probe P will show Q".
- The bug is substantial → you SHOULD share the ranked list with the user as a non-blocking checkpoint while continuing work.
- When testing a hypothesis → you MUST NOT change several things at once.
- Every probe MUST map to a specific hypothesis's prediction.
- When probing → you MUST NOT "log everything and grep".
- The host allows a debugger or REPL → you SHOULD prefer one.
- Every temporary probe MUST carry one unique tag prefix.
- A hypothesis has failed → you MUST NOT pile another fix on top of the failed one.

## When 3+ fixes have failed — question the architecture

Three or more failed fixes → you MUST stop attempting fixes and raise the architectural question with the user: is this pattern sound, or are we fixing symptoms of a wrong design?

Before that discussion → you MUST NOT attempt fix #4.

## When there is no code root cause

The completed investigation identifies an environmental, timing-dependent, or external cause → you MUST document what you investigated, implement appropriate handling (retry, timeout, or a clear error), and add logging for future diagnosis.

Before concluding there is no code root cause → you MUST first be sure this investigation is actually finished.
