---
name: domain-modeling
description: Use when building or sharpening a project's domain model — naming concepts, maintaining a glossary / ubiquitous language (CONTEXT.md), recording an ADR, or when terms drift, overload, or contradict the code — you MUST sharpen each ambiguous term to one canonical definition and record it the moment it lands
---

# Domain Modeling

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- Reading the glossary to use its vocabulary → not this skill; any task does that in passing.
- Changing the model — resolving terms, reshaping relationships, recording decisions → this skill.

## The Four Actions

While designing or discussing the domain, you MUST perform each of these whenever its trigger appears.

1. **Challenge drift against the glossary.** A term is used in a way that conflicts with its glossary definition → you MUST call it out immediately.
2. **Sharpen ambiguity to one canonical term.** A word is vague or overloaded → you MUST propose one precise canonical term and name the alternatives it displaces.
3. **Stress-test with edge-case scenarios.** A definition or relationship is proposed → you MUST invent concrete scenarios that probe its boundaries.
4. **Cross-check the model against the real code.** A claim is made about how the domain works → you MUST check whether the code agrees, and surface any contradiction.

## Record the Moment It Lands

- A term is resolved → you MUST update the glossary **in that moment**. You MUST NOT batch updates to the end of the session.
- Writing or updating the glossary → read `@context-format.md` and follow it.
- A decision passes the ADR gate below → read `@adr-format.md` and follow it.

## ADRs — the Three-Gate Test

You MUST NOT create an ADR unless **all three** hold:

1. **Hard to reverse** — changing the decision later carries real cost.
2. **Surprising without context** — a future reader would ask why it is this way.
3. **A real trade-off was weighed** — genuine alternatives existed and one was chosen for specific reasons.

Any gate fails → no ADR.

## Artifact Locations

- Both artifacts are durable design documents for humans, not skill state → they MUST NOT be placed under `.omnipowers/` or any other agent-only directory.
- You MUST resolve their location in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps design documents, when that is unambiguous; (4) the fallback — the glossary at the **host project root** as `CONTEXT.md`, ADRs in `docs/adr/`.
- Resolving to 3 or 4 MUST be confirmed with the user before the **first creation** of either artifact in a host project; resolving to 1 or 2 MUST NOT ask. A location the user states governs permanently for that project.

## Lazy Creation

- You MUST NOT scaffold artifacts ahead of need: no empty `CONTEXT.md`, no empty `docs/adr/`. Create `CONTEXT.md` when the first term is resolved; create `docs/adr/` when the first ADR passes the gate.
- You MUST NOT nag about absent artifacts. A task that would merely *consume* the glossary and finds none proceeds silently.

## Red Flags — STOP

Any of these is true → stop and correct course:

- Glossary updates queued up "for the end of the session"
- An empty `CONTEXT.md` or `docs/adr/` created "so the structure is ready"
- An ADR written for a decision that fails any of the three gates
- A vague or overloaded term accepted without proposing a canonical term
- A claim about domain behavior accepted without checking the code
- The absence of a `CONTEXT.md` raised during work that wasn't resolving a term
- A first `CONTEXT.md` or ADR written without confirming the location with the user
- Specs, history, or implementation notes drafted into the glossary

## Rationalizations — rejected

| Thought | What to do instead |
|---|---|
| "I'll write the glossary entries once the design settles" | Write the entry the moment the term resolves. |
| "This decision feels important — ADR it" | Run the three gates; importance is not one of them. |
| "Recording it can't hurt" | A gate fails → write no ADR. |
| "I'll create the files up front so they exist" | Create each artifact when its first content exists. |
| "The term is close enough, everyone understands" | Propose one canonical term. |
| "The user said the code works that way" | Check the code before accepting the claim. |
| "The default location is standard, no need to ask" | The default is case 3 or 4 → confirm it before the first creation. |
| "That edge case is too contrived" | Probe the boundary anyway. |
