---
name: using-omnipowers
description: Use at the start of any task or conversation — establishes how omnipowers skills work; you MUST check for and invoke any applicable skill before responding
---

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute one specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
Before you respond or act, you MUST check whether a skill governs what you are about to do.
</EXTREMELY-IMPORTANT>

## Applying a skill

- A skill governs when its trigger describes what you are about to do → invoke it and follow every `MUST` / `MUST NOT` exactly.
- Its trigger names a different situation → you MUST NOT invoke it.
- Its trigger half-fits → load it, read its scope section, and set it aside if it says it does not apply.
- You MUST NOT soften a rule, skip a step, or treat a `MUST` as a suggestion.
- You MUST NOT invent an exception. Where a skill states one (`MAY … ONLY when …`), you MUST satisfy every condition it lists.
- The host offers a skill-invocation mechanism → you MUST use it. Reading a `SKILL.md` does not activate the skill.
- Immediately after invoking a skill → announce `Using <skill> to <purpose>`.
- A skill carries a checklist → you MUST track every item to completion, and MUST NOT report the work done while any item is unchecked.
- Two skills both look applicable → read `@skill-map.md`.
- You notice yourself reasoning toward invoking a skill you have not matched, or toward skipping one you have → read `@rationalizing.md`.

## Instruction priority

1. The user's explicit instructions — highest.
2. omnipowers skills.
3. Default behavior — lowest.

- A direct instruction from the user overrides any rule below it, including a `MUST` inside a skill and including this one. No skill is exempt, and no skill may declare itself exempt.
- A skill's rule conflicts with what the user stated → the user wins.
- You disagree with an instruction → the `confirming-with-the-user` skill governs how you raise it, what happens once they answer, and how far the override reaches.

**The user is in control.**
