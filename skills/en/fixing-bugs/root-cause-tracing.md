# Root-Cause Tracing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Core principle

You MUST trace backward through the call chain to the original trigger and fix there. You MUST NOT fix only where the error appears.

The origin has been fixed and hardening the layers it passed through is under consideration → read `@defense-in-depth.md` and apply it.

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

You MUST NOT stop tracing at the first frame you can edit.
