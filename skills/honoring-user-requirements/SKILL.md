---
name: honoring-user-requirements
description: Use once per session, at the first instruction the user gives, or when they ask that their requirements be recorded, appealed, or carried out exactly ("落档", "申诉", "绝对执行"); it then governs every requirement they state — you MUST write each one into the requirements ledger the moment it is stated, verify every open entry at each task return and before any completion claim, and carry out a confirmed requirement exactly as stated
---

# Honoring User Requirements

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
WRITE IT DOWN THE MOMENT IT IS SAID — VERIFY IT BEFORE YOU CLAIM ANYTHING — ONCE CONFIRMED, DO EXACTLY THAT
```

## The Ledger

Ledger — one `work-state` artifact per piece of work, with its location resolved per `using-omnipowers` and fallback `.omnipowers/requirements.md`.

```markdown
# Requirements

## Standing
- R1 — "<the user's words>" (stated <date>)

## This work
- [ ] R2 — "<the user's words>" (stated <date>; verify by: <the check>)
  - appeal: <what you proposed> → <the user's answer, and when>
  - evidence: <file:line, command output, or commit>
```

## Recording

- The user states an instruction, a constraint, a prohibition, a decision, or an answer to an appeal → you MUST add it to the ledger **before acting on it**, in their words.
- Recording a requirement → you MUST NOT paraphrase it into something narrower or broader.
- Recording requirements → you MUST NOT batch entries to the end of the round.
- The host's own entrypoint already states a requirement → you MUST NOT copy it.

## Appeal

Appeal — a disagreement with a requirement or a proposal of a better way, governed by `confirming-with-the-user`.

- You disagree with a requirement or see a better way → you MUST record the appeal and the answer under the entry.

## Verification

- Before ending any round and before any claim that work is complete, fixed, or ready → you MUST read every open entry and, for each, write one line of evidence that it is honored, or mark it **violated**.
- At a task return → you MUST read every open entry that task's work could have affected and, for each, write one line of evidence that it is honored, or mark it **violated**.
- An entry is violated → you MUST fix it before any other work, then re-verify.
- An entry has no evidence yet → you MUST NOT claim the work done.
- An entry has no evidence yet → you MUST NOT report the round without naming it.
