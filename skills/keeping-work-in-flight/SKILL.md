---
name: keeping-work-in-flight
description: Use at every agent or background-task return and before ending any round, and whenever 2+ separate problems could run at once (different test files, subsystems, bugs) — you MUST count what is still running, dispatch one tracked call per idle ownership scope before reading any report, and never leave work running whose completion cannot wake you
---

# Keeping Work In Flight

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
DISPATCH BEFORE YOU READ — COUNT BEFORE YOU FINISH — ONLY A TRACKED CALL WAKES YOU
```

## The Dispatch Block

Run these four steps in order at both of these moments: an agent, subagent, or background task returns; a round is about to end. You MUST run them before reading any report and before writing any part of your reply.

1. **Count what is still running, and what is queued.** Queued work with nothing running is the condition this block exists to catch. Nothing queued is a finished round, not a failure.
2. **List every ownership scope that is idle and has queued work.** Each one is wasted wall-clock.
3. **Dispatch one tracked call per idle scope.** One scope, one call.
4. **Now** read the reports, judge, and write.

A returned report is not a reason to stop → it is the trigger to run this block again.

## One tracked call per scope

- Dispatching N units of work → you MUST issue N separate tracked calls.
- A shell loop that backgrounds N processes inside one call → you MUST NOT use it. The host cannot list those processes, and their completion does not re-invoke you.
- You need the task's result → that task MUST be the tracked call itself.
- You need only that a process stays alive — a server, a device, a daemon, anything with no result to wait for → detach it. It MUST outlive the shell that started it.

## Before You Dispatch

The block found an idle scope with queued work → read `@fanning-out.md` and apply it: it carries the independence precondition every candidate MUST pass, what each dispatch MUST carry, and what to do when the host has no subagents.

## Continuation — work that outlives the round

- Finishable this round → finish it. No mechanism.
- Blocked on an external event that completes later — a CI run, a long build, a dispatched agent → use the host's tracked asynchronous mechanism, so its completion wakes you.
- Spans sessions by nature — a long migration, a recurring audit → use the mechanism the host declares under `continuation`.
- The host declares none → write the next step into the host's work-state document and state that the round ends there.
- Continuation carries an objective the user has already approved → you MUST NOT use it to proceed past a decision the user owns.

## Heartbeat

- You MAY install a periodic report that states only: how many tasks are running, which scopes are idle, the last commit, and the number of unpushed commits.
- That report MUST NOT edit, commit, dispatch, or change any state. A heartbeat that acts is a second uncoordinated writer and stops being a trustworthy observer.
- A heartbeat catches idling after the fact → you MUST NOT treat it as replacing the Dispatch Block.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "I'll read this report first, then see what else to start." | Run the Dispatch Block first. Reading comes fourth. |
| "A loop is quicker than six separate calls." | Issue six tracked calls. A loop's processes cannot wake you. |
| "Nothing is running, but I'm nearly done anyway." | Zero running is the condition the block exists to catch. Dispatch, then finish. |
| "I'll wait for this agent to come back." | You do not wait. Dispatch every idle scope, then read what returned. |
| "These two tasks barely overlap." | Overlap fails the precondition. Do not parallelize them. |
| "That directory belongs to another owner, but it's a tiny change." | Route it to its owner. Independence is not authority. |
| "I'll note the next step in my reply." | A reply is not state. Write it into the host's work-state. |
| "The heartbeat will catch it if I stall." | The heartbeat reports; it does not dispatch. Run the block. |

## Checklist

Before ending a round, confirm:

- [ ] I ran the Dispatch Block at every agent return and before ending this round.
- [ ] Every idle ownership scope with queued work received its own tracked call.
- [ ] No work was launched through a shell loop or any untracked background form.
- [ ] Every task whose result I need is itself a tracked call.
- [ ] Work that outlives this round is on the host's continuation mechanism, or its next step is written into the host's work-state.
