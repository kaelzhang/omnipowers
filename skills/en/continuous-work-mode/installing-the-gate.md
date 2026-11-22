# Installing the Stop-Time Gate

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## What to install

- The user started the mode → you MUST NOT ask for gate-installation authorization again.
- You confirm the mode is armed → you MUST name the file you changed.

## The stop-time contract

For every host mechanism, the installation MUST satisfy all four:

- it runs when the agent is about to end its turn, not after;
- its refusal signal (a non-zero exit or a structured continue decision) prevents the turn from ending;
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

## Antigravity

```json
{
  "continuous-work-mode": {
    "Stop": [
      { "type": "command", "command": "bash <project-root>/.agents/hooks/checkpoint.sh --gate" }
    ]
  }
}
```

- Running in Antigravity → you MUST copy `checkpoint.sh` to `.agents/hooks/checkpoint.sh` and register the entry above in `.agents/hooks.json`, whether or not `/goal` is active.
- `.agents/hooks.json` already exists → you MUST merge the `"continuous-work-mode"` key without modifying other keys.
- Running in Antigravity → you MUST NOT end the round to ask the user to run `/goal`.

## A host with no hook mechanism

- No stop-time hook exists → you MUST NOT claim the mode is mechanized.

## Removing the gate

Gate removal — deleting the hook registration, the installed `checkpoint.sh`, and `.omnipowers/continuous-mode`, `.omnipowers/continuous-mode.owner`, and `.omnipowers/continuous-gate.last` from the workbench.

Mode ending — delivery of the goal the mode was armed for, distinct from ending a single round.

- The mode ends → you MUST remove the gate in the same step that deletes the sentinel.
- Removing the hook registration leaves its config file empty → you MUST delete that config file and any empty hooks directory you created.
- The gate is being removed → you MUST NOT ask for authorization.
- The work the gate was installed for has ended → the gate MUST NOT outlive that work.
