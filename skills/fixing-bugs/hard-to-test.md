# When the Regression Test Is Hard to Write

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Read this when the reproducing test resists being written.

| Friction | What to do |
|---|---|
| The test needs elaborate setup — the unit does too much / is too coupled | Extract helpers; consider splitting the unit. |
| You must mock almost everything — the code depends on concretes, not interfaces | Inject the dependency instead of reaching for it. |
| You cannot isolate the bug in a test — the responsibility is smeared across layers | Narrow the seam; test at the level the defect lives. |

- Friction does not waive the Iron Law → you MUST still write the reproducing test, and the fix may need a small structural change to make that test writable.
- No correct seam exists (the only way to test would couple to internals) → you MUST record the seam gap and raise it with the user after the fix lands, and you MUST NOT skip the test or test through internals.
