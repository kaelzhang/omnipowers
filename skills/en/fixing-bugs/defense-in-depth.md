# Defense-in-Depth Validation

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

You SHOULD validate at every layer the data passes through.

The bug has already shipped once → you MUST NOT treat one validation point as enough.

When tracing the invalid value's origin and every point it passes through → read `@root-cause-tracing.md` and apply it.
