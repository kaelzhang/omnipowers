# Fanning Work Out

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this once the Dispatch Block has found an idle ownership scope with queued work, before dispatching anything.

Before dispatching anything, you MUST confirm ALL of the following. Any one fails → the tasks are related, you MUST NOT parallelize them, and you MUST investigate them together first.

1. **No shared mutable state.** No two tasks edit the same file, resource, database row, or configuration.
2. **No sequential dependency.** No task needs another's output, side effect, or completion.
3. **Self-contained comprehension.** Each task is fully understandable from its own scope.
4. **No interference.** Concurrent agents cannot collide on locks, ports, build artifacts, or generated files.
5. **No ownership boundary crossed.** Every task falls inside the area you are authorized to change. The host assigns ownership of a directory to a team, a code owner, or another agent → that task is not yours to dispatch, however independent it is; route it to its owner through the host's own mechanism.

## When the host has no subagents

- The host provides subagents → dispatch one per independent domain.
- The host provides a way to hand a domain to its owner → use it for any domain outside your own area.
- Neither is available → process each independent domain sequentially yourself, applying the same focused-task discipline to each: fully scope, solve, and summarize one before starting the next. You MUST NOT skip or abandon the work.

The independence analysis, the per-domain constraints, and the integration review apply identically in every case; only the concurrency is dropped.

## Dispatching one agent

Each dispatch MUST carry: the one problem it owns, the files or scope it may touch, what it MUST NOT touch, the verification it must run, and the report it must return. You MUST NOT dispatch an agent that shares a file with another in-flight agent.
