---
name: continuous-work-mode
description: Use when the user explicitly starts or ends continuous work mode — "进入连续工作模式", "退出连续工作模式", or 连续工作模式 with any verb, "continuous work mode", "keep going until everything is done, stop asking me" — you MUST install the stop-time gate and stop ending rounds to ask whether to continue
---

# Continuous Work Mode

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
THE QUEUE IS CHECKED BY A COMMAND, NOT BY MEMORY — REPORTING IS THE LAST STEP, NEVER THE DELIVERABLE
```

## When to Use

- The user starts the mode in this session → you MUST arm it before the next unit of work.
- The user ends it, or the goal it was armed for is delivered → you MUST disarm it.
- The user has not asked for it → you MUST NOT arm it.
- The user has not asked for it → you MUST NOT install the gate.
- The user has not asked for it → you MUST NOT ask whether to.

## Arming the Mode

The gate is absent → read `@installing-the-gate.md` and install it.

- The user starts the mode → you MUST NOT ask consent for gate installation.
- The user has not started the mode → you MUST NOT install the gate.

Sentinel — `<project-root>/.omnipowers/continuous-mode`, whose presence arms the mode and whose absence disarms it, with this template:

```
goal=<one line: what this mode delivers>
base=<the commit the mode starts from>
started=<current epoch seconds>
expires=<hours before the mode goes stale>   # optional, default 24
defects=<path to a checklist file>           # optional, repeatable
repo=<path to another repo to watch>         # optional, repeatable
```

Acceptance list — one `- [ ]` item per line below the sentinel fields, with at least one item; delivery means every item checked, and non-delivery means any item unchecked.

- An item is written in the acceptance list → it MUST be observable in the product, never a step you remember taking.
- Arming the mode → you MUST write the acceptance list in one pass from what the user already stated.
- Arming the mode → you MUST NOT research or design to produce the acceptance list.
- Arming the mode → you MUST NOT add scope to the acceptance list.
- An acceptance item lands → you MUST check it off.
- `.omnipowers/` is not git-ignored → you MUST add it to `.gitignore` before writing the sentinel.
- The arming confirmation is sent → you MUST NOT end the round on the confirmation.

## The Order

Checkpoint (step 1) — at a task return or before a round ends, running `@checkpoint.sh`, or the command the gate reports.

Dispatch (step 2) — running the Dispatch Block of the `keeping-work-in-flight` skill against the checkpoint's findings and open acceptance items, including its check that the next serial stretch is not splittable.

- Steps 1 and 2 have not run → you MUST NOT read a returned report.
- Steps 1 and 2 have not run → you MUST NOT write any part of a reply.
- Step 2 runs → you MUST count what is still running yourself.

## Ending a Round

Permitted round end — delivery of the goal with an empty checkpoint; a required decision the user owns about unclear goals or delivery criteria, a blocker, a serious risk, or a disagreement; or the user's stop.

- The mode is armed → you MUST NOT end a round for any reason outside the permitted round ends.
- The mode is armed → you MUST NOT end a round to ask anything the `brainstorming` skill forbids asking.
- The mode is armed → you MUST NOT end a round on a progress summary, a completed task, or a delivered report.
- You are writing "I have finished X, next I could do Y, would you like me to continue?" and Y is unblocked and needs no ruling → you MUST do Y instead of sending that sentence.
- You cannot clear a finding → you MUST name it in the report.
- You cannot clear a finding and the gate let the round through → you MUST NOT leave it silent.

## Disarming

Disarming — removing the sentinel, its adjacent owner file, the gate's marker, the gate's registration, and its installed script.

- The goal the mode was armed for is delivered → you MUST disarm.
- The user ends the mode → you MUST disarm.
- The work turns into an unrelated task → you MUST disarm.
- The work turns into an unrelated task → you MUST NOT carry an armed mode into it.
- Every acceptance item is checked → you MUST disarm in that same round, even when the checkpoint still lists findings.
- A checkpoint finding exists → you MUST NOT promote it into the acceptance list or re-arm for it.
- The mode is being disarmed → removal MUST be decided while you are still running.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "I finished this round, I'll report and see what they say." | Run the checkpoint, dispatch, then report. |
| "I'll check the queue when I write the summary." | Run the command first. |
| "Asking whether to continue is the cautious thing to do." | Dispatch the unblocked work. |
| "The gate let me through, so the queue must be clear." | Read what it printed. |
| "The user is not watching, I'll pause here." | End the round only on delivery, a ruling, or the user's stop. |
| "I'll arm the mode, it will help." | Arm it only when the user starts it. |
| "The gate is complaining about a mode I never started." | Ask the user, then delete the files it named. |
| "The goal is delivered, I'll leave the mode on in case." | Disarm it. |
| "The gate is harmless when disarmed, I'll leave it installed." | Remove it with the sentinel. |
| "The checkpoint still lists things, so the mode is not done." | Report the rest as follow-up and disarm. |
| "While I am in this mode I may as well fix these too." | Leave goal-setting to the user. |
| "Should I install the hook?" | Install it and say which file you changed. |
