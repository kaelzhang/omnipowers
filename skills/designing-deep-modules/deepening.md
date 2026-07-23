# Deepening Shallow Modules

**Load this reference when:** restructuring existing shallow modules — merging thin wrappers into a deep module, deciding how the deepened module's dependencies are handled and tested, or migrating the old test suite.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

This reference uses the skill's vocabulary: **module**, **interface**, **depth**, **seam**.

## Classify Each Dependency First

Before deepening a cluster of shallow modules, you MUST classify every dependency the resulting module will have. The category determines whether the dependency stays inside the implementation or becomes an injected port — and therefore how the deepened module is tested. Skipping this step is how deepening reintroduces shallowness: the wrong category adds ports nobody needs or leaves untestable I/O buried inside.

### 1. In-process

Pure computation and in-memory state; no I/O. Always deepenable: merge the shallow modules into one deep module and test directly through the new interface. No injected adapter, no new seam.

### 2. Local-substitutable

Real infrastructure with a faithful local stand-in that can run inside the test suite (an embedded or in-process database, an in-memory filesystem). Deepenable whenever the stand-in exists: tests run against the stand-in, and the dependency stays inside the implementation. You MUST NOT surface it as a port on the module's interface just for testing — that widens the interface to solve a problem the stand-in already solves.

### 3. Remote but owned

The host project's own services across a network (internal APIs, microservices, queues). Define a port at the seam: the deep module owns the logic; the transport is injected as an adapter. Production uses the network adapter (HTTP, gRPC, queue); tests use an in-memory adapter. Both adapters serve a real need, so the port satisfies the two-adapter rule.

### 4. True external

Third-party services the host project does not control (payment processors, messaging providers). The deepened module MUST take the dependency as an injected port; tests provide a mock adapter that encodes the third-party behavior the module relies on, pinning it so drift is caught.

## Seam Discipline

- A port is justified only in categories 3 and 4, where production and test adapters are both real. Categories 1 and 2 need no port at the interface; adding one anyway makes the freshly deepened module shallow again.
- The implementation MAY keep private internal seams for its own structure. They MUST NOT be exposed through the interface because tests find them convenient — the interface serves callers, and tests cross it the same way callers do.

## Test Migration: Replace, Don't Layer

Deepening obsoletes the implementation-coupled tests of the absorbed shallow modules. You MUST replace them, in this order:

1. **Write interface-level tests first.** Cover, through the deepened module's interface, the same observable behavior the old tests guarded. Assert outcomes a caller can see, never internal state.
2. **Verify equivalent coverage.** Walk the old suite as a checklist: every behavior it guarded is now exercised through the interface. Until this holds, both suites stay.
3. **Then delete the implementation-coupled tests.** Only after coverage is equivalent.

Deleting before step 2 completes drops the safety net mid-restructure. Keeping both suites afterward is layering, not replacing: the old tests weld the deep module to its former internal structure, break on every internal refactor with no behavior change, and train everyone to ignore red suites.

The property to preserve: the new tests survive internal refactors. If a test must change when the implementation changes but the behavior does not, it tests past the interface — fix that test before proceeding.
