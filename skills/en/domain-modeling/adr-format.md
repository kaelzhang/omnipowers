# ADR Format

ADR-format load condition — a decision has passed all three gates (hard to reverse, surprising without context, real trade-off weighed) and you are writing the ADR.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Template

```md
# {Short title naming the decision}

{YYYY-MM-DD}

{One paragraph: the situation, what was decided, and why — including what the
choice cost or ruled out.}
```

A section, header, or field beyond this template carries no real content → you MUST NOT add it.

## Optional sections

- Adding an **Alternatives** section → it MAY be added only when the rejected options are worth remembering, meaning someone plausibly re-proposes them later.
- Adding a **Consequences** section → it MAY be added only when a non-obvious downstream effect needs to be on record.
- A decision is actually revisited → a **Status** field (`accepted | superseded by ADR-NNNN`) MAY be added.
