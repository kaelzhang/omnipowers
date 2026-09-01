---
name: continuous-work-mode
description: Use when the user explicitly starts or ends continuous work mode — "进入连续工作模式", "continuous work mode", "keep going until everything is done, stop asking me" — you MUST install a stop-time gate that runs the checkpoint before any round can end, and while the mode is armed you MUST NOT end a round to ask whether to continue
---

# Continuous Work Mode

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
THE QUEUE IS CHECKED BY A COMMAND, NOT BY MEMORY — REPORTING IS THE LAST STEP, NEVER THE DELIVERABLE
```

A rule that must be recalled while writing a completion summary is recalled least often, because that is the moment of finishing something. This mode replaces the recollection with a gate the host runs.

## When to Use

- The user starts the mode in this session → you MUST arm it before the next unit of work.
- The user ends it, or the goal it was armed for is delivered → you MUST disarm it.
- The user has not asked for it → you MUST NOT arm it. An armed gate changes when the host lets a round end, and that is the user's decision.

## Arming the Mode

1. **Install the gate, once per project.** The gate is absent → read `@installing-the-gate.md` and install it. Installing writes to the host's configuration → you MUST obtain the user's explicit consent first, stating the file you will change.
2. **Write the sentinel** at `<project-root>/.omnipowers/continuous-mode`. The gate is inert while this file is absent, so the mode is armed and disarmed by this file alone:

```
base=<the commit the mode starts from>
defects=<path to a checklist file>      # optional, repeatable
repo=<path to another repo to watch>    # optional, repeatable
```

3. **Confirm in one line** what the mode was armed for, and continue working in the same reply. You MUST NOT end the round on the confirmation.

`.omnipowers/` is the workbench: it MUST be git-ignored, and the sentinel MUST NOT be committed.

## The Order

A task returns, or a round is about to end:

1. Run the checkpoint — `@checkpoint.sh`, or the command the gate reports.
2. Run the Dispatch Block of the `keeping-work-in-flight` skill. That skill owns counting and dispatching; this mode owns only that the check happens before the reply.
3. Clear what the checkpoint found and can be cleared now.
4. **Then** write the report.

You MUST NOT read a returned report, and MUST NOT write any part of a reply, before steps 1 and 2. A report is the sentence that follows the work; it is not the work.

## What the Checkpoint Reports

- uncommitted changes, per module, in every watched repo;
- commits that exist only locally, and branches never pushed;
- untracked files that committed code already references;
- open items on the declared defect checklists;
- symbols this round defined that nothing outside their own file references — capability built with no way in.

The checkpoint sees the filesystem and git. It cannot see what is still running → you MUST count that yourself in step 2.

## Ending a Round

While the mode is armed, exactly three things end a round:

- the goal is delivered and the checkpoint is empty;
- a decision the user owns is required — the goal or its delivery criteria are unclear, a blocker needs a ruling, a serious risk or a disagreement needs settling;
- the user stops the mode.

You MUST NOT end a round for any other reason. In particular:

- You MUST NOT ask whether to continue. Work that is not blocked and needs no ruling is dispatched now, not offered.
- You MUST NOT end a round on a progress summary, a completed task, or a delivered report.
- You are writing "I have finished X, next I could do Y, would you like me to continue?" → Y is unblocked and needs no ruling → you MUST do Y instead of sending that sentence.

The gate blocks a round end once per distinct checkpoint state and never twice for the same one. A finding you genuinely cannot clear MUST be named in the report; it MUST NOT be left silent because the gate let the round through.

## Disarming

- The goal is delivered, or the user ends the mode → you MUST delete the sentinel and say the mode is off.
- You MUST NOT leave the mode armed across an unrelated task.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "I finished this round, I'll report and see what they say." | Run the checkpoint, dispatch, then report. |
| "I'll check the queue when I write the summary." | The summary is the moment you will forget. Run the command first. |
| "Asking whether to continue is the cautious thing to do." | It moves scheduling onto the user. Dispatch the unblocked work. |
| "The gate let me through, so the queue must be clear." | The gate blocks once per state. Read what it printed. |
| "The user is not watching, I'll pause here." | Nothing pauses a round except delivery, a ruling, or the user. |
| "I'll arm the mode, it will help." | Arm it only when the user starts it. |

## Checklist

Before ending any round while the mode is armed:

- [ ] The checkpoint ran this round, and I read its output.
- [ ] The Dispatch Block ran before I read any report or wrote any reply.
- [ ] Every finding is cleared, dispatched, or named in the report.
- [ ] This round ends on delivery, a decision the user owns, or the user's stop — nothing else.
- [ ] The mode is disarmed if its goal is delivered.
