# When the Regression Test Is Hard to Write

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

The reproducing test resists being written → you MUST still write it.

No correct seam exists (the only way to test would couple to internals) → you MUST record the seam gap and raise it with the user after the fix lands.

No correct seam exists (the only way to test would couple to internals) → you MUST NOT skip the test or test through internals.
