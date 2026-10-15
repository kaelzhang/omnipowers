# Installing the Stop-Time Gate

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## What to install

- The user started the mode → you MUST NOT ask for gate-installation authorization again.
- You confirm the mode is armed → you MUST name the file you changed.

## The stop-time contract

For every host mechanism, the installation MUST satisfy all four:

- it runs when the agent is about to end its turn, not after;
- a non-zero refusal prevents the turn from ending;
- the text the gate prints reaches the agent, not only a log;
- an unclearable finding cannot block forever.

- A gate variant blocks unconditionally → you MUST NOT install it.

## Claude Code

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

- The host offers a task-completion or subagent-stop event → you SHOULD register the same command there.

## A host with no hook mechanism

- No stop-time hook exists → you MUST NOT claim the mode is mechanized.

## Removing the gate

Gate removal — deleting the hook registration, the installed `checkpoint.sh`, and `.omnipowers/continuous-mode`, `.omnipowers/continuous-mode.owner`, and `.omnipowers/continuous-gate.last` from the workbench.

Mode ending — delivery of the goal the mode was armed for, distinct from ending a single round.

- The mode ends → you MUST remove the gate in the same step that deletes the sentinel.
- The gate is being removed → you MUST NOT ask for authorization.
- The work the gate was installed for has ended → the gate MUST NOT outlive that work.
