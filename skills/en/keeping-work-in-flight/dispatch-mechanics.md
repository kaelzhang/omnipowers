# Dispatch Mechanics

> Normative keywords — MUST, MUST NOT, SHOULD, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The four forms

Tracked background form — the host's background form listed as active work, with a wake-up on exit.

Detached foreground form — `(cmd &)` or `nohup cmd & disown` inside a foreground call, without a wake-up.

Session-detached form — a form such as `setsid cmd &` that detaches into its own session and reports completion within seconds while the process runs on, without a wake-up.

Timed-out foreground call — a foreground call that exceeded its timeout and retains its identity.

- A foreground call exceeded its timeout → you MUST NOT assume it finished.
- A form is session-detached → you MUST NOT use it.

## Delegated command-line runs

- A delegated run inherits the caller's stdin → you MUST close it explicitly.
- A delegated command-line run produces a report → the report MUST be written to a file the run names, not to standard output.

## Ending one

- Ending a process → you MUST target the single process, and you MUST then verify that only it died.
- You did not start a process → you MUST NOT end it without establishing what depends on it.

## Waiting

- You are about to start work → the work MUST be launched in the tracked form.
- You could have been notified about work → you MUST NOT poll it.

```bash
for i in $(seq 1 9); do
  ps ax -o command= | awk '$1 ~ /cargo$/ {f=1} END {exit !f}' || break
  sleep 10
done
```

A process count includes the search → you MUST NOT act on that count.
