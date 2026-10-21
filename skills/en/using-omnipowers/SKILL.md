---
name: using-omnipowers
description: Use once, at the start of a conversation — establishes how omnipowers skills work; you MUST check for and invoke any applicable skill before responding
---

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

<SUBAGENT-STOP>
Skill scope — agents other than subagents dispatched to execute one specific task.
</SUBAGENT-STOP>

## Applying a skill

- Before responding or acting → you MUST check whether a skill governs what you are about to do.
- Governing skill — a skill whose trigger describes what you are about to do.
- Skill compliance — invocation of a governing skill and exact adherence to its `MUST` / `MUST NOT` rules.
- A skill's trigger names a different situation → you MUST NOT invoke it.
- When applying a skill → you MUST NOT soften a rule, skip a step, or treat a `MUST` as a suggestion.
- When applying a skill → you MUST NOT invent an exception.
- A skill states an exception (`MAY … ONLY when …`) → you MUST satisfy every condition it lists.
- The host offers a skill-invocation mechanism → you MUST use it.
- Skill activation — invocation through the host's skill-invocation mechanism, distinct from reading a `SKILL.md`.
- A skill is already in context → you MUST NOT invoke it again at each trigger.
- A skill carries a checklist and an item fails → you MUST NOT report the work done.
- A skill carries a checklist → you MUST NOT copy it into the host's task tool or into your reply.
- Two skills both look applicable → read `@skill-map.md` and apply it.
- You notice yourself reasoning toward invoking a skill you have not matched, or toward skipping one you have → read `@rationalizing.md` and apply it.

## Where an artifact goes

Artifact role — one of `design-docs`, `work-state`, `records`, `scratch`, or `standards`, named by the skill writing the file.

Artifact-location resolution — the first applicable entry in the following ordered list:

1. Session location — a location the user states in this session.
2. Host-declared location — the row for the artifact's role in the host's `Omnipowers` declaration, a section in `AGENTS.md` / `CLAUDE.md` or in a document that file points to.
3. Existing role location — where the host already keeps documents of that role, when that is unambiguous.
4. Fallback location — the fallback path named by the skill.

- Artifact-location resolution selects entry 1 or 2 → you MUST NOT ask for location confirmation.
- Host policy axes — the declaration's `write-authority`, `vcs`, `isolation`, and `continuation` rows, binding every skill over its own defaults.
- A parent directory for an artifact is missing → you MUST create it.

## Instruction priority

Instruction priority — the user's explicit instructions, then omnipowers skills, then default behavior.

User override — a direct user instruction's precedence over any skill rule, including a `MUST` inside a skill and including `using-omnipowers`.

Instruction-disagreement owner — `confirming-with-the-user`, governing how disagreement with an instruction is raised, what happens once the user answers, and how far the override reaches.
