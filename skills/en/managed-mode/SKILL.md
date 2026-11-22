---
name: managed-mode
description: Use only when the user explicitly starts or ends managed mode — "进入托管模式", "请进入 4 小时的托管模式", "退出托管模式", 托管模式 with any verb, "managed mode" — you MUST decide every ruling yourself through research instead of asking, record it, and replay the record to the user after the mode ends
---

# Managed Mode

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
DECIDE BY RESEARCH, NEVER BY ASKING — EVERY RULING IS RECORDED, THEN REPLAYED
```

## When to Use

- The user starts the mode in this session → you MUST enter it before the next unit of work.
- The user has not asked for it → you MUST NOT enter it.
- The user has not asked for it → you MUST NOT ask whether to.

## Entering

Managed state — `<project-root>/.omnipowers/managed-mode`, whose presence means the mode is on, with this template:

```
start=<output of `date -u +%Y-%m-%dT%H:%MZ` at entry>
deadline=<start plus the duration the user stated, else plus 10 hours>
record=<path to the ruling record>
```

- Entering the mode → you MUST write the managed state.
- Entering the mode → you MUST arm `continuous-work-mode` for the goal the user stated, or for the work in progress when the user stated none.
- A checkpoint of `continuous-work-mode` runs → you MUST compare the output of `date -u` with `deadline=`.
- Judging whether the deadline has passed → you MUST NOT rely on memory.

## Rulings

Ruling — a point `confirming-with-the-user` assigns to the user.

- The mode is on → you MUST NOT ask the user for a ruling.
- The mode is on → you MUST NOT end a round to wait for a ruling.
- A ruling arises → you MUST research, under `researching`, the practice the industry follows in the same situation, weigh it against this project's verified state, and decide.
- The host offers a deep-research capability → you MAY use it for that research.
- Deciding a ruling → you MUST rank long-term architecture, design elegance, and established best practice above development cost.
- Deciding a ruling → development cost MUST NOT decide it.
- A skill requires you to confirm an artifact location → you MUST take that skill's fallback location without asking.

## Actions You Defer

- An action `confirming-with-the-user` lists as hard to undo or externally visible → you MUST NOT perform it while the mode is on, and MUST record it as a deferred action.
- A deferred action stands in the way of further work → you MUST continue by a reversible path where one exists.

## Scope

- Work lies outside the goal, including a site the `fixing-bugs` sweep finds outside it → you MUST NOT do it, and MUST record it as a proposed goal.

## The Ruling Record

Ruling record — a `design-docs` artifact, location resolved per `using-omnipowers`, fallback `docs/design/YYYY-MM-DD-managed-rulings.md`, with one entry per ruling, deferred action, or proposed goal:

```markdown
## M<n> — <the question the user would have been asked>
- kind: ruling | deferred action | proposed goal
- research: <primary sources, cited>
- options: <each option and its impact>
- chosen: <option> — why: <reason>
- done: <commits, or "not done">
- undo: <how to reverse it if the user rejects it>
```

- A ruling is decided → you MUST write its entry before acting on it.
- Implementing a ruling → you MUST commit it apart from other work, under the host's `vcs` convention.

## Exiting

- The deadline has passed → you MUST finish and commit the step in hand, start no new work, and exit.
- The user ends the mode, or `continuous-work-mode` disarms on delivery → you MUST exit.
- Exiting → you MUST disarm `continuous-work-mode` and delete the managed state.
- Exiting → you MUST present every record entry to the user as a decision under `confirming-with-the-user`, stating what was done and what undoing it costs.
- The user's answer differs from the recorded choice → you MUST undo the ruling's commits and carry out the answer.

## Red Flags — STOP if you catch yourself thinking

| Thought | What to do instead |
| --- | --- |
| "This choice fixes a schema; it is the user's, so I wait." | Research, decide, record, keep working. |
| "The user named no kind of confirmation to waive." | The mode waives every ruling. |
| "托管模式 is not a trigger of continuous-work-mode." | Entering this mode arms it. |
| "I'll remember the deadline." | Read `deadline=` and run `date -u`. |
| "The location needs the user's confirmation first." | Take the fallback location. |
| "The sweep says fix the other site in this change." | Outside the goal, it is a proposed goal. |
| "The natural last step is deleting the old files." | Defer it and record it. |
