# Spec Document Template

**Load this reference when:** writing the design doc (the spec) — the spec file
MUST follow the structure below.

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD,
> SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14
> (RFC 2119, RFC 8174), and only when capitalized.

## The Durability Rule

The spec MUST NOT embed file paths, line numbers, or code — the implementation
plan carries them, not the spec.

**The one exception:** a prototype-derived snippet MAY be embedded ONLY when
the snippet itself IS the recorded decision — an agreed schema, state table,
type signature, or transition function whose exact shape prose cannot pin
down. Embed only the decision-carrying portion, place it inside the decision
it settles, and note that it came from a prototype.

## The Template

All six sections MUST appear, in this order. Scale each section's length to
the task — a genuinely simple task yields a short spec, never a missing
section.

```markdown
# <Topic> — Design Spec

## Problem

What hurts today, and for whom. Concrete symptoms from the affected
user's perspective — not a restatement of the intended solution.

## Solution

The agreed design: what will exist when the work is done and how its
parts fit together. Prose carries the design; a diagram MAY support
the prose but MUST NOT replace it.

## User Stories

Only the stories that bind scope, each in the form:

- As a <actor>, I want <capability>, so that <benefit>.

A story earns its place by constraining what gets built. If deleting
a story would change nothing about the implementation, delete it.

## Implementation Decisions

Every decision settled during design, each with its why: architecture
choices, unit boundaries and their interfaces, data shapes and
contracts, and prototype verdicts (what a prototype proved or ruled
out). The why is REQUIRED per decision — a decision recorded without
its reason cannot be defended or safely revisited later.

## Testing Decisions

The public seams the tests will exercise, and what each seam's tests
verify. Tests verify externally observable behavior at the seam,
never internals. Existing seams are preferred over new ones; the
fewer seams, the better.

## Out of Scope

REQUIRED — never omitted, never empty: every task has a boundary,
and an empty section means the boundary was never examined. List
each explicit exclusion with a one-line reason. This section is the
gold-plating guard: excluded work MUST NOT creep into the
implementation; scope grows only by returning to the user.
```

A spec written from this template MUST still pass the spec self-review in this
skill's `SKILL.md` (no placeholders, internally consistent, single-cycle
scope, unambiguous) before it goes to the user.
