# Design It Twice — Constraint-Differentiated Alternatives

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Differentiate by Constraint

Producing alternative designs under `brainstorming` → you MUST differentiate the attempts by constraint, assigning each attempt one design constraint orthogonal to the others.

## Step 1 — Write the Shared Problem Statement

- Before producing any design → you MUST write a problem statement shared by all attempts: what the module must accomplish, who its callers are, and the hard external constraints.
- Writing the shared problem statement → it MUST NOT contain a candidate design, a sketch, or a preferred direction.

## Step 2 — Produce the Designs Independently

Producing the alternatives → you MUST produce two designs, one per constraint.

A third orthogonal constraint applies → you MAY add a third design.

Producing each design → it MUST deliver:

1. the interface itself — entry points, signatures, invariants, error modes;
2. one caller-side usage example;
3. what the implementation hides behind the interface.

- Subagents receive design assignments → each subagent MUST receive only the shared problem statement plus its own constraint, with no shared draft, sibling's output, or hint of your leaning.
- The host has no subagents and you are producing the second design → you MUST NOT edit the first design.
- The host has no subagents and the first design is already on the page → the second MUST NOT inherit the first's shape merely on that basis.

## Step 3 — Compare Interfaces, Not Implementations

Depth — behavior hidden by each entry point relative to its interface surface.

Deletion test — whether rewriting the implementation from the interface contract permits changes to data structures and algorithms without caller changes, or requires reproducing the old internals.

Locality of change — whether the interface confines anticipated changes behind the boundary or spills them into callers.

Comparing the designs → you MUST compare them at the interface only.

A design has an elegant implementation and a shallow interface → the implementation MUST NOT rescue the interface.

## Step 4 — Synthesize and Hand Back

- Selecting the result → you MUST pick a winner and state, per criterion, why it won.
- The runner-up's single best idea strengthens the winning shape → the winner MAY graft that idea.
- Synthesizing the designs → you MUST NOT average them into a compromise that satisfies neither constraint.
