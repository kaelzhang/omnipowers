# ADR Format

**Load this reference when:** a decision has passed all three gates (hard to reverse, surprising without context, real trade-off weighed) and you are writing the ADR.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Location and naming

ADRs live in `docs/adr/` at the host project root (or the location the user confirmed for this project). Files are numbered sequentially with a slug: `0001-event-sourced-orders.md`, `0002-postgres-for-write-model.md`. To number a new ADR, scan `docs/adr/` for the highest existing number and increment by one. Create the directory only together with the first ADR.

## Template

```md
# {Short title naming the decision}

{YYYY-MM-DD}

{One paragraph: the situation, what was decided, and why — including what the
choice cost or ruled out.}
```

That is the entire template. The value of an ADR is that the decision and its *why* are recorded at all — a one-paragraph ADR that exists beats a ten-section ADR that never got written. **A template too heavy to fill is why ADRs die**; you MUST NOT add sections, headers, or fields beyond this template unless they carry real content (below).

## Optional sections

Most ADRs need neither. Add one ONLY when it carries real content:

- **Alternatives** — MAY be added only when the rejected options are worth remembering, i.e. someone plausibly re-proposes them later. "We considered other approaches" is not content; delete it.
- **Consequences** — MAY be added only when a non-obvious downstream effect needs to be on record. Restating the decision is not a consequence.

A `Status` line (`accepted | superseded by ADR-NNNN`) MAY be added when a decision is actually revisited — not speculatively.

## What qualifies

- **Architectural shape.** "We use a monorepo." "The write model is event-sourced; the read model is projected into Postgres."
- **Integration patterns between parts.** "Ordering and Billing communicate via domain events, never synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target — the ones that would take a quarter to swap, not every library.
- **Boundary and ownership decisions.** "Customer data is owned by the Customer context; others reference it by ID only."
- **Deliberate deviations from the obvious path.** "Raw SQL instead of an ORM, because X." These stop the next engineer from "fixing" something deliberate.
- **Constraints invisible in the code.** "No cloud provider Y — compliance." "Responses under 200 ms — partner contract."
- **Explicit NO-decisions.** "We will not X because Y" is as valuable as any yes — it stops X from being re-proposed every quarter. Record rejections whenever the rejection is non-obvious.
