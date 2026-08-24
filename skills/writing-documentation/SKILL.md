---
name: writing-documentation
description: Use when creating or changing durable documentation — "write a README", "document this module", "reorganize the docs", "our docs are a mess", "nobody can find the right doc" — or when adding, removing, splitting, or renaming any long-lived Markdown (README, architecture doc, contributor/agent entrypoint, a docs tree) — you MUST give the set one entrypoint that routes a reader by task to the exact files they need, update that entrypoint in the same change, and keep one source per rule
---

# Writing Documentation

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Scope

- Long-lived documentation — `README.md` files, architecture and engineering documents, service / product / operations docs, contributor and agent entrypoints, and any Markdown a future reader is expected to load in order to do work correctly → apply this skill.
- Transient text — scratch plans, task notes, chat, commit messages, PR descriptions, review comments → this skill does not apply; that text SHOULD be clear and SHOULD link to the authoritative document when it depends on one, and carries no entrypoint obligation.

**Not this skill:**

- Authoring a skill (a `SKILL.md` and its supporting files) → the `writing-skills` skill governs.
- Compacting this session for the next agent → the `writing-handoffs` skill governs.
- Writing an implementation plan → the `writing-plans` skill governs.
- Producing a research findings file → the `researching` skill governs what it contains and how claims are cited; this skill applies only if that file joins a durable set.
- Deciding what a domain term means, or whether a decision deserves a record → the `domain-modeling` skill governs. This skill shapes how the glossary and the records are **reached and written**, never what they say.

## The Iron Law

```
EVERY DOCUMENT IS REACHED FROM ITS SET'S ENTRYPOINT — NEVER BY SCANNING
```

You MUST NOT write documentation that requires a reader to open every Markdown file in a directory to discover which one applies.

## The Entrypoint Contract

Every documentation set MUST have exactly **one** entrypoint, and that entrypoint MUST answer all four questions:

1. **What the set is responsible for** — one line, in terms of the work it governs.
2. **How files are selected** — the reader picks by task signal, or the whole set is required; state which.
3. **Exactly which files to read** — by exact path, spelled out. "See the files in this directory" is not an answer.
4. **What to skip by default** — for task-selected sets, the neighbouring files a reader leaves unloaded unless the task expands into them.

Two shapes satisfy the contract. Heading names in the templates below are not fixed → use the host project's own heading conventions where it has them; what MUST be present is the content.

**Shape A — task-signal resolver** (readers choose):

```markdown
# <Area>

<One line: the work this set governs.>

## Loading Map

| Task signal | Read | Skip unless the task expands |
| --- | --- | --- |
| <a condition matched against the reader's actual task> | `<exact-file.md>` | `<neighbouring files left unloaded>` |
```

**Shape B — required reading** (all mandatory):

```markdown
# <Area>

<One line: the work this set governs.>

## Required Reading

Read every document in this set before starting:

- `<exact-file.md>` — <what it governs>
```

- Some documents bind every reader and others are task-selected → state both shapes and mark which documents are unconditional.
- You MUST NOT leave two live entrypoints for one set.

## The Resolver Table

- You MUST NOT make a generated index, manifest, machine-readable data file, or script the routing mechanism. Such artifacts MAY exist for other purposes; they MUST NOT be what the entrypoint sends the reader to.
- Signals MUST be natural-language conditions describing what the reader is **about to do**, not restated document titles.
- Paths MUST be exact and MUST resolve from the entrypoint's own directory.
- Every document in the set MUST appear in at least one row — in `Read` or in `Skip unless the task expands`.
- Each signal SHOULD resolve to a small load set; how small varies with how coarse the set's documents are.
- A signal that pulls in most of the set MUST be split into narrower signals.
- The entrypoint MUST state what to do when no signal matches: read the single smallest plausible document, or ask.
- The task is a set-wide audit, restructure, or migration → reading the whole set is legitimate; that is a property of those tasks, not a fallback for ordinary ones.

## Path Resolution

- Relative paths MUST resolve from the directory containing the document that carries them.
- A path is written against any other base (repository root, workspace root, the reader's shell working directory) → that base MUST be stated immediately next to the path.
- Placeholder patterns MAY describe a convention. A reference to an actual file MUST be a real path valid from the current document.

## Signal Density

- You SHOULD use the shortest prose that preserves the normative meaning, omit rationale unless it changes how the rule is applied, and omit examples that do not disambiguate. How much explanation a rule needs varies with how counterintuitive it is — that calibration is yours.
- Each rule MUST have exactly one source. The same rule is stated normatively in two documents → keep one and make the other a cross-reference, subject to the limit below.

## The Limit of the No-Restatement Rule

- A document designed to be loaded **alone** MUST carry everything needed to apply it correctly, even where a neighbour says the same thing.
- Before removing any restatement you MUST determine whether the two documents are ever loaded together.
- Either document is loaded alone → the restatement stays, and the entrypoint MUST name which copy is authoritative.

## Same-Change Obligations

- Adding, removing, splitting, renaming, or re-scoping a document MUST update that set's entrypoint **in the same change**.
- Every documentation change MUST scan the changed document's neighbours in the same set for redundancy the change **introduced or exposed**, and resolve it in the same change, subject to the limit above.
- The host project declares a commit, staging, or message convention → that convention governs how the change ships; this skill requires only that the entrypoint update ship *with* it.

**The only exception.** You MAY land a document change without the entrypoint update ONLY when the entrypoint lies outside your write authority in this project. Then you MUST, before treating the change as done: (1) state the entrypoint's exact path and the exact row or line it now needs; (2) obtain the user's explicit direction on how it gets updated; (3) leave that request in your reply, not only in your reasoning. "I'll do it next time" and "the owner will notice" are not this exception.

The set you are about to change has no entrypoint, has more than one, or has an entrypoint that no longer matches what is on disk → read `@repairing-a-doc-set.md` and apply it before making your change.

## Findings Outside Your Remit

The redundancy, dead path, or structural defect you find lives outside what you were asked to change — another area's documentation, a document another team owns, a file the user did not put in scope → you MUST surface it to the user by exact path and exact overlap, naming the file and what is wrong with it in your reply, and you MUST NOT restructure it silently.

## Where Documentation Lives

- A document describing an existing directory, package, or module SHOULD live in that directory. The host project deliberately centralizes its documentation → follow what it already does.
- A new durable documentation set with no obvious home is a **design-docs** artifact. Resolve its location in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host project's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps durable documentation, when that is unambiguous; (4) the fallback `docs/`. Resolving to 3 or 4 MUST be confirmed with the user before the first write; resolving to 1 or 2 MUST NOT ask.
- The entrypoint's **filename** is the host's convention, not this skill's: use the file the host's readers already open — commonly `README.md` for a directory, and the host's own contributor/agent entrypoint file for agent-facing sets. You MUST NOT introduce a second entrypoint filename alongside one the host already uses.
- Documentation that is the host's own **standards** — its review checklists, coding rules, the criteria it holds work to — is maintained by the host. You MUST NOT restructure it on your own initiative; apply this skill there only on the user's explicit direction.
- The host declares a write-authority model → you MUST obtain authorization through it rather than writing into space it governs.

## Red Flags — STOP

- A document added, renamed, or deleted and the entrypoint untouched
- "See the files in this directory", "read the docs under `docs/`", or any instruction to browse
- An entrypoint that lists documents without exact paths
- A generated index, manifest, or script proposed as the routing mechanism
- One task signal that pulls in most of the set
- A document in the set that no row of the table reaches
- A root-relative path inside a nested document, with no base stated
- The same rule stated normatively in two documents, neither marked authoritative
- A rule replaced by a cross-reference in a document that is read alone
- Restructuring a document you were not asked to touch because you noticed overlap in passing
- A second entrypoint filename introduced next to the one the project already uses

## Rationalizations — rejected

| Thought | What to do instead |
|---|---|
| "It's obvious which file to read" | Route by exact path; the next reader holds a directory listing and a task, not the set. |
| "I'll update the README in a follow-up" | Update the entrypoint in this change, or the change is not done. |
| "A generated index stays in sync automatically" | Write the routing judgment as prose; nothing generates it. |
| "One more row won't hurt the load set" | Split the signal. |
| "Repeating the rule keeps this document self-contained" | Determine first whether the two are ever loaded together; read together → keep one copy. |
| "Cross-referencing is always tighter" | Reader never loads the target → the pointer is a deleted rule; keep the copy. |
| "I'll mention the overlap in my summary" | Name the exact path in your reply. |
| "This directory only has three files" | Give the set its entrypoint now. |
| "I'll restructure the neighbouring area while I'm in here" | Surface the finding by exact path; do not restructure it silently. |
| "I can't edit their entrypoint, so I'll just ship mine" | State the path and the exact row it needs, and get direction. |

## Before the Change Is Done

- [ ] The set has one entrypoint, and it answers all four contract questions
- [ ] Every document in the set is reachable from that entrypoint by an exact path
- [ ] Task signals describe what the reader is doing, and no signal pulls in most of the set
- [ ] Every path resolves from the document that contains it, or states its base
- [ ] No rule is stated normatively twice without one copy named authoritative and a standalone-load reason
- [ ] Neighbours scanned for redundancy this change introduced or exposed
- [ ] Findings outside your remit surfaced to the user by exact path
