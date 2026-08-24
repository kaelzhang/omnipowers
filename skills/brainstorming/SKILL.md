---
name: brainstorming
description: "Use when about to do creative or implementation work with an unsettled design — building a feature, changing behavior, scaffolding, or any request where a real design question exists — you MUST explore intent and design and get it approved before writing code; a request that already names the change, its site, and the expected outcome is its own spec and is NOT a design round."
---

# Brainstorming Ideas Into Designs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

This skill is a pre-implementation gate.

## Iron Law

YOU MUST NOT WRITE CODE, SCAFFOLD A PROJECT, INVOKE ANY IMPLEMENTATION SKILL, OR TAKE ANY IMPLEMENTATION ACTION UNTIL YOU HAVE WRITTEN A DESIGN SPEC AND THE USER HAS APPROVED THAT WRITTEN SPEC.

- Verbal approval of a design alone MUST NOT satisfy this gate.
- The spec is a committed file by default; the inline-spec escape below scales the artifact, never the approval.
- You catch yourself having started implementation before the written-spec approval → you MUST stop, revert the premature action, and return to this process.
- A design question that reasoning and research cannot settle MAY be answered during the design phase with a throwaway prototype built under the `prototyping` skill's full rule-set; that prototype's verdict MUST feed the spec. Code not built under that skill's rules is implementation and stays forbidden.

## The Gate

- A design question exists → the gate applies whatever the perceived size: a todo list, a single-function utility, and a one-line config change all pass through it.
- Size MUST NOT be a reason to skip. The design MAY be a few sentences for a genuinely simple task; you MUST present it and get approval.

**The floor — a request that is already its own spec.** You MAY proceed without a design round ONLY when ALL of these hold:

1. the user named **what** changes and **where** — you are not choosing the site;
2. the expected outcome is stated or unambiguous;
3. you can name **no** design question worth putting to them — write one in a single line; if you cannot, there is none;
4. nothing beyond the named change is needed to make it work.

Any of the four fails → the gate applies in full. "It's small", "it's obvious", and "it's one line" are **not** among the four. Proceeding under this floor → you MUST say so in one line: `proceeding on your spec as stated`.

**Proportionate ceremony — the one escape from the spec-file ritual.** The committed spec file MAY be replaced by an **inline written spec** ONLY when ALL of these hold: the change is a single step, easily reversed, and its full intent fits in a few sentences. Then you MUST write those sentences out in the conversation (what will change, where, and the expected behavior) and obtain the user's explicit approval of that written text before any code. Multi-step, hard to reverse, or wider than one obvious edit → full committed spec.

## Checklist

You MUST complete these items in order. You MUST NOT skip an item because the task "looks small".

1. **Explore project context** — read the relevant files, docs, and recent commits before asking anything.
2. **Assess scope** — request spans multiple independent subsystems → flag it and decompose before refining details, then run this checklist from step 1 on the first sub-project.
3. **Ask clarifying questions** — one at a time; purpose, constraints, and success criteria.
4. **Propose 2-3 approaches** — with trade-offs and your recommendation, leading with the recommended option; each grounded in the relevant industry's best practice.
5. **Present the design** — in sections scaled to complexity; get approval after each section; not approved → revise and re-present.
6. **Write the design doc** — save the agreed spec and commit it.
7. **Spec self-review** — inline check for placeholders, contradictions, ambiguity, and scope.
8. **User reviews the written spec** — ask the user to review the spec file before proceeding; changes requested → return to step 6.
9. **Transition to implementation** — only after the user approves the written spec.

## The Process

### Understanding the idea

- You MUST examine the current project state first — relevant files, docs, and recent commits — before asking the user anything the project itself can answer.
- You MUST prefer researching over asking: before posing a question, determine whether the answer is discoverable from the codebase, docs, configuration, or conventions. Ask the user only what you genuinely cannot determine yourself.
- Before designing, you MUST search the codebase for an existing implementation of the requested capability — by domain concept, not just keywords — and report where you looked.
- Before refining details, you MUST assess scope. The request describes multiple independent subsystems → you MUST flag this immediately, and you MUST NOT spend questions refining details of a project that needs to be decomposed first.
- The project is too large for a single spec → you MUST help the user decompose it into sub-projects: the independent pieces, how they relate, and the build order. Then brainstorm the first sub-project through the normal design flow; each sub-project gets its own spec → design → implementation cycle.
- For appropriately scoped work, you MUST ask questions one at a time. You MUST NOT bundle multiple questions into one message; a topic needing more exploration → break it into separate questions.
- Questions MUST follow the decision tree's dependency order: settle a parent decision before asking the questions that hang off it.
- You MUST offer concrete options over open-ended prompts. The decision space is enumerable → present multiple-choice or A/B/C options. Open-ended questions are acceptable ONLY when the space genuinely cannot be enumerated.
- Each clarifying question SHOULD carry your recommended answer with a one-line reason (SHOULD — pure-preference questions have no meritable recommendation).
- Each question MUST focus on purpose, constraints, or success criteria.
- The conversation has already explored the intent, approaches, and decisions → the exploration steps above are satisfied; you MUST NOT re-interview ritualistically, and proceed directly to presenting the design and writing the spec. The written-spec gate is unchanged.

### Exploring approaches

- You MUST propose 2-3 distinct approaches with their trade-offs before settling on a design.
- You MUST lead with your recommended option and explain why, then present the alternatives and their trade-offs conversationally.
- The design centers on a module interface and the alternatives are non-obvious → read `@design-it-twice.md` and produce constraint-differentiated alternatives per that method.
- You MUST cut unnecessary features from every design (YAGNI).

### Ground the design in relevant best practice

- Every approach you propose MUST be grounded in the established best practices of the **industry and domain this project's goals belong to** — the norms of *that* field, not generic engineering platitudes — and MUST fit the host project's existing paradigm and conventions.
- The problem is **complex, unfamiliar to you, or in a fast-moving or emerging domain** → you MUST research current authoritative practice (the host's research capability: web search, current official docs, standards) before settling the design, and you MUST NOT rely solely on built-in knowledge. The host offers no research capability → you MUST say the design rests on built-in knowledge and flag that uncertainty to the user. You MUST follow every load-bearing claim back to the source that owns it — official docs, spec, or source code, not a paraphrase (the `researching` skill governs standalone research and its citation discipline).
- You SHOULD apply recognized design doctrines where they fit the domain and the host's paradigm — object-oriented design principles (e.g. SOLID), domain-driven design (bounded contexts, layered domains) for domain-rich systems, clear layering and boundaries — and SHOULD NOT force a paradigm onto a host that follows another; which doctrine applies is domain-dependent judgment.

### Presenting the design

- You believe you understand what is being built → you MUST present the design.
- You MUST scale each section to its complexity: a few sentences if straightforward, up to a few hundred words if nuanced.
- You MUST ask, after each section, whether it looks right so far, and you MUST get approval before moving on.
- The design MUST cover, as applicable: architecture, components, data flow, error handling, and testing. For testing, the design MUST name the public seams tests will exercise and what each verifies — the fewest seams, at the highest level that stays fast and deterministic.
- You MUST be ready to go back and clarify when something does not make sense, and you MUST update the agreed design as understanding sharpens rather than letting the spec drift from the conversation.

### Design for isolation and clarity

- You SHOULD break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently — where the unit boundaries lie is domain-dependent judgment. Prefer deep units: a lot of behavior behind a small interface (the `designing-deep-modules` skill carries the full doctrine).
- The design MUST state, for each unit, what it does, how it is used, and what it depends on, and MUST enumerate each unit's invariants, error modes, ordering constraints, configuration, and performance expectations, not just its signatures.
- You MUST NOT introduce an interface or abstraction layer with only one justified implementation.
- A unit cannot be understood without reading its internals, or its internals cannot change without breaking consumers → you SHOULD refine the boundaries; how much refinement serves the goal is a judgment call.
- A **code** file grows large → the design SHOULD split it; the right boundary depends on the domain. Documentation is judged by structure and navigability, and data / generated files (JSON data, fixtures, snapshots, lockfiles) carry no line-count concern.

### Working in existing codebases

- You MUST explore the current structure before proposing changes, and you MUST follow existing patterns.
- The host project carries a domain glossary (e.g. a `CONTEXT.md`) or architecture decision records → you MUST read them and use their canonical vocabulary in the design; the design contradicts a recorded decision → you MUST flag the contradiction explicitly rather than silently overriding it. These files are absent → proceed silently; you MUST NOT nag the user to create them (the `domain-modeling` skill governs building them).
- Existing code has problems that directly affect the work (a file that has grown too large, unclear boundaries, tangled responsibilities) → you SHOULD include targeted improvements as part of the design; the scope of such improvements is a judgment call about what serves the current goal.
- You MUST NOT propose unrelated refactoring. You MUST stay focused on what serves the current goal.

## After the Design

The user has approved the design and you are about to record it and move to implementation → read `@after-the-design.md` and apply it.

## Red Flags — STOP

Any of these is true → you MUST stop, return to the gate, and do the required action:

| Red flag | Required action |
| --- | --- |
| You are about to write code, scaffold, or edit production files and the user has not approved a design | Present a design first. |
| You skipped exploring the project because the task "looks trivial" | Explore context, then proceed through the checklist. |
| You bundled several questions into one message | Ask one question at a time. |
| You asked the user something the codebase already answers | Research it yourself first. |
| You asked an open-ended question when concrete options exist | Offer enumerable options instead. |
| You started implementation before the user reviewed the written spec | Revert and complete the user review gate. |
| The request spans multiple independent subsystems and you began refining details | Decompose first, then brainstorm the first sub-project. |
| You settled a design for a complex or emerging-domain problem purely from memory | Research current authoritative practice, or explicitly flag that the design rests on built-in knowledge. |

## Rationalizations — all REJECTED

| Rationalization | Ruling |
| --- | --- |
| "This is too simple to need a design." | A short design is required; skipping is not allowed. |
| "The user clearly knows what they want, so I'll just build it." | The gate still applies. |
| "I'll design as I implement; it's faster." | The design MUST come first. |
| "I already started, so finishing is fine." | Premature implementation MUST be reverted, not continued. |
| "Asking the user is quicker than reading the code." | You MUST research before asking. |
| "Open-ended questions give richer answers." | Use concrete options wherever the space is enumerable. |
| "I'll write the spec after I review the user's approval verbally." | The spec MUST be written, committed, and user-reviewed before implementation. |
| "I already know the best practice here." | For complex or emerging domains, research current practice; recall alone is not grounding. |
