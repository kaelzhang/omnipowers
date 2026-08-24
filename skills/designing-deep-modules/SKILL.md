---
name: designing-deep-modules
description: Use when designing or restructuring a module, interface, service, wrapper, layer, or API surface — placing a seam, or adding an abstraction "for testability" or "to keep it clean" — you MUST make every module deep, substantial behavior behind a small fully-specified interface, with no pass-throughs and no single-implementation abstractions
---

# Designing Deep Modules

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- A **deep module** puts a large amount of behavior behind a small interface, placed at a clean seam.
- Depth is the design target for every module you create or reshape.
- **Core principle:** design to minimize what callers must know, not what the implementation contains.

## Vocabulary

You MUST use these terms with these meanings when discussing or documenting a design:

- **Module** — anything with an interface and an implementation: a function, class, package, or service. Deliberately scale-agnostic.
- **Interface** — everything a caller must know to use the module correctly (see *The Interface Is Everything a Caller Must Know*), not just the type signature.
- **Depth** — the behavior a caller can exercise per unit of interface learned. Deep: small interface, large behavior. Shallow: an interface nearly as complex as the implementation behind it.
- **Seam** — the place where a module's interface lives and where an implementation can vary without editing callers. Where the seam goes is its own design decision, separate from what goes behind it.

"Boundary" keeps its ordinary uses (layering, bounded contexts); say "seam" when you mean specifically the place an interface lives.

## The Deletion Test

Before accepting any module — new or reshaped — you MUST run the deletion test: imagine deleting the module and re-reading its callers.

- Callers barely change — they already had the pieces, or would simply call one level down → the module is a **pass-through**; you MUST deepen it (move real behavior inside) or remove it (inline it).
- Real logic would smear across N callers → the module is earning its depth; keep it.

## The Two-Adapter Rule

- You MUST NOT introduce an interface, port, or abstraction layer that has only one justified implementation.
- An abstraction is justified only when at least two implementations serve a real need **today** — a second production variant, or a genuine test adapter for a dependency that cannot run in tests.
- Variation becomes real later → introduce the seam then.

## The Interface Is Everything a Caller Must Know

For every module you design, you MUST enumerate the full interface:

- **Invariants** — what the module guarantees, and what it requires callers to uphold.
- **Error modes** — what can fail, how failure is reported, what state remains after failure.
- **Ordering constraints** — what must be called before what; what may not be called twice.
- **Required configuration** — setup, environment, and wiring a caller must provide.
- **Performance expectations** — complexity, blocking behavior, caching, allocation patterns a caller may rely on.

Anything a caller must know that the interface does not state is still part of the interface.

The enumeration reveals a sprawling contract over a thin implementation → the module is shallow, and you MUST redesign it, not document your way around it.

## Testability by Construction

- You MUST be able to test the module's behavior through its interface alone. Testing it would require reaching past the interface into internals → the seam is wrong, and you MUST reshape the module rather than pry it open for tests.
- Tests MUST assert observable outcomes through the interface, not internal state.
- A deep implementation MAY be composed of smaller private parts with their own internal seams; those internal seams MUST NOT be promoted into the interface because tests find them convenient.
- You SHOULD accept dependencies rather than construct them internally, and SHOULD return results rather than mutate shared state.

## Deepening Existing Shallow Modules

When restructuring code that already exists — merging a cluster of thin wrappers into one deep module, deciding how the deepened module's dependencies (databases, owned remote services, third-party APIs) are handled, or migrating the old tests — read `@deepening.md` and apply it.

## Red Flags — STOP

Any of these is true → the design fails this skill and you MUST rework it:

- A module whose methods mostly delegate to identically-shaped methods one level down.
- An interface with roughly as many operations as the implementation has functions.
- An interface, trait, or port with exactly one implementation and no concrete second in sight.
- A wrapper added "to keep the layers clean" that contributes no behavior.
- Tests that import a module's internals instead of its interface.
- A caller that must read the module's source to use it correctly — unstated invariants, ordering, or error modes.
- You cannot state in one sentence what a caller gains from the module existing.

## Rationalizations — Rejected

| Excuse | Reality |
|---|---|
| "We might need to swap implementations later" | Speculative variation. Introduce the seam when the second implementation is real. |
| "A wrapper keeps it clean" | A pass-through is a hop; it does not reduce what a caller must know. |
| "Every dependency should sit behind an interface" | The two-adapter rule decides per dependency, not by policy. |
| "Smaller modules are always better" | Depth is the measure, not size. |
| "The types document the contract" | Invariants, error modes, ordering, configuration, and performance are part of the interface whether or not you state them. |
| "It's easier to test the internals directly" | A test past the interface is welded to the implementation, not to the behavior. |

## Checklist

Before calling a module design done, you MUST be able to check every box:

- [ ] Deletion test run; no pass-through modules remain
- [ ] Every abstraction has at least two justified implementations
- [ ] Full interface enumerated: invariants, error modes, ordering, configuration, performance
- [ ] Behavior is testable through the interface alone
- [ ] One sentence states what a caller gains from each module
