---
name: continuous-work-mode
description: Use when the user explicitly starts or ends continuous work mode — "进入连续工作模式", "退出连续工作模式", or 连续工作模式 with any verb, "continuous work mode", "keep going until everything is done, stop asking me" — you MUST install a stop-time gate that runs the checkpoint before any round can end, and while the mode is armed you MUST NOT end a round to ask whether to continue
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
- The user has not asked for it → you MUST NOT arm it, MUST NOT install the gate, and MUST NOT ask whether to. An armed gate changes when the host lets a round end; the user's own words are the only thing that starts it.

## Arming the Mode

1. **Install the gate.** The gate is absent → read `@installing-the-gate.md` and install it. The user starting the mode is the authorization: the gate is what the mode is, not a further decision. You MUST NOT ask consent for it, and you MUST NOT install it for any other reason. Name the file you changed when you confirm in step 3.
2. **Write the sentinel** at `<project-root>/.omnipowers/continuous-mode`. The gate is inert while this file is absent, so the mode is armed and disarmed by this file alone:

```
base=<the commit the mode starts from>
started=<current epoch seconds>
expires=<hours before the mode goes stale>   # optional, default 24
defects=<path to a checklist file>           # optional, repeatable
repo=<path to another repo to watch>         # optional, repeatable
```

`.omnipowers/` is not git-ignored → you MUST add it to `.gitignore` before writing the sentinel. A committed sentinel arms the mode for everyone who clones the project.

3. **Confirm in one line** what the mode was armed for, and continue working in the same reply. You MUST NOT end the round on the confirmation.

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

Disarming removes both halves: the sentinel, the owner file beside it, and the gate's marker, **and the gate itself** — its registration and its installed script. An inert gate is still a script the host runs at the end of every turn in a project whose work is finished. There is no exception: the mode is cheap to install again the next time the user starts it.

You MUST disarm when any of these is true:

- the goal the mode was armed for is delivered;
- the user ends the mode;
- the work turns into an unrelated task. You MUST NOT carry an armed mode into one.

The checkpoint prompts the disarm itself: it prints the removal command whenever it finds the queue empty, which is the moment disarming is correct. A disarmed gate cannot speak — the host shows nothing from a hook that lets the turn end — so the decision to remove it MUST be taken at disarm, while you are still running. You MUST NOT rely on remembering it while writing a completion summary — that is the failure this whole mode exists to remove.

The mode outliving its session is prevented, not merely discouraged. The gate claims the session on its first fire, and it refuses a mode that a different session armed or that has passed its `expires` life. It says which files to delete and blocks once, so a mode nobody owns costs one interruption and then clears.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "I finished this round, I'll report and see what they say." | Run the checkpoint, dispatch, then report. |
| "I'll check the queue when I write the summary." | The summary is the moment you will forget. Run the command first. |
| "Asking whether to continue is the cautious thing to do." | It moves scheduling onto the user. Dispatch the unblocked work. |
| "The gate let me through, so the queue must be clear." | The gate blocks once per state. Read what it printed. |
| "The user is not watching, I'll pause here." | Nothing pauses a round except delivery, a ruling, or the user. |
| "I'll arm the mode, it will help." | Arm it only when the user starts it. |
| "The gate is complaining about a mode I never started." | It is a leftover. Ask the user, then delete the files it named. |
| "The goal is delivered, I'll leave the mode on in case." | Disarm it. An armed mode gates the next, unrelated task. |
| "The gate is harmless when disarmed, I'll leave it installed." | Remove it with the sentinel. Installing it again costs one step. |
| "Should I install the hook?" | They started the mode. Install it and say which file you changed. |

## Checklist

Before ending any round while the mode is armed:

- [ ] The checkpoint ran this round, and I read its output.
- [ ] The Dispatch Block ran before I read any report or wrote any reply.
- [ ] Every finding is cleared, dispatched, or named in the report.
- [ ] This round ends on delivery, a decision the user owns, or the user's stop — nothing else.
- [ ] The mode is disarmed if its goal is delivered, the user ended it, or the task changed.
- [ ] Disarming removed the gate too — registration, script, and workbench files.
