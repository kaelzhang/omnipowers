# Installing the Stop-Time Gate

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this when continuous work mode is being armed in a project that has no gate installed.

## What to install

Copy `checkpoint.sh` into the host — its hook directory when it has one, otherwise `<project-root>/.omnipowers/bin/` — and make it executable. Register it to run when the agent is about to end its turn, invoked as `checkpoint.sh --gate`.

Installing writes to the host's configuration. You MUST state the exact file you will change and obtain the user's explicit consent before writing it. Consent refused → you MUST run the checkpoint manually at every task return and before every round end, and you MUST say the mode is running without its gate.

## The stop-time contract

A gate is only a gate if refusing the stop actually returns control to the agent. Whatever the host's mechanism, the installation MUST satisfy all four:

- it runs when the agent is about to end its turn, not after;
- a non-zero refusal prevents the turn from ending;
- the text the gate prints reaches the agent, not only a log;
- an unclearable finding cannot block forever.

`checkpoint.sh --gate` satisfies the fourth itself: it blocks once per distinct checkpoint state and passes a repeat of the same state through. You MUST NOT install a variant that blocks unconditionally.

## Claude Code

Register a `Stop` hook in the project's `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/checkpoint.sh --gate" }
        ]
      }
    ]
  }
}
```

Exit code `2` blocks the stop and sends the gate's stderr to the agent; exit `0` lets the turn end and sends nothing. The host offers a task-completion or subagent-stop event as well → you SHOULD register the same command there, so the check also runs when work returns rather than only when the turn ends.

## A host with no hook mechanism

No stop-time hook exists → the gate cannot be installed, and you MUST NOT claim the mode is mechanized. Run `checkpoint.sh` yourself as step 1 of every task return and every round end, and state in the arming confirmation that the check is manual in this project.

## Removing the gate

The mode ends → you MUST remove the gate in the same step that deletes the sentinel. Ending a single round is not the mode ending; delivering the goal it was armed for is.

Removal is authorized by the consent that installed it, so you MUST NOT ask again. Delete the hook registration, the installed `checkpoint.sh`, and everything the mode leaves in the workbench: `.omnipowers/continuous-mode`, `.omnipowers/continuous-mode.owner`, `.omnipowers/continuous-gate.last`. Removing the registration while leaving the sentinel behind is the one order that misleads: it reads as an armed mode that nothing enforces.

The user states they will use the mode again in this project → you MAY leave the registration and the script in place, and you MUST say so when you report the mode off. A gate nobody asked to keep MUST NOT outlive the work it was installed for.
