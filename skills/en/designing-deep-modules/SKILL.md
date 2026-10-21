---
name: designing-deep-modules
description: Use when designing or restructuring a module, interface, service, wrapper, layer, or API surface — decoupling or layering it ("解耦", "分层"), placing a seam, or adding an abstraction "for testability" or "to keep it clean" — you MUST make every module deep, substantial behavior behind a small fully-specified interface, with no pass-throughs and no single-implementation abstractions
---

# Designing Deep Modules

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Vocabulary

When discussing or documenting a design → you MUST use these terms with these meanings:

- **Module** — anything with an interface and an implementation: a function, class, package, or service.
- **Interface** — everything a caller must know to use the module correctly, including requirements unstated by the module, not just the type signature.
- **Depth** — the behavior a caller can exercise per unit of interface learned.
- **Deep module** — a module with a small interface and a large amount of behavior behind it.
- **Shallow module** — a module with an interface nearly as complex as its implementation.
- **Seam** — the place where a module's interface lives and where an implementation can vary without editing callers.

## The Deletion Test

Before accepting any module — new or reshaped → you MUST run the deletion test: imagine deleting the module and re-reading its callers.

- Deleting the module leaves callers with the same pieces or calling one level down → you MUST deepen it (move real behavior inside) or remove it (inline it).

## The Two-Adapter Rule

- **Justified abstraction** — an abstraction with at least two implementations serving a real need today: a second production variant, or a genuine test adapter for a dependency that cannot run in tests.
- When introducing an interface, port, or abstraction layer → you MUST NOT give it only one justified implementation.

## The Interface Is Everything a Caller Must Know

For every module you design → you MUST enumerate the full interface:

- **Invariants** — what the module guarantees, and what it requires callers to uphold.
- **Error modes** — what can fail, how failure is reported, what state remains after failure.
- **Ordering constraints** — what must be called before what; what may not be called twice.
- **Required configuration** — setup, environment, and wiring a caller must provide.
- **Performance expectations** — complexity, blocking behavior, caching, allocation patterns a caller may rely on.

The enumeration reveals a sprawling contract over a thin implementation → you MUST redesign the module, not document your way around it.

## Testability by Construction

- When designing a module → you MUST be able to test its behavior through its interface alone.
- Testing the module would require reaching past the interface into internals → you MUST reshape the module rather than pry it open for tests.
- When testing a module → tests MUST assert observable outcomes through the interface, not internal state.
- When composing a deep implementation → you MAY use smaller private parts with their own internal seams.
- Tests find internal seams convenient → those seams MUST NOT be promoted into the interface on that basis.
- When designing a module → you SHOULD accept dependencies rather than construct them internally.
- When designing a module → you SHOULD return results rather than mutate shared state.

## Deepening Existing Shallow Modules

When restructuring code that already exists — merging a cluster of thin wrappers into one deep module, deciding how the deepened module's dependencies (databases, owned remote services, third-party APIs) are handled, or migrating the old tests — read `@deepening.md` and apply it.

## Red Flags — STOP

Any of these is true → you MUST rework the design:

- A module whose methods mostly delegate to identically-shaped methods one level down.
- An interface with roughly as many operations as the implementation has functions.
- An interface, trait, or port with exactly one implementation and no concrete second in sight.
- A wrapper added "to keep the layers clean" that contributes no behavior.
- Tests that import a module's internals instead of its interface.
- A caller that must read the module's source to use it correctly — unstated invariants, ordering, or error modes.
- You cannot state in one sentence what a caller gains from the module existing.

## Checklist

Before calling a module design done → you MUST be able to check every box:

- [ ] Deletion test run; no pass-through modules remain
- [ ] Every abstraction has at least two justified implementations
- [ ] Full interface enumerated: invariants, error modes, ordering, configuration, performance
- [ ] Behavior is testable through the interface alone
- [ ] One sentence states what a caller gains from each module
