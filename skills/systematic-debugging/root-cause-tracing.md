# Root-Cause Tracing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this technique during **Phase 1** of `systematic-debugging` when the failure surfaces **deep in the call stack** and it is not obvious where the bad value came from. It is the concrete method behind the Phase 1 rule "trace the bad value to its source."

## Core principle

A bug usually *manifests* deep in the stack (a file written to the wrong path, a record opened with the wrong key, a request sent to the wrong host) but *originates* somewhere upstream. You MUST trace backward through the call chain to the original trigger and fix there. You MUST NOT fix only where the error appears — that patches a symptom and leaves the cause live.

## The tracing process

1. **Observe the symptom precisely.** Capture the exact failing operation and its inputs — e.g. "init ran in the source directory instead of a temp directory."
2. **Find the immediate cause.** Identify the single line/operation that directly produces the wrong result, and the exact value it received.
3. **Ask "what called this, and what value did it pass?"** Step up one frame. Record the value at that frame.
4. **Keep tracing up** one frame at a time, following the bad value, until you reach the frame where the value was *first* produced (a default, an uninitialized field, an external input, a wrong argument).
5. **Fix at that origin.** Correct where the bad value is born, not where it lands. Then consider hardening every layer it passed through (see `@defense-in-depth.md`).

## When you cannot trace by hand — instrument

If the chain is too long or dynamic to follow by reading code, add temporary instrumentation at the point of the dangerous operation, then run once and read the evidence:

- **Capture a full stack trace at the failure point.** Most languages expose the current call stack (e.g. raising/constructing an exception object and reading its trace, or a runtime stack API). Log it *before* the dangerous operation runs — not after it fails — together with the suspect value and relevant environment/config.
- **Write to a stream you will actually see.** In test runs, write to the process's error stream (or an unbuffered channel) rather than an app logger that the test harness may suppress.
- **Run once and filter** for your marker (e.g. grep the combined output for a unique tag you logged), then read the captured stack to locate the originating frame.
- **Remove the instrumentation** once you have the origin; it is a probe, not a fix.

## Finding which test or caller pollutes shared state

When a bad value or artifact appears only sometimes (e.g. under the full suite but not in isolation), the cause is usually order-dependent pollution from another caller. Bisect to find it: run the suite in halves, then quarters, narrowing to the first unit whose presence reproduces the pollution. A scripted bisection (run units one group at a time, stop at the first group that reproduces) finds the culprit fast; keep any such helper inside the host project, not as a dependency of this skill.

## The discipline

```
Found the immediate cause
      │
      ▼
Can you trace one level up?  ──no──▶  you are at the source → fix here
      │ yes
      ▼
Trace backward, following the bad value
      │
      ▼
Is this where the value was first produced?  ──no──▶  keep tracing
      │ yes
      ▼
Fix at the source, then harden each layer it crossed (defense-in-depth)
```

You MUST NOT stop tracing at the first frame you *can* edit; stop at the frame where the bad value *originates*.
