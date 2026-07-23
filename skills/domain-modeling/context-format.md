# Glossary Format — CONTEXT.md

**Load this reference when:** writing or updating a project glossary (`CONTEXT.md`), or structuring a multi-context repository (`CONTEXT-MAP.md`).

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

- **Definitions are IS-statements.** Each definition MUST say what the term *is* in one or two sentences — not what it does, how it is implemented, or where it lives in the code.
- **Every term carries an `_Avoid_` line** listing its banned synonyms. This line is the anti-synonym-drift device: it converts "we picked one word" into a rule any future reader or agent can enforce mechanically. A term with competing words in circulation and no `_Avoid_` line is unfinished.
- **Be opinionated.** When several words compete for one concept, you MUST pick a single canonical term; every displaced word goes under `_Avoid_`.
- **Purity.** The file is the glossary and nothing else. It MUST NOT contain specs, requirements, decision history, implementation details, or TODOs — decisions belong in ADRs, specs belong wherever the host project keeps specs. A glossary that accretes other content stops being consulted as a glossary.
- **Project-specific concepts only.** General programming and infrastructure terms (timeout, retry, cache, queue) MUST NOT appear, however heavily the project uses them. Before adding a term, ask: is this concept unique to *this* domain, or generic? Only the former belongs.
- **Relationships section.** One line per relation, naming both terms in bold. Relations with cardinality or direction ("many", "exactly one", "after delivery") say more than bare arrows.
- **Grouping.** Terms MAY be grouped under subheadings when natural clusters emerge; a flat list is fine when they don't. Do not invent clusters to look organized.

## Multi-context repositories — the minority case

Most repositories are a single bounded context and need exactly one root `CONTEXT.md`. Only when a repository genuinely contains multiple bounded contexts — independent sub-domains where the *same word legitimately means different things* — does the split structure apply:

- A root `CONTEXT-MAP.md` lists each context, where its `CONTEXT.md` lives, and the **direction** of each relationship between contexts (who emits, who consumes, what is shared).
- Each context keeps its own `CONTEXT.md` inside its directory.

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them
- **Ordering ↔ Billing**: shared types for `CustomerId` and `Money`
```

Routing: if a `CONTEXT-MAP.md` exists, read it to determine which context the current topic belongs to; if the context is unclear, ask the user. You MUST NOT introduce the multi-context structure pre-emptively — keep a single root `CONTEXT.md` until a second bounded context actually exists.
