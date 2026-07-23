---
name: domain-modeling
description: Use when building or sharpening a project's domain model — pinning down terminology, naming a concept, maintaining a ubiquitous language or glossary (CONTEXT.md), recording an architectural decision (ADR), or when discussion terms turn vague, drift, overload, or contradict the code — you MUST sharpen every ambiguous term to one canonical definition and record it in the glossary the moment it is resolved
---

# Domain Modeling

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A modeled domain is one where every concept has exactly one name, every name has exactly one meaning, the code agrees with the model, and the decisions that shaped it are written where the next human will look. This skill is the *active* discipline that produces that state: challenging terms, probing edges, and writing resolutions down as they land.

**Core principle:** An ambiguity you let pass today is a bug report in six months, filed in two vocabularies.

Merely *reading* the glossary to use its vocabulary is not this skill — any task can do that in passing. This skill governs **changing the model**: resolving terms, reshaping relationships, recording decisions.

## The Four Actions

While designing or discussing the domain, you MUST perform each of these whenever its trigger appears. Skipping one silently ratifies a broken model.

1. **Challenge drift against the glossary.** When a term is used in a way that conflicts with its glossary definition, you MUST call it out immediately: "The glossary defines *cancellation* as X, but here it means Y — which is it?" Unchallenged drift forks the language.
2. **Sharpen ambiguity to one canonical term.** When a word is vague or overloaded ("account", "job", "sync"), you MUST propose one precise canonical term and name the alternatives it displaces. Two near-synonyms today become two concepts tomorrow.
3. **Stress-test with edge-case scenarios.** When a definition or relationship is proposed, you MUST invent concrete scenarios that probe its boundaries ("a customer cancels half an order — is that a *cancellation*?"). A term that survives no edge case defines nothing.
4. **Cross-check the model against the real code.** When a claim is made about how the domain works, you MUST check whether the code agrees, and surface any contradiction: "The code cancels whole Orders, but you said partial cancellation exists — which is right?" A model the code ignores is fiction.

## Record the Moment It Lands

- You MUST update the glossary **the moment** a term is resolved. You MUST NOT batch updates to the end of the session — sessions end early, context truncates, and batched resolutions are lost exactly when they mattered.
- When writing or updating the glossary, read `@context-format.md` and follow it.
- When a decision passes the ADR gate below, read `@adr-format.md` and follow it.

## ADRs — the Three-Gate Test

You MUST NOT create an ADR unless **all three** hold:

1. **Hard to reverse** — changing the decision later carries real cost.
2. **Surprising without context** — a future reader would ask "why on earth is it this way?"
3. **A real trade-off was weighed** — genuine alternatives existed and one was chosen for specific reasons.

If any gate fails, no ADR: easily reversed decisions will simply be reversed; unsurprising ones raise no question; no-alternative ones record only "we did the obvious thing". ADRs written past the gate bury the ones that matter.

## Artifact Locations

- The glossary lives at the **host project root** as `CONTEXT.md`; ADRs live in `docs/adr/`. These are industry-standard, human-discoverable locations — the artifacts are project documents for humans, not skill state, so they MUST NOT be tucked under `.omnipowers/` or any agent-only directory.
- On the **first creation** of either artifact in a host project, you MUST confirm the location with the user before writing it. A location the user states overrides the default above, permanently for that project.

## Lazy Creation

- You MUST NOT scaffold artifacts ahead of need: no empty `CONTEXT.md`, no empty `docs/adr/`. Create `CONTEXT.md` when the first term is resolved; create `docs/adr/` when the first ADR passes the gate. Empty scaffolds are noise that trains readers to ignore the real thing.
- You MUST NOT nag about absent artifacts. A task that would merely *consume* the glossary and finds none proceeds silently — absence is a fact, not a defect to report.

## Red Flags — STOP

If any of these is true, stop and correct course:

- Glossary updates queued up "for the end of the session"
- An empty `CONTEXT.md` or `docs/adr/` created "so the structure is ready"
- An ADR written for a decision that fails any of the three gates
- A vague or overloaded term ("account", "job", "process") accepted without proposing a canonical term
- A claim about domain behavior accepted without checking the code
- "You don't have a CONTEXT.md yet" raised during work that wasn't resolving a term
- A first `CONTEXT.md` or ADR written without confirming the location with the user
- Specs, history, or implementation notes drafted into the glossary

## Rationalizations — Rejected

| Excuse | Reality |
|--------|---------|
| "I'll write the glossary entries once the design settles" | Sessions end mid-design. Resolved now means written now; unwritten resolutions evaporate. |
| "This decision feels important — ADR it" | *Important* is not the test. Run the three gates; most important decisions fail at least one. |
| "Recording it can't hurt" | It can: ADR noise buries the ADRs that matter, and readers stop opening the directory. |
| "I'll create the files up front so they exist" | Artifacts earn existence with content. An empty file is a promise nobody made. |
| "The term is close enough, everyone understands" | Everyone understands differently. That is precisely the failure this skill exists to stop. |
| "The user said the code works that way" | The code is the ground truth for what the code does. Check it. |
| "The default location is standard, no need to ask" | First creation writes to the host's root. The user owns their root; confirm once. |
| "That edge case is too contrived" | Contrived scenarios are cheap; production incidents are not. Probe the boundary anyway. |

## The Bottom Line

```
Term resolved   → glossary updated in the same breath
Decision passes → all three gates, then a short ADR
Neither         → keep the discussion sharp and write nothing
```
