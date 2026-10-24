---
name: keeping-work-in-flight
description: Use once per session, the first time you start a long-running command, background job, or subagent, or a task returns, or when asked to work in parallel ("并行工作"); it then governs every return and round end — you MUST launch work in the form the host tracks so its completion wakes you, never a backgrounded process you poll, and MUST count what is still running before reading any report
---

# Keeping Work In Flight

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
DISPATCH BEFORE YOU READ — COUNT BEFORE YOU FINISH — ONLY A TRACKED CALL WAKES YOU
```

## The Dispatch Block

An agent, subagent, or background task returns, or a round is about to end → you MUST run these four steps in order before reading any report and before writing any part of your reply:

1. Count what is still running and what is queued.
2. List every ownership scope that is idle and has queued work.
3. Dispatch one tracked call per idle scope.
4. Read the reports, judge, and write.

Nothing is queued → before calling the round finished, you MUST check whether what you are about to do next splits into pieces that could run at once.

Independence test — `@fanning-out.md`, applicable when checking whether the next work splits into concurrent pieces.

## Launch it in the tracked form

- You are about to start work that outlives the call starting it → you MUST launch it in the form the host lists as active work and whose completion re-invokes you.
- A tracked form exists → you MUST NOT background the work and poll it, and you MUST NOT schedule a wake-up to check on it.
- You cannot say where the host lists this work as running → you MUST NOT treat "it is running somewhere" as dispatched.
- A dispatch is tracked → you MUST NOT wait on it, by a PID wait, a poll loop, a sleep-and-check, or any other means.

## One tracked call per scope

- Dispatching N units of work → you MUST issue N separate tracked calls.
- A shell loop backgrounds N processes inside one call → you MUST NOT use it.
- You need the task's result → that task MUST be the tracked call itself.
- You need only that a process stays alive, with no result to wait for → it MUST outlive the shell that started it.
- A form reports completion within seconds while its process runs on → you MUST NOT use it.

- Choosing a background form, closing a delegated run's stdin, polling one, or ending one → read `@dispatch-mechanics.md` and apply it.
- You are a Claude Code agent about to launch a `codex exec` run → read `@codex-from-claude-code.md` and apply it.

## Before You Dispatch

The block found an idle scope with queued work → read `@fanning-out.md` and apply it: every candidate MUST pass its independence precondition, and each dispatch MUST carry what it specifies, including when the host has no subagents.

## Continuation — work that outlives the round

Continuation carries an objective the user has already approved → you MUST NOT use it to proceed past a decision the user owns.

## Heartbeat

- You MAY install a periodic report that states only: how many tasks are running, which scopes are idle, the last commit, and the number of unpushed commits.
- A periodic report is installed → that report MUST NOT edit, commit, dispatch, or change any state.
- A heartbeat catches idling after the fact → you MUST NOT treat it as replacing the Dispatch Block.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "I'll read this report first, then see what else to start." | Run the Dispatch Block first. |
| "A loop is quicker than six separate calls." | Issue six tracked calls. |
| "I'll kick this build off in the background and check on it later." | Launch it in the tracked form. |
| "I'll schedule a wake-up to see whether it finished." | Relaunch it tracked. |
| "It's one long command, not parallel work — this doesn't apply." | Choose the tracked form per dispatch. |
| "Launched it tracked, now I'll wait on the PID until it finishes." | Launch and move on. |
| "The subagents are tracked; my own background script is different." | Launch your own script in the tracked form. |
| "It's quicker to just work through these one at a time." | Split first, then dispatch. |
| "Nothing is running, but I'm nearly done anyway." | Dispatch, then finish. |
| "I'll wait for this agent to come back." | Dispatch every idle scope, then read what returned. |
| "These two tasks barely overlap." | Do not parallelize them. |
| "That directory belongs to another owner, but it's a tiny change." | Route it to its owner. |
| "I'll note the next step in my reply." | Write it into the host's work-state. |
| "The heartbeat will catch it if I stall." | Run the block. |
