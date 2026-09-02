# Defense-in-Depth Validation

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this technique at the HARDEN step of `fixing-bugs`, after you have fixed a bug caused by an invalid value, when you want that class of bug to become **structurally impossible** rather than merely fixed at one spot.

## Core principle

You SHOULD validate at **every layer the data passes through**, so that no path can reintroduce the bad value. You MUST NOT treat one validation point as enough for a bug that has already shipped once.

## The layers

Map the value's path from where it enters to where it is used, and add a guard at each distinct layer it crosses. The four common layers:

1. **Entry-point validation** — at the API/boundary, reject obviously invalid input immediately (empty, missing, wrong type, nonexistent target).
2. **Business-logic validation** — inside the operation, assert the value makes sense for *this* use, even if the entry point was bypassed (e.g. by a caller that constructed the object directly or a mock).
3. **Environment/context guards** — refuse a dangerous operation in a context where it must never happen (e.g. refuse a destructive filesystem or network operation unless the target is within an expected sandbox/scope).
4. **Diagnostic instrumentation** — log the key value and the call site just before the dangerous operation, so the forensic trail exists if every guard above is bypassed.

## Applying it

1. **Trace the data flow** (see `@root-cause-tracing.md`) — where the bad value originates and every point it passes through.
2. **List the checkpoints** — each layer between origin and use.
3. **Add a guard at each layer**, failing loudly with a message that names the value and why it is invalid.
4. **Test each guard independently** — bypass layer 1 and confirm layer 2 still catches it.
