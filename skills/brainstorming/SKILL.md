---
name: brainstorming
description: "Use when about to do creative or implementation work with an unsettled design — building a feature, changing behavior, scaffolding, or any request where a real design question exists — you MUST explore intent and design and get it approved before writing code; a request that already names the change, its site, and the expected outcome is its own spec and is NOT a design round."
---

# Brainstorming Ideas Into Designs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

This skill is a pre-implementation gate. Before any creative or implementation work, you MUST turn the idea into an explored, agreed design through collaborative dialogue, then get the user's approval. You MUST start by understanding the current project context, ask questions one at a time to refine the idea, prefer researching over asking, offer concrete options over open-ended prompts, and keep the agreed spec updated as understanding sharpens.

## Iron Law

YOU MUST NOT WRITE CODE, SCAFFOLD A PROJECT, INVOKE ANY IMPLEMENTATION SKILL, OR TAKE ANY IMPLEMENTATION ACTION UNTIL YOU HAVE WRITTEN A DESIGN SPEC AND THE USER HAS APPROVED THAT WRITTEN SPEC. Verbal approval of a design alone MUST NOT satisfy this gate. The spec is a committed file by default; the single proportionate-ceremony escape (an inline written spec for a trivial, single-step, easily reversed change — see the Anti-Pattern section) scales the artifact, never the approval.

This applies regardless of perceived simplicity: a todo list, a single-function utility, and a one-line config change all pass through this gate when a design question exists. The one thing that does lift it is the absence of a question to ask — see "The floor" below, which is about what the request already settled, never about how small it looks. If you catch yourself starting implementation before the written-spec approval, you MUST stop, revert any premature action, and return to this process.

**The one code-shaped exception:** a design question that reasoning and research cannot settle MAY be answered during the design phase with a throwaway prototype built under the `prototyping` skill's full rule-set — such code does not violate this gate, and its verdict MUST feed the spec. Anything not built under that skill's rules is implementation and stays forbidden.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every task with a design question goes through this process. "Simple" tasks are exactly where unexamined assumptions cause the most wasted work, because the gate gets skipped and the wrong thing gets built fast. Size is never the reason to skip; the only reason is that the request left no question to ask. The design MAY be short — a few sentences for a genuinely simple task — but you MUST present it and get approval. Brevity is permitted; skipping is not.

**The floor — a request that is already its own spec.** This gate exists to surface intent the request left unstated. Where the request states it completely, the design is already written *and* approved: it is the user's own instruction. Asking them to approve it hands their instruction back as a question, costs a round trip, and delivers nothing — the user asked for work and received a form.

You MAY proceed without a design round ONLY when ALL of these hold:

1. the user named **what** changes and **where** — you are not choosing the site;
2. the expected outcome is stated or unambiguous;
3. you can name **no** design question worth putting to them — try to write one in a single line; if you cannot, there is none;
4. nothing beyond the named change is needed to make it work.

If any of the four fails, the gate applies in full. "It's small", "it's obvious", and "it's one line" are **not** among the four: a one-line change carrying a real design question still takes the gate, and a large change whose spec the user wrote out completely does not. When you do proceed under this floor, you MUST say so in one line ("proceeding on your spec as stated") so the skip is visible and the user can stop you.

**Proportionate ceremony — the one escape from the spec-file ritual.** The committed-spec-file ceremony MAY be replaced by an **inline written spec** ONLY when ALL of these hold: the change is a single step, easily reversed, and its full intent fits in a few sentences. Then you MUST still write those sentences out in the conversation (what will change, where, and the expected behavior) and obtain the user's explicit approval of that written text before any code. The approval gate never scales down — only the artifact does. Anything multi-step, hard to reverse, or wider than one obvious edit takes the full committed spec.

## Checklist

You MUST complete these items in order. You MUST NOT skip an item because the task "looks small".

1. **Explore project context** — read the relevant files, docs, and recent commits before asking anything.
2. **Assess scope** — if the request spans multiple independent subsystems, flag it and decompose before refining details.
3. **Ask clarifying questions** — one at a time; understand purpose, constraints, and success criteria.
4. **Propose 2-3 approaches** — with trade-offs and your recommendation, leading with the recommended option; each grounded in the relevant industry's best practice (researched, not recalled, when the problem is complex or the domain emerging).
5. **Present the design** — in sections scaled to complexity; get approval after each section.
6. **Write the design doc** — save the agreed spec and commit it.
7. **Spec self-review** — inline check for placeholders, contradictions, ambiguity, and scope.
8. **User reviews the written spec** — ask the user to review the spec file before proceeding.
9. **Transition to implementation** — only after the user approves the written spec.

## Process Flow

```
Explore project context
        |
        v
Assess scope --(multiple subsystems)--> Decompose into sub-projects --> (brainstorm first sub-project)
        |
        v
Ask clarifying questions (one at a time)
        |
        v
Propose 2-3 approaches (with recommendation)
        |
        v
Present design sections <----------------+
        |                                 |
        v                                 |
User approves design? --(no, revise)-----+
        | yes
        v
Write design doc
        |
        v
Spec self-review (fix inline)
        |
        v
User reviews spec? --(changes requested)--> Write design doc
        | approved
        v
Transition to implementation
```

The terminal state is the user approving the written spec. You MUST NOT take any implementation action before reaching it.

## The Process

### Understanding the idea

- You MUST examine the current project state first — relevant files, docs, and recent commits — before asking the user anything that the project itself can answer.
- You MUST prefer researching over asking. Before posing a question to the user, determine whether the answer is already discoverable from the codebase, docs, configuration, or conventions. Ask the user only what you genuinely cannot determine yourself.
- Before refining details, you MUST assess scope. If the request describes multiple independent subsystems (for example "a platform with chat, file storage, billing, and analytics"), you MUST flag this immediately. You MUST NOT spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, you MUST help the user decompose it into sub-projects: identify the independent pieces, how they relate, and the build order. You then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → design → implementation cycle.
- For appropriately scoped work, you MUST ask questions one at a time. You MUST NOT bundle multiple questions into one message; if a topic needs more exploration, break it into multiple separate questions.
- Questions MUST follow the decision tree's dependency order: settle a parent decision before asking the questions that hang off it, because an early answer reshapes which later questions exist at all. This ordering is why questions arrive singly — a firehose of parallel questions loses the structure that makes the interview converge.
- You MUST offer concrete options over open-ended prompts. When the decision space is enumerable, present multiple-choice or A/B/C options rather than asking "what do you want?". Open-ended questions are acceptable only when the space genuinely cannot be enumerated.
- Each clarifying question SHOULD carry your recommended answer with a one-line reason, so the user reacts to a proposal instead of a blank prompt (SHOULD, because pure-preference questions have no meritable recommendation).
- Each question MUST focus on understanding purpose, constraints, or success criteria.
- Before designing, you MUST search the codebase for an existing implementation of the requested capability — by domain concept, not just keywords — and report where you looked. Rebuilding what already exists is a design failure no amount of good design repairs.
- When the conversation has already explored the intent, approaches, and decisions (a long working discussion), the exploration steps above are satisfied — you MUST NOT re-interview ritualistically; proceed directly to presenting the design and writing the spec. The Iron Law is unchanged: the written, approved spec still gates implementation.

### Exploring approaches

- You MUST propose 2-3 distinct approaches with their trade-offs before settling on a design.
- You MUST lead with your recommended option and explain why, then present the alternatives and their trade-offs conversationally.
- When the design centers on a module interface and the alternatives are non-obvious, read `@design-it-twice.md` and produce constraint-differentiated alternatives per that method.

### Ground the design in relevant best practice

- Every approach you propose MUST be grounded in the established best practices of the **industry and domain this project's goals belong to** — the norms of *that* field (a payments system follows payment-industry norms; a realtime pipeline follows that domain's norms), not generic engineering platitudes — and MUST fit the host project's existing paradigm and conventions.
- When the problem is **complex, unfamiliar to you, or in a fast-moving or emerging domain**, you MUST actively research current authoritative practice (the host's research capability: web search, current official docs, standards) before settling the design. You MUST NOT rely solely on built-in knowledge for such problems — it lags and misleads precisely where the domain is new. If the host offers no research capability, you MUST say the design rests on built-in knowledge and flag that uncertainty to the user. Follow every load-bearing claim back to the source that owns it — official docs, spec, or source code, not a paraphrase (the `researching` skill governs standalone research and its citation discipline).
- You SHOULD apply recognized design doctrines where they fit the domain and the host's paradigm — object-oriented design principles (e.g. SOLID), domain-driven design (bounded contexts, layered domains) for domain-rich systems, clear layering and boundaries — and SHOULD NOT force a paradigm onto a host that follows another; which doctrine applies is domain-dependent judgment.

### Presenting the design

- Once you believe you understand what is being built, you MUST present the design.
- You MUST scale each section to its complexity: a few sentences if straightforward, up to a few hundred words if nuanced.
- You MUST ask, after each section, whether it looks right so far, and you MUST get approval before moving on (incremental validation).
- The design MUST cover, as applicable: architecture, components, data flow, error handling, and testing. For testing, the design MUST name the public seams tests will exercise and what each verifies — the fewest seams, at the highest level that stays fast and deterministic — so the test boundaries are agreed with the user at design time, not invented during implementation.
- You MUST be ready to go back and clarify when something does not make sense, and you MUST update the agreed design as understanding sharpens rather than letting the spec drift from the conversation.

### Design for isolation and clarity

- You SHOULD break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently — where the unit boundaries lie is domain-dependent judgment, so it varies by situation. Prefer deep units: a lot of behavior behind a small interface (the `designing-deep-modules` skill carries the full doctrine).
- The design MUST state, for each unit, what it does, how it is used, and what it depends on. An interface is everything a caller must know — the design MUST enumerate each unit's invariants, error modes, ordering constraints, configuration, and performance expectations, not just its signatures.
- You MUST NOT introduce an interface or abstraction layer with only one justified implementation — abstraction is earned by a second real implementer, not by "we might need it later".
- If someone cannot understand what a unit does without reading its internals, or you cannot change the internals without breaking consumers, the boundaries need work and you SHOULD refine them — how much refinement serves the goal is a judgment call.
- Smaller, well-bounded units are easier to work with and edit reliably. When a **code** file grows large, that is a signal it is doing too much, and the design SHOULD split it — judgment applies because the right boundary depends on the domain. This signal is about code units only: documentation is judged by structure and navigability (a well-organized long doc is fine), and data / generated files (JSON data, fixtures, snapshots, lockfiles) carry no line-count concern.

### Working in existing codebases

- You MUST explore the current structure before proposing changes, and you MUST follow existing patterns.
- If the host project carries a domain glossary (e.g. a `CONTEXT.md`) or architecture decision records, you MUST read them and use their canonical vocabulary in the design; if the design contradicts a recorded decision, you MUST flag the contradiction explicitly rather than silently overriding it. When these files are absent, proceed silently — you MUST NOT nag the user to create them (the `domain-modeling` skill governs building them).
- Where existing code has problems that directly affect the work (a file that has grown too large, unclear boundaries, tangled responsibilities), you SHOULD include targeted improvements as part of the design — the scope of such improvements is a judgment call about what serves the current goal.
- You MUST NOT propose unrelated refactoring. You MUST stay focused on what serves the current goal.

## After the Design

### Documentation

- The spec is a **durable design document**. You MUST resolve where it goes in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps design documents, when that is unambiguous; (4) the fallback `docs/design/YYYY-MM-DD-<topic>.md`. Resolving to 3 or 4 MUST be confirmed with the user before the project's first spec is written; resolving to 1 or 2 MUST NOT ask. You MUST create any missing parent directories.
- The spec SHOULD follow the structure in `@spec-template.md` (read it when writing the spec); its **Out of Scope** section is REQUIRED — explicit exclusions are what prevent gold-plating.
- A spec is a durable artifact: it MUST NOT embed file paths, line numbers, or code — those go stale while the spec sits, and the implementation plan carries them. A prototype-derived snippet MAY be embedded ONLY when the snippet itself is the recorded decision.
- You MUST place the design document under version control, following the host's declared `vcs` convention where it has one and an ordinary commit otherwise. If the host declares a `write-authority` model, you MUST obtain authorization through it before writing — the user's approval of the design is not by itself authority to write where the host does not permit.

### Spec self-review

After writing the spec, you MUST review it with fresh eyes and fix any issues inline:

1. **Placeholder scan** — any "TBD", "TODO", incomplete section, or vague requirement MUST be resolved.
2. **Internal consistency** — sections MUST NOT contradict each other; the architecture MUST match the feature descriptions.
3. **Scope check** — the spec MUST be focused enough for a single implementation cycle; if not, it MUST be decomposed.
4. **Ambiguity check** — any requirement open to two interpretations MUST be narrowed to one explicit meaning.

Fix issues inline. You need not re-review after fixing — fix and move on.

### User review gate

After the self-review passes, you MUST ask the user to review the written spec before proceeding, for example:

> "Spec written and committed to `<path>`. Please review it and let me know if you want any changes before we start implementation."

You MUST wait for the user's response. If they request changes, you MUST make them and re-run the spec self-review. You MUST proceed only once the user approves.

### Transition to implementation

- Only after the user approves the written spec MAY you begin implementation.
- If the host project provides a planning or implementation-planning skill, you SHOULD invoke it next to turn the approved spec into an implementation plan; the choice depends on what the host offers.

## Key Principles

- **One question at a time** — never overwhelm with multiple questions in one message.
- **Research before asking** — answer from the project itself whenever you can; ask the user only what you cannot determine.
- **Best practice is domain-specific and current** — anchor designs in the norms of the industry this project serves, researched afresh when the problem is complex or the domain emerging.
- **Concrete options over open-ended** — present enumerable choices rather than open prompts wherever the space allows.
- **YAGNI ruthlessly** — remove unnecessary features from every design.
- **Explore alternatives** — always propose 2-3 approaches before settling.
- **Incremental validation** — present the design in sections and get approval before moving on.
- **Keep the spec current** — update the agreed design as understanding sharpens; the spec MUST reflect the conversation.
- **Be flexible** — go back and clarify when something does not make sense.

## Red Flags — STOP

If any of these is true, you MUST stop and return to the gate:

| Red flag | Required action |
| --- | --- |
| You are about to write code, scaffold, or edit production files and the user has not approved a design | STOP. Present a design first. |
| You skipped exploring the project because the task "looks trivial" | STOP. Explore context, then proceed through the checklist. |
| You bundled several questions into one message | STOP. Ask one question at a time. |
| You asked the user something the codebase already answers | STOP. Research it yourself first. |
| You asked an open-ended question when concrete options exist | STOP. Offer enumerable options instead. |
| You started implementation before the user reviewed the written spec | STOP. Revert and complete the user review gate. |
| The request spans multiple independent subsystems and you began refining details | STOP. Decompose first, then brainstorm the first sub-project. |
| You settled a design for a complex or emerging-domain problem purely from memory, without researching current practice | STOP. Research current authoritative practice first, or explicitly flag that the design rests on built-in knowledge. |

## Rationalizations — all REJECTED

| Rationalization | Reality |
| --- | --- |
| "This is too simple to need a design." | Simple tasks are where skipped assumptions waste the most work. A short design is required; skipping is not allowed. |
| "The user clearly knows what they want, so I'll just build it." | Presenting a short design and getting approval costs little and catches the mismatch before code exists. The gate still applies. |
| "I'll design as I implement; it's faster." | Designing after starting locks in unexamined assumptions. The design MUST come first. |
| "I already started, so finishing is fine." | Premature implementation MUST be reverted, not continued. Return to the gate. |
| "Asking the user is quicker than reading the code." | You MUST research before asking. Reading the project is the job. |
| "Open-ended questions give richer answers." | Concrete options are easier to answer and converge faster. Use them wherever the space is enumerable. |
| "I'll write the spec after I review the user's approval verbally." | The spec MUST be written, committed, and user-reviewed before implementation. Verbal approval of a design does not replace the written-spec review gate. |
| "I already know the best practice here." | For complex or emerging domains, built-in knowledge lags the field. Research current practice; recall alone is not grounding. |
