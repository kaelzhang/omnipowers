---
name: honoring-user-requirements
description: Use once per session, at session start or the first instruction the user gives, or when they ask that their requirements be recorded, appealed, or carried out exactly ("落档", "申诉", "绝对执行"); it then governs every requirement they state — you MUST read the ledgers before acting at each session start, compaction, and new piece of work, write each requirement into a ledger the moment it is stated, verify every entry at each task return and before any completion claim, and carry out a confirmed requirement exactly as stated
---

# Honoring User Requirements

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
READ IT BEFORE YOU ACT — WRITE IT DOWN THE MOMENT IT IS SAID — VERIFY IT BEFORE YOU CLAIM ANYTHING — ONCE CONFIRMED, DO EXACTLY THAT
```

## The Ledgers

Standing requirement — a requirement the user states for longer than one piece of work: every session, every task, or the whole project.

Standing ledger — one `design-docs` artifact per host project holding its standing requirements, with its location resolved per `using-omnipowers` and fallback `docs/design/standing-requirements.md`.

Work ledger — one `work-state` artifact per piece of work holding that work's other requirements, with its location resolved per `using-omnipowers` and fallback `.omnipowers/requirements.md`.

Open entry — a work ledger entry not yet checked off.

The standing ledger:

```markdown
# Standing requirements

- S1 — "<the user's words>" (stated <date>)
  - appeal: <what you proposed> → <the user's answer, and when>
```

The work ledger:

```markdown
# Requirements

- [ ] R1 — "<the user's words>" (stated <date>; verify by: <the check>)
  - appeal: <what you proposed> → <the user's answer, and when>
  - evidence: <file:line, command output, or commit>
- S1 evidence: <file:line, command output, or commit>
```

## Loading

- A session starts, the context is compacted or resumed, or you start a new piece of work → you MUST read the standing ledger and every open entry of the work ledger before acting.
- A ledger entry differs from your memory or from a compaction summary → you MUST follow the ledger.
- Writing the brief for a subagent or a delegated run → you MUST copy into it, in the user's words, every standing entry and open entry its task could affect.

## Recording

- The user states an instruction, a constraint, a prohibition, a decision, or an answer to an appeal → you MUST add it to the ledger **before acting on it**, in their words.
- The requirement is a standing requirement → you MUST add it to the standing ledger.
- The requirement is not a standing requirement → you MUST add it to the work ledger.
- Recording a requirement → you MUST NOT paraphrase it into something narrower or broader.
- Recording requirements → you MUST NOT batch entries to the end of the round.
- The host's own entrypoint already states a requirement → you MUST NOT copy it.
- A skill in your context already states a requirement → you MUST NOT copy it.

## Appeal

Appeal — a disagreement with a requirement or a proposal of a better way, governed by `confirming-with-the-user`.

- You disagree with a requirement or see a better way → you MUST record the appeal and the answer under the entry.

## Verification

- Before ending any round and before any claim that work is complete, fixed, or ready → you MUST read every standing entry and every open entry and, for each, write one line of evidence that it is honored, or mark it **violated**.
- At a task return → you MUST read every standing entry and open entry that task's work could have affected and, for each, write one line of evidence that it is honored, or mark it **violated**.
- Writing evidence for a standing entry → you MUST write it in the work ledger, not in the standing ledger.
- An entry is violated → you MUST fix it before any other work, then re-verify.
- An entry has no evidence yet → you MUST NOT claim the work done.
- An entry has no evidence yet → you MUST NOT report the round without naming it.
