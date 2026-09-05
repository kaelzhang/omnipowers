# Dispatch Mechanics

> Normative keywords — MUST, MUST NOT, SHOULD, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Read this when choosing a background form, waiting on a dispatch, or ending one.

## The four forms

The distinction is not `&` versus no `&`. It is whether the host lists the dispatch as active work.

| Form | Wakes you | Use it for |
| --- | --- | --- |
| the host's tracked background form, listed as active work | yes, on exit | anything whose result you need |
| `(cmd &)` or `nohup cmd & disown` inside a foreground call | no | only a process you need alive, never a result |
| a form that detaches into its own session (`setsid cmd &`) | no, and it reports completion within seconds while the process runs on | nothing |
| a foreground call that exceeded its timeout | it keeps its identity | read its output file; you MUST NOT assume it finished |

The third form is the dangerous one: it looks tracked and is not. You MUST NOT use it.

The tracked form carries one command, so N dispatches cost N calls. A loop that spawns N processes inside one call costs one call and loses every wake-up: the call returns, and the work that finishes afterward is collected by nobody.

## Delegated command-line runs

- A delegated run inherits the caller's stdin → you MUST close it explicitly. Left open, the run blocks forever with no output and no error.
- The report MUST be written to a file the run names, not to standard output. Output that exists only in a returned stream does not survive the call that made it.

## Ending one

- A signal sent to a bare process id reaches every process sharing that id's process group. You MUST target the single process, and you MUST then verify that only it died.
- You MUST NOT end a process you did not start without establishing what depends on it. Ending a supervisor orphans what it supervised, leaving a live process nothing can reach.

## Waiting

Polling is the fallback for work that could not be tracked — an already-running process, something started outside this session, a resource you do not own. Work you are about to start MUST be launched in the tracked form instead; you MUST NOT poll what you could have been notified about.

No tracked form covers it AND the host forbids a foreground wait → poll with a bounded loop, and treat exhausting the bound as a result, not as failure to wait longer.

```bash
for i in $(seq 1 9); do
  ps ax -o command= | awk '$1 ~ /cargo$/ {f=1} END {exit !f}' || break
  sleep 10
done
```

Match on the executable, never on the whole command line. A pattern passed as an argument appears in the argument list of the process doing the searching, so a whole-line match finds at least itself and reports one process too many. You MUST NOT act on a count that includes the search.
