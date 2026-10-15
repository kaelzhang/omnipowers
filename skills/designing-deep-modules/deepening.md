# Deepening Shallow Modules

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Classify Each Dependency First

Before deepening a cluster of shallow modules → you MUST classify every dependency the resulting module will have into one of these four categories.

### 1. In-process

**In-process dependency** — pure computation and in-memory state; no I/O.

### 2. Local-substitutable

**Local-substitutable dependency** — real infrastructure with a faithful local stand-in that can run inside the test suite.

A local stand-in exists → you MUST NOT surface the dependency as a port on the module's interface just for testing.

### 3. Remote but owned

**Remote but owned dependency** — the host project's own services across a network.

### 4. True external

**True external dependency** — third-party services the host project does not control.

The dependency is true external → the deepened module MUST take the dependency as an injected port.

## Seam Discipline

- When structuring the implementation → it MAY keep private internal seams.
- Tests find private internal seams convenient → those seams MUST NOT be exposed through the interface on that basis.

## Test Migration: Replace, Don't Layer

When deepening absorbs shallow modules → you MUST replace their implementation-coupled tests by performing these steps in order:

1. Write interface-level tests first; cover, through the deepened module's interface, the same observable behavior the old tests guarded; assert outcomes a caller can see, never internal state.
2. Verify equivalent coverage by walking the old suite as a checklist; keep both suites until every behavior the old suite guarded is exercised through the interface.
3. After verifying equivalent coverage → delete the implementation-coupled tests.
