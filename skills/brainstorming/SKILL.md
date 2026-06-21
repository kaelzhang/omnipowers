---
name: brainstorming
description: "Use when about to do any creative or implementation work — creating a feature, building a component, adding functionality, modifying behavior, or scaffolding a project — you MUST first explore intent, requirements, and design and get the design approved before writing any code."
---

# Brainstorming Ideas Into Designs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

This skill is a pre-implementation gate. Before any creative or implementation work, you MUST turn the idea into an explored, agreed design through collaborative dialogue, then get the user's approval. You MUST start by understanding the current project context, ask questions one at a time to refine the idea, prefer researching over asking, offer concrete options over open-ended prompts, and keep the agreed spec updated as understanding sharpens.

## Iron Law

YOU MUST NOT WRITE CODE, SCAFFOLD A PROJECT, INVOKE ANY IMPLEMENTATION SKILL, OR TAKE ANY IMPLEMENTATION ACTION UNTIL YOU HAVE PRESENTED A DESIGN AND THE USER HAS APPROVED IT.

This applies to EVERY task regardless of perceived simplicity. A todo list, a single-function utility, a one-line config change — all of them pass through this gate. If you catch yourself starting implementation before approval, you MUST stop, revert any premature action, and return to this process.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every task goes through this process. "Simple" tasks are exactly where unexamined assumptions cause the most wasted work, because the gate gets skipped and the wrong thing gets built fast. The design MAY be short — a few sentences for a genuinely simple task — but you MUST present it and get approval. Brevity is permitted; skipping is not.

## Checklist

You MUST complete these items in order. You MUST NOT skip an item because the task "looks small".

1. **Explore project context** — read the relevant files, docs, and recent commits before asking anything.
2. **Assess scope** — if the request spans multiple independent subsystems, flag it and decompose before refining details.
3. **Ask clarifying questions** — one at a time; understand purpose, constraints, and success criteria.
4. **Propose 2-3 approaches** — with trade-offs and your recommendation, leading with the recommended option.
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
- You MUST offer concrete options over open-ended prompts. When the decision space is enumerable, present multiple-choice or A/B/C options rather than asking "what do you want?". Open-ended questions are acceptable only when the space genuinely cannot be enumerated.
- Each question MUST focus on understanding purpose, constraints, or success criteria.

### Exploring approaches

- You MUST propose 2-3 distinct approaches with their trade-offs before settling on a design.
- You MUST lead with your recommended option and explain why, then present the alternatives and their trade-offs conversationally.

### Presenting the design

- Once you believe you understand what is being built, you MUST present the design.
- You MUST scale each section to its complexity: a few sentences if straightforward, up to a few hundred words if nuanced.
- You MUST ask, after each section, whether it looks right so far, and you MUST get approval before moving on (incremental validation).
- The design MUST cover, as applicable: architecture, components, data flow, error handling, and testing.
- You MUST be ready to go back and clarify when something does not make sense, and you MUST update the agreed design as understanding sharpens rather than letting the spec drift from the conversation.

### Design for isolation and clarity

- You MUST break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently.
- For each unit you MUST be able to answer: what does it do, how is it used, and what does it depend on?
- If someone cannot understand what a unit does without reading its internals, or you cannot change the internals without breaking consumers, the boundaries need work and you MUST refine them.
- Smaller, well-bounded units are easier to work with and edit reliably. When a file grows large, that is a signal it is doing too much, and the design SHOULD split it — judgment applies because the right boundary depends on the domain.

### Working in existing codebases

- You MUST explore the current structure before proposing changes, and you MUST follow existing patterns.
- Where existing code has problems that directly affect the work (a file that has grown too large, unclear boundaries, tangled responsibilities), you SHOULD include targeted improvements as part of the design — the scope of such improvements is a judgment call about what serves the current goal.
- You MUST NOT propose unrelated refactoring. You MUST stay focused on what serves the current goal.

## After the Design

### Documentation

- You MUST write the validated design (the spec) to a dated design file under the project's docs directory, using a path of the form `docs/specs/YYYY-MM-DD-<topic>-design.md`. If the user has stated a preference for spec location, that preference overrides this default.
- You MUST commit the design document to version control.

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
