---
name: honoring-user-requirements
description: Use once per session, at the first instruction the user gives; it then governs every requirement they state — you MUST write each one into the requirements ledger the moment it is stated, verify every open entry at each task return and before any completion claim, and carry out a confirmed requirement exactly as stated
---

# Honoring User Requirements

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
WRITE IT DOWN THE MOMENT IT IS SAID — VERIFY IT BEFORE YOU CLAIM ANYTHING — ONCE CONFIRMED, DO EXACTLY THAT
```

A requirement held only in memory is lost by the round that needs it most: the long one, the one after a compaction, the one where you had a better idea.

## The Ledger

The ledger is a `work-state` artifact: resolve its location per `using-omnipowers`, fallback `.omnipowers/requirements.md`. One per piece of work. Its shape:

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

- The user states an instruction, a constraint, a prohibition, a decision, or an answer to an appeal → you MUST add it to the ledger **before acting on it**, in their words. You MUST NOT paraphrase it into something narrower or broader, and MUST NOT batch entries to the end of the round.
- It outlives this work → file it under *Standing*. It is delivered by this work → under *This work*, with the check that will prove it.
- The host's own entrypoint already states it → reference that line; you MUST NOT copy it.
- A question, context, or thinking aloud is not a requirement. In doubt → record it and say you did.

## Appeal

You disagree with a requirement, or see a better way → the `confirming-with-the-user` skill governs how you raise it, that you raise it once, and that their answer is the decision. You MUST record the appeal and the answer under the entry.

- The user confirms the requirement → it is no longer arguable. You MUST carry it out exactly as stated: not an improved version, not the part you agree with, not a version that drifts back toward your proposal later in the work.
- The user changes it → the entry changes to their new words, and the old words are struck, not deleted.

## Verification

Before ending any round and before any claim that work is complete, fixed, or ready → you MUST read every open entry and, for each, write one line of evidence that it is honored, or mark it **violated**. At a task return → the same, for the entries that task's work could have affected.

- An entry is violated → you MUST fix it before any other work, then re-verify.
- An entry has no evidence yet → it is not honored. You MUST NOT claim the work done, and MUST NOT report the round without naming it.
- A *Standing* entry is verified against the round's actual output — the diff, the commit, the reply — not against your intention.
- Continuous work mode is armed → name the ledger in its sentinel as a `defects=` file, so its open entries appear at every checkpoint.

## Red Flags — STOP

- "I'll note that later, once I've done this bit."
- "They said X, but what they really want is Y."
- "I'll do most of it — the rest doesn't fit."
- "I already complied with that earlier, no need to check the final result."
- "This is a small session, the ledger is overkill." — one entry is one line.

## Checklist

Before ending a round or claiming completion:

- [ ] Every requirement the user stated this round is in the ledger, in their words, before it was acted on
- [ ] Every appeal and its answer is recorded under its entry
- [ ] Every open entry has a line of evidence, or is marked violated and fixed
- [ ] No confirmed requirement was narrowed, improved upon, or partially done
