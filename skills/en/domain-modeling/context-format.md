# Glossary Format — CONTEXT.md

Glossary-format load condition — writing or updating a project glossary (`CONTEXT.md`), or structuring a multi-context repository (`CONTEXT-MAP.md`).

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Structure

```md
# {Project or Context Name}

{One or two sentences: what this context is and why it exists.}

## Language

**Order**:
A customer's confirmed request for goods, priced and ready to fulfill.
_Avoid_: purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: client, buyer, account

## Relationships

- A **Customer** places many **Orders**
- An **Order** yields exactly one **Invoice** after delivery
```

## Rules

- Writing a definition → it MUST say what the term *is* in one or two sentences, rather than what it does, how it is implemented, or where it lives in the code.
- Several words compete for one concept → you MUST pick a single canonical term.
- `_Avoid_` — the line listing every displaced word.
- Writing the glossary → it MUST NOT contain specs, requirements, decision history, implementation details, or TODOs.
- General programming and infrastructure terms (timeout, retry, cache, queue) → they MUST NOT appear in the glossary, however heavily the project uses them.
- Natural clusters emerge → terms MAY be grouped under subheadings.

## Multi-context repositories

Bounded contexts — independent sub-domains where the same word legitimately means different things.

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them
- **Ordering ↔ Billing**: shared types for `CustomerId` and `Money`
```

Before a second bounded context exists → you MUST NOT introduce the multi-context structure.
