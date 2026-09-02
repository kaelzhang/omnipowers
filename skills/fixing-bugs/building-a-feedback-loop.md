# Building a Feedback Loop

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this reference at the REPRODUCE step of `fixing-bugs` when you must "reproduce it consistently" and no reproduction route is obvious. A feedback loop is **one command** that goes red on *this* bug, goes green once it is fixed, and runs unattended.

## The menu — try routes cheapest-first

You MUST have a working loop before you form hypotheses. Work down this menu in order and take the **first** route that reaches the bug's code path. Each route's red signal is named; the loop MUST produce that signal, not merely "ran".

1. **Failing test** — a test at whatever seam reaches the bug (unit, integration, e2e), run through the host project's own test runner. Red = the assertion on the symptom fails.
2. **HTTP script** — a `curl`/`httpie` script against a locally running server. Red = wrong status code or response body.
3. **CLI invocation + snapshot diff** — run the program on a fixture input and diff stdout/stderr/exit code against a known-good snapshot. Red = non-empty diff.
4. **Headless browser script** — drive the UI with the host project's browser automation (e.g. Playwright, Puppeteer) and assert on DOM state, console errors, or network traffic. Red = the assertion fails.
5. **Trace / log replay** — capture a real request, payload, or event log to disk once, then replay it through the failing code path in isolation. Red = replay reproduces the wrong output.
6. **Throwaway harness script** — a minimal script that boots just enough of the system (one service, stubbed dependencies) to hit the bug with a single call. Red = the call returns the wrong result.
7. **Property / fuzz loop** — the symptom is "sometimes wrong output" → run many generated inputs and assert the property the bug violates. Red = any counterexample; keep the failing input as a fixture.
8. **Bisection harness** — the bug appeared between two known-good/known-bad states (commit, dataset, version) → wrap the check in a script that exits 0 on good and 1 on bad so `git bisect run` can drive it. Red = exit 1.
9. **Differential loop** — run the same input through the old and the new implementation (or two configs) and diff the outputs. Red = non-empty diff.
10. **Human-in-the-loop script** — last resort; see below.

Throwaway artifacts a loop needs (replay captures, harness scripts, the human-in-the-loop script) are **scratch**: they MUST live inside the host project — where its `Omnipowers` declaration puts `scratch`, otherwise under `.omnipowers/debug/` — and MUST be deleted when debugging ends. A failing test (route 1) is not throwaway: it stays in the suite as the regression test.

Every route exhausted → you MUST stop and tell the user so explicitly: list what you tried, and ask for an environment that reproduces the failure, a captured artifact (log dump, trace, recording), or permission to add temporary instrumentation. You MUST NOT proceed to hypotheses without a loop.

## Route 10 — the human-in-the-loop script

A step genuinely requires a human (a physical device, credentials you must not handle, an environment only the user can reach) → the loop is still a script: it drives the *human* through an exact checklist and records their observations. You MUST NOT fall back to this route while any automated route above remains untried, and the script MUST capture observations, not only issue instructions.

Template (copy into the host project and edit the checklist):

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

Before hypothesis testing, tighten on three axes:

- **Sharper.** The loop MUST assert the user's exact symptom — the specific wrong value, missing error, or timing — and MUST NOT settle for "did not crash".
- **Deterministic.** The loop MUST give the same verdict on every run: pin the clock, seed random number generators, isolate the filesystem, stub or freeze the network. (For bugs that are themselves non-deterministic, see the next section.)
- **Faster.** The loop SHOULD complete in seconds: cache setup, skip unrelated initialization, narrow the scope to the failing path. How far you can push this varies by system.

## Non-deterministic bugs — amplify the reproduction rate

The failure is intermittent → the target is a **measured reproduction rate high enough to test hypotheses against**, not an immediate clean repro. You MUST NOT hypothesis-test against a rate too low to distinguish signal from luck.

1. **Count, don't eyeball.** Wrap the trigger in a loop of N runs and report `failures/N`. That ratio is your red signal: a hypothesis is supported when acting on it moves the ratio; "fixed" is a measured drop to 0/N over a large N, not one lucky green run.
2. **Amplify until debuggable.** Raise the rate by tightening the timing window (inject delays or yields at suspected race points), adding load and parallelism, and controlling the seed (iterate over seeds, then pin the one that fails). Keep amplifying until each verdict is affordable.
3. **Flaky tests specifically.** The intermittent failure is a test waiting on an arbitrary delay → the root-cause fix is to wait on the real condition; read `@condition-based-waiting.md`.

## Minimise — every remaining element load-bearing

The loop goes red reliably → you MUST shrink the reproduction before Phase 3: remove inputs, data, config, steps, and code **one element at a time**, re-running the loop after each removal. The loop stayed red → the element was noise, keep it removed. The loop went green → the element is load-bearing, restore it.

**Completion criterion:** the reproduction is minimal exactly when removing *any* remaining element makes the failure disappear — "looks small" is not the criterion. You MUST NOT declare minimisation done without meeting it. The minimal reproduction is what becomes the failing regression test in Phase 4.
