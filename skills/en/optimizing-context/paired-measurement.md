# Paired Context Measurement

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Pinning Both Sides

Paired run — two fresh-session dispatches of the identical task brief against the before and after Git trees, holding runner, CLI version, model, reasoning effort, tool surface, sandbox, working directory, and initial fixture constant.

- Measuring input token changes → you MUST run paired runs rather than comparing across different runners, models, or prompt texts.
- Before dispatching either side → you MUST verify `git rev-parse "<rev>^{tree}"` and read static file bytes from `git show "<rev>:<path>"`, resolving symlinks within that revision.
- A simultaneous architecture change would confound the instruction change → you SHOULD measure an instructions-only commit pair separately.
- Run-to-run variance can flip the verdict → you SHOULD run 3 or more repetitions per task and compare medians.

## Procedure

```text
for revision in [before, after]:
    verify git rev-parse "<revision>^{tree}" matches the pinned tree
    for each role and representative task (design, review, test, fix):
        compute static resident bytes (root + role + declared preloads)
        compute static entry-set bytes (resident + domain + target module contract)
        launch a fresh session with the identical brief and runner flags
        retain the raw event stream, final output, and exit status
        record first_input (total input of request 1, including cache read and write)
        record cumulative_input, uncached_input, cache_read, and cache_write separately
        count explicit file reads and failed path lookups
        verify expected rules surfaced with citations and unrelated packs stayed unloaded
```

## Accounting & Acceptance

- Recording `first_input` or `cumulative_input` → you MUST include cached creation and cached read tokens alongside uncached tokens, and reconcile request sums against the session's final usage record.
- Designing the task set → you MUST list expected applicable rules before running, and include at least one negative control per conditional pack to confirm irrelevant packs do not load.
- Either side hits a permission error, missing fixture, or incomplete task outcome → you MUST fix the harness and rerun before comparing token totals.
- Accepting the optimization → target resident or cumulative input MUST improve in the intended launch mode, missed applicable rules MUST NOT increase, and any per-task regression MUST be reported explicitly rather than hidden inside an average.
