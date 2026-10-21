# Building a Feedback Loop

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Feedback loop — one command that goes red on this bug, goes green once it is fixed, and runs unattended.

## The menu — try routes cheapest-first

You MUST have a working loop before you form hypotheses. The loop MUST produce its route's red signal, not merely "ran".

1. Failing test — a test at a seam reaching the bug, run through the host project's test runner; red signal: the assertion on the symptom fails.
2. HTTP script — a `curl`/`httpie` script against a locally running server; red signal: wrong status code or response body.
3. CLI invocation + snapshot diff — a program run on a fixture input with stdout/stderr/exit code compared against a known-good snapshot; red signal: non-empty diff.
4. Headless browser script — UI automation with assertions on DOM state, console errors, or network traffic; red signal: the assertion fails.
5. Trace / log replay — a captured request, payload, or event log replayed through the failing code path in isolation; red signal: the wrong output.
6. Throwaway harness script — a script booting enough of the system to hit the bug with a single call; red signal: the wrong result.
7. Property / fuzz loop — generated inputs checked against the property the bug violates when the symptom is "sometimes wrong output"; red signal: a counterexample.
8. Bisection harness — a script checking states between known-good and known-bad commits, datasets, or versions; exit 0: good; red signal: exit 1.
9. Differential loop — the same input passed through two implementations or configurations with outputs compared; red signal: non-empty diff.
10. Human-in-the-loop script — a script driving a human through an exact checklist and recording observations for a physical device, credentials the agent cannot handle, or an environment only the user can reach.

Throwaway loop artifacts — replay captures, harness scripts, and the human-in-the-loop script; role: **scratch**.

Throwaway loop artifacts MUST live inside the host project — where its `Omnipowers` declaration puts `scratch`, otherwise under `.omnipowers/debug/` — and MUST be deleted when debugging ends.

Every route exhausted → you MUST stop and tell the user explicitly: list what you tried, and ask for an environment that reproduces the failure, a captured artifact (log dump, trace, recording), or permission to add temporary instrumentation. You MUST NOT proceed to hypotheses without a loop.

## Route 10 — the human-in-the-loop script

Any automated route above remains untried → you MUST NOT fall back to the human-in-the-loop route.

For the human-in-the-loop route → the script MUST capture observations, not only issue instructions.

## Template

```bash
#!/usr/bin/env bash
# Human-in-the-loop reproduction checklist.
# The agent edits the steps; the human runs the script and follows the prompts.
# Captured answers print as KEY=VALUE lines for the agent to parse.
set -euo pipefail

step()    { printf '\n>>> %s\n' "$1"; read -r -p "    [Enter when done] " _; }
capture() { local v="$1"; printf '\n>>> %s\n' "$2"; read -r -p "    > " a; printf -v "$v" '%s' "$a"; }

# --- edit the checklist below -------------------------------------------
step    "Start the app and sign in as a regular user."
capture FAILED   "Trigger <the exact action>. Did the failure occur? (y/n)"
capture EVIDENCE "Paste the exact error message or wrong value (or 'none'):"
# --- end checklist -------------------------------------------------------

printf '\n--- captured ---\n'
printf 'FAILED=%s\nEVIDENCE=%s\n' "$FAILED" "$EVIDENCE"
```

## Tighten the loop before testing hypotheses

- Before hypothesis testing → the loop MUST assert the user's exact symptom — the specific wrong value, missing error, or timing — and MUST NOT settle for "did not crash".
- Before hypothesis testing, for bugs that are not themselves non-deterministic → the loop MUST give the same verdict on every run: pin the clock, seed random number generators, isolate the filesystem, stub or freeze the network.
- Before hypothesis testing → the loop SHOULD complete in seconds: cache setup, skip unrelated initialization, narrow the scope to the failing path.

## Non-deterministic bugs — amplify the reproduction rate

The failure is intermittent → you MUST NOT hypothesis-test against a rate too low to distinguish signal from luck.

The intermittent failure is a test waiting on an arbitrary delay → read `@condition-based-waiting.md` and apply it.

## Minimise — every remaining element load-bearing

The loop goes red reliably → you MUST shrink the reproduction before Phase 3: remove inputs, data, config, steps, and code **one element at a time**, re-running the loop after each removal.

Minimal reproduction — a reproduction for which removing any remaining element makes the failure disappear.

The reproduction does not meet the minimal-reproduction criterion → you MUST NOT declare minimisation done.
