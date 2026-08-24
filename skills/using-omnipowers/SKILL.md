---
name: using-omnipowers
description: Use at the start of any task or conversation — establishes how omnipowers skills work; you MUST check for and invoke any applicable skill before responding
---

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute one specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
Before you respond or act, you MUST check whether a skill governs what you are about to do. The check itself is never optional.

Where a skill governs, using it is not optional and you MUST NOT rationalize your way out of it. Where none governs, you MUST NOT invoke one anyway.
</EXTREMELY-IMPORTANT>

## What omnipowers skills are

omnipowers skills are **normative**, not advisory. Most of a skill's content is a hard requirement expressed in BCP 14 keywords. When a skill applies:

- You MUST follow every `MUST` / `MUST NOT` in it, exactly.
- You MUST NOT soften a rule, skip a step, or treat a `MUST` as a suggestion.
- A skill's only exceptions are the ones the skill itself states. You MUST NOT invent new ones. Where a skill defines an escape (typically `MAY ... ONLY when ...`), you MUST satisfy every condition it lists.

## Instruction priority

When guidance conflicts, follow this order:

1. **The user's explicit instructions** (AGENTS.md / CLAUDE.md / direct requests) — highest.
2. **omnipowers skills** — override default behavior where they conflict.
3. **Default behavior** — lowest.

A direct instruction from the user overrides any rule below it — including a `MUST` inside a skill, and including this one. No skill is exempt, and no skill may declare itself exempt.

Before complying you MAY object **once**, and the objection MUST be substantive: name the rule being overridden, state the concrete consequence, and offer the alternative. An objection missing any of the three is friction, not review — where you have no substantive objection you MUST NOT manufacture one. Once the user has answered you MUST carry the instruction out in full, and MUST NOT re-raise it in the same or another form.

An override applies to the instance it was given for. A standing change MUST come from the user saying so, not from you generalizing one override into a habit.

**The user is in control.**

## The rule

You MUST run the check BEFORE any response or action — including before asking a clarifying question or reading the codebase. The check costs one thought; skipping it is how a discipline gets missed entirely.

**A skill governs when its trigger describes what you are actually about to do** — not when the subject matter is merely adjacent to it. Read the description and ask: is this the situation it names? If yes, invoke it and follow it exactly. If no, proceed with the work; having checked is enough, and you MUST NOT announce a skill you did not invoke.

Both failures are real, and they cost in opposite directions:

- **Skipping a skill that governs** loses the discipline the user installed it for, and the excuses are always the same — "it's small", "it's obvious", "just this once". You MUST NOT accept any of them.
- **Invoking a skill that does not govern** spends the user's time and tokens on ceremony they did not ask for, and — worse — can convert a fully-specified instruction into a question back to them. Loading a skill "just in case" is not caution; it is the same defect pointed the other way, and it MUST NOT be done.

When a skill's trigger genuinely half-fits, load it and read its own scope section: a well-written skill states where it does not apply. If it says it does not apply, set it aside and say nothing further about it.

Immediately after invoking a skill and before acting on it, you MUST announce `Using <skill> to <purpose>` so the user can see which skill is governing the step; without that announcement the skill governs the work invisibly and the user cannot tell which discipline is in force.


When a skill contains a checklist, you MUST track every item to completion and MUST NOT report the work done while any item is unchecked.

## How to invoke a skill

- **Claude Code:** use the `Skill` tool. Its content loads into the conversation — follow it directly. You MUST NOT `Read` a skill's `SKILL.md` in place of invoking it; reading does not activate it.
- **Codex:** skills are discovered by `name` and `description`; activate the matching skill by name.
- **Other tools:** consult that tool's skill-loading mechanism.

## When several skills could apply

Invoke the skill that governs your current step first, then the next. A skill that shapes HOW you work (a discipline or workflow) MUST run before one that only guides WHAT you produce. You MUST NOT skip a governing skill because a later one looks more specific.

When you are unsure which skill governs — or two adjacent skills both look applicable — read `@skill-map.md`: it maps the collection into flows and states the boundary between each pair of commonly confused skills.

## When you are about to talk yourself into or out of a skill

The two failures above have well-worn excuses on both sides — "it's too small to need a skill", "I'll check after I look at the code", "it's adjacent so I'd better load it too", "better review it as well, just to be safe". The moment you notice yourself reasoning toward using a skill you have not matched to the task, or toward skipping one you have, read `@rationalizing.md` and check your thought against it before you act.
