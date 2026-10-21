# Fanning Work Out

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

The Dispatch Block found an idle ownership scope with queued work, before dispatching anything → you MUST confirm all of the following:

1. No two tasks edit the same file, resource, database row, or configuration.
2. No task needs another's output, side effect, or completion.
3. Each task is fully understandable from its own scope.
4. Concurrent agents cannot collide on locks, ports, build artifacts, or generated files.
5. Every task falls inside the area you are authorized to change; a task's directory is assigned to a team, a code owner, or another agent → route it to its owner through the host's own mechanism.

Any confirmation fails → you MUST NOT parallelize the tasks, and you MUST investigate them together first.

## When the host has no subagents

Neither subagents nor a way to hand a domain to its owner is available → you MUST NOT skip or abandon the work.

## Dispatching one agent

- Dispatching one agent → the dispatch MUST carry: the one problem it owns, the files or scope it may touch, what it MUST NOT touch, the verification it must run, and the report it must return.
- An agent shares a file with another in-flight agent → you MUST NOT dispatch it.
