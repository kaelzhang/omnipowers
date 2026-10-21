---
name: domain-modeling
description: Use when building or sharpening a project's domain model — naming concepts, maintaining a glossary / ubiquitous language (CONTEXT.md), recording an ADR, or when terms drift, overload, or contradict the code — you MUST sharpen each ambiguous term to one canonical definition and record it the moment it lands
---

# Domain Modeling

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Four Actions

While designing or discussing the domain → you MUST perform each action below whenever its trigger appears.

1. A term is used in a way that conflicts with its glossary definition → you MUST call it out immediately.
2. A word is vague or overloaded → you MUST propose one precise canonical term and name the alternatives it displaces.
3. A definition or relationship is proposed → you MUST invent concrete scenarios that probe its boundaries.
4. A claim is made about how the domain works → you MUST check whether the code agrees, and surface any contradiction.

## Record the Moment It Lands

- A term is resolved → you MUST update the glossary **in that moment**.
- Glossary updates → you MUST NOT batch them to the end of the session.
- Writing or updating the glossary → read `@context-format.md` and apply it.
- A decision passes the ADR gate below → read `@adr-format.md` and apply it.

## ADRs — the Three-Gate Test

- **Hard to reverse** — changing the decision later carries real cost.
- **Surprising without context** — a future reader would ask why it is this way.
- **A real trade-off was weighed** — genuine alternatives existed and one was chosen for specific reasons.

A decision does not satisfy all three gates → you MUST NOT create an ADR.

## Artifact Locations

- Glossary and ADR artifact role — `design-docs`, with location resolved per `using-omnipowers`; fallback — the glossary at the **host project root** as `CONTEXT.md`, ADRs in `docs/adr/`.
- Placing a glossary or ADR → it MUST NOT be placed under `.omnipowers/` or any other agent-only directory.

## Lazy Creation

- Creating artifacts → you MUST NOT scaffold artifacts ahead of need: no empty `CONTEXT.md`, no empty `docs/adr/`.
- An artifact is absent → you MUST NOT nag about its absence.
