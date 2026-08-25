# Design It Twice — Constraint-Differentiated Alternatives

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this during the approaches-exploration step of `brainstorming` (checklist item 4, "Propose 2-3 approaches") when the design centers on a **module interface** and the alternatives are non-obvious.

## Differentiate by constraint

A second design produced by staring at the first is a variation, not an alternative — the first idea anchors everything after it.

You MUST differentiate the attempts by **constraint**: assign each attempt one design constraint orthogonal to the others. Pick constraints that pull in genuinely different directions for *this* module, for example:

- "Optimize the caller's ergonomics — the common case reads as one obvious call, even if the implementation gets ugly."
- "Optimize for testability through the interface alone — every behavior observable and forceable without reaching into internals."
- "Minimize the interface surface at all costs — the fewest entry points and types that still cover every caller."
- "Maximize room to evolve — adding the next likely capability changes no existing signature."

## Step 1 — Write the shared problem statement

- Before producing any design, you MUST write a problem statement that all attempts share: what the module must accomplish, who its callers are, and the hard external constraints (data shapes, protocols, invariants that are not yours to choose).
- The problem statement MUST NOT contain a candidate design, a sketch, or a preferred direction.

## Step 2 — Produce the designs independently

You MUST produce two designs, one per constraint; a third MAY be added when a third genuinely orthogonal constraint applies. Each design MUST deliver:

1. the interface itself — entry points, signatures, invariants, error modes;
2. one caller-side usage example;
3. what the implementation hides behind the interface.

- The host provides subagents → dispatch one subagent per constraint, in parallel. Each subagent MUST receive only the shared problem statement plus its own constraint — no shared draft, no sibling's output, no hint of your own leaning.
- The host has no subagents → degrade gracefully: produce the designs yourself, sequentially. Write the first design down completely, set it aside, then adopt the second constraint fresh, working from the problem statement as if the first attempt did not exist. You MUST NOT edit the first design while producing the second, and the second MUST NOT inherit the first's shape merely because it is already on the page.

## Step 3 — Compare interfaces, not implementations

You MUST compare the designs at the interface only — an elegant implementation MUST NOT rescue a shallow interface. Judge each design on:

- **Depth** — how much behavior each entry point hides. A deep interface offers callers a small, simple surface over substantial functionality; an interface that mirrors its internals is shallow no matter how clean the code behind it.
- **The deletion test** — delete the implementation and imagine rewriting it from the interface contract alone. The rewrite could freely change data structures and algorithms without any caller noticing → the interface hides real decisions. The rewrite would be forced to reproduce the old internals → the interface leaks them.
- **Locality of change** — for the changes this module will plausibly face, which interface confines them behind the boundary, and which spills them into callers.

## Step 4 — Synthesize and hand back

- You MUST pick a winner and state, per criterion, why it won.
- The winner MAY graft the runner-up's single best idea where it strengthens the winning shape; you MUST NOT average the designs into a compromise that satisfies neither constraint.
- Carry the winner, and the runner-up with its trade-offs, back into the approaches you present at checklist item 4.
