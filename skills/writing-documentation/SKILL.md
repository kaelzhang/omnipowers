---
name: writing-documentation
description: Use when creating or changing durable documentation — "write a README", "document this module", "reorganize the docs", "our docs are a mess", "nobody can find the right doc" — or when adding, removing, splitting, or renaming any long-lived Markdown (README, architecture doc, contributor/agent entrypoint, a docs tree) — you MUST give the set one entrypoint that routes a reader by task to the exact files they need, update that entrypoint in the same change, and keep one source per rule
---

# Writing Documentation

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Documentation fails on architecture long before it fails on prose. A correct rule in a file nobody is routed to has the same effect as no rule at all, and a set with no door forces every reader to load everything or guess.

**Core principle:** A documentation set is a routing structure, not a pile of files. One door; from that door, the shortest path to the exact files this task needs — and nothing else.

## When to Use

Apply this skill to **long-lived documentation**: `README.md` files, architecture and engineering documents, service / product / operations docs, contributor and agent entrypoints, and any Markdown a future reader is expected to load in order to do work correctly.

It does NOT apply to transient text: scratch plans, task notes, chat, commit messages, PR descriptions, review comments. Those SHOULD be clear and SHOULD link to the authoritative document when they depend on one, but they carry no entrypoint obligation.

**Not this skill:**
- Authoring a skill (a `SKILL.md` and its supporting files) → the `writing-skills` skill governs.
- Compacting this session for the next agent → the `writing-handoffs` skill governs; a handoff is in-flight state, not durable documentation.
- Writing an implementation plan → the `writing-plans` skill governs; a plan dies with the work.
- Producing a research findings file → the `researching` skill governs what it contains and how claims are cited; this skill applies only if that file joins a durable set.
- Deciding what a domain term means, or whether a decision deserves a record → the `domain-modeling` skill governs. This skill shapes how the glossary and the records are **reached and written**, never what they say.

## The Iron Law

```
EVERY DOCUMENT IS REACHED FROM ITS SET'S ENTRYPOINT — NEVER BY SCANNING
```

You MUST NOT write documentation that requires a reader to open every Markdown file in a directory to discover which one applies. A reader who must scan either loads the whole set (burning the context the work needed) or picks by filename and misses the rule that governed. Both failures are silent.

## The Entrypoint Contract

Every documentation set MUST have exactly **one** entrypoint, and that entrypoint MUST answer all four questions below. A set missing any answer is a set the reader scans.

1. **What the set is responsible for** — one line, in terms of the work it governs.
2. **How files are selected** — either the reader picks by task signal, or the whole set is required. State which; a reader who cannot tell which case they are in loads defensively.
3. **Exactly which files to read** — by exact path, spelled out. "See the files in this directory" is not an answer.
4. **What to skip by default** — for task-selected sets, the neighbouring files a reader leaves unloaded unless the task expands into them. Without this, the routing buys nothing.

Two shapes satisfy the contract. The section names below are illustrative — use the host project's own heading conventions where it has them; what MUST be present is the content, not these words.

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

Where both are genuinely true — some documents bind every reader, others are task-selected — state both and mark which documents are unconditional.

You MUST NOT leave two live entrypoints for one set: a reader who finds the wrong door reads a stale routing table and never learns there was another.

## The Resolver Table

The routing judgment — *which task means which document* — is prose, resolved semantically by whoever reads it, a person or a model. You MUST NOT make a generated index, manifest, machine-readable data file, or script the routing mechanism: nothing generates that judgment, a generated list of filenames routes nobody, and once both exist they disagree and the reader has two answers. Such artifacts MAY exist for other purposes (site navigation, link checking); they MUST NOT be what the entrypoint sends the reader to.

Requirements for the table:

- Signals MUST be natural-language conditions describing what the reader is **about to do** ("about to change how the service authenticates a request"), not restated document titles. A signal that only names the file leaves the reader matching against a directory listing, which is the scanning failure again.
- Paths MUST be exact and MUST resolve from the entrypoint's own directory.
- Every document in the set MUST appear in at least one row — in `Read` or in `Skip unless the task expands`. A document no row reaches is unroutable; it will be maintained and never read.
- Each signal SHOULD resolve to a small load set; how small is a judgment about how coarse the set's documents are. A signal that pulls in most of the set MUST be split into narrower signals — it restores the scanning failure at a higher token cost.
- The entrypoint MUST state what to do when no signal matches: read the single smallest plausible document, or ask. Silence here defaults the reader to reading everything.

Reading the whole set is legitimate for a set-wide audit, restructure, or migration; that is a property of those tasks, not a fallback for ordinary ones.

## Path Resolution

Relative paths MUST resolve from the directory containing the document that carries them. When a path is written against any other base — a repository root, a workspace root, the reader's shell working directory — that base MUST be stated immediately next to the path. A path that silently assumes another base resolves to nothing; the reader concludes the document is missing and proceeds without the rule it carried.

Placeholder patterns (`<service>/config.toml`, `{id}/notes.md`) MAY describe a convention. A reference to an actual file MUST be a real path valid from the current document.

## Signal Density

Long-lived documentation is loaded by every future reader of that area, so every line is a recurring cost. You SHOULD use the shortest prose that preserves the normative meaning, omit rationale ("the goal is…", "this exists because…") unless it changes how the rule is applied, and omit examples that do not disambiguate. How much explanation a rule needs varies with how counterintuitive it is — that calibration is yours.

One requirement is not a matter of calibration: **each rule MUST have exactly one source.** Where the same rule is stated normatively in two documents, keep one and make the other a cross-reference, subject to the limit below. Two normative copies drift, and the reader who finds the stale one has no way to know it is stale.

## The Limit of the No-Restatement Rule

Deduplication is only safe **between documents that are read together**. A document designed to be loaded **alone** — without its neighbours — MUST carry everything needed to apply it correctly, even where a neighbour says the same thing. Replacing that content with a cross-reference hands the reader a pointer into a document they will not open, and they apply half a rule while believing they applied all of it.

So before removing any restatement you MUST determine whether the two documents are ever loaded together. If either is loaded alone, the restatement stays, and the entrypoint MUST name which copy is authoritative so the next change knows what it must keep in sync.

## Same-Change Obligations

- Adding, removing, splitting, renaming, or re-scoping a document MUST update that set's entrypoint **in the same change**. An entrypoint that lies mis-routes worse than no entrypoint: a dead path reads as "this rule was deleted", and an unlisted new document is invisible from the day it lands. A later change does not fix this, because it usually never comes.
- Every documentation change MUST scan the changed document's neighbours in the same set for redundancy the change **introduced or exposed**, and resolve it in the same change, subject to the limit above.
- Where the host project declares a commit, staging, or message convention, that convention governs how the change ships; this skill only requires that the entrypoint update ship *with* it.

**The only exception.** You MAY land a document change without the entrypoint update ONLY when the entrypoint lies outside your write authority in this project. Then you MUST, before treating the change as done: (1) state the entrypoint's exact path and the exact row or line it now needs; (2) obtain the user's explicit direction on how it gets updated; (3) leave that request in your reply, not only in your reasoning. "I'll do it next time" and "the owner will notice" are not this exception.

When the set you are about to change has no entrypoint, has more than one, or has an entrypoint that no longer matches what is on disk, read `@repairing-a-doc-set.md` and apply it before making your change.

## Findings Outside Your Remit

When the redundancy, dead path, or structural defect you find lives outside what you were asked to change — another area's documentation, a document another team owns, a file the user did not put in scope — you MUST surface it to the user by exact path and exact overlap, and you MUST NOT restructure it silently. Silent cross-area edits overwrite decisions their owner made deliberately, and the owner learns their document moved only when it breaks something.

Surfacing means naming the file and what is wrong with it, in your reply. A finding you keep in your head is a finding that dies with the session.

## Where Documentation Lives

- A document describing an existing directory, package, or module SHOULD live in that directory — that is where the reader is already standing. A host project that deliberately centralizes its documentation overrides this; follow what it already does rather than opening a second home for the same material.
- A new durable documentation set with no obvious home is a **design-docs** artifact. Resolve its location in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host project's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps durable documentation, when that is unambiguous; (4) the fallback `docs/`. Resolving to 3 or 4 MUST be confirmed with the user before the first write; resolving to 1 or 2 MUST NOT ask — the host has already answered.
- The entrypoint's **filename** is the host's convention, not this skill's. Use the file the host's readers already open — commonly `README.md` for a directory, and the host's own contributor/agent entrypoint file for agent-facing sets. You MUST NOT introduce a second entrypoint filename alongside one the host already uses, for the same reason you MUST NOT leave two live entrypoints.
- Documentation that is the host's own **standards** — its review checklists, coding rules, the criteria it holds work to — is maintained by the host. You MUST NOT restructure it on your own initiative; apply this skill there only on the user's explicit direction.
- Where the host declares a write-authority model, you MUST obtain authorization through it rather than writing into space it governs.

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

| Excuse | Reality |
|---|---|
| "It's obvious which file to read" | Obvious to you, holding the whole set in context. The next reader holds a directory listing and a task. |
| "I'll update the README in a follow-up" | The entrypoint lies until then, and the follow-up rarely happens. Same change, or the change is not done. |
| "A generated index stays in sync automatically" | Nothing generates the task-to-document judgment. A generated list of filenames routes nobody, and now two structures disagree. |
| "One more row won't hurt the load set" | Load sets grow one row at a time until a reader opens eight documents and skims all of them. Split the signal. |
| "Repeating the rule keeps this document self-contained" | Only if it is genuinely read alone. Check first — read together, one copy goes stale and someone follows the stale one. |
| "Cross-referencing is always tighter" | Not when the reader never loads the target. A pointer into an unloaded document is a deleted rule. |
| "I'll mention the overlap in my summary" | The overlap lives in a file; your summary evaporates at the end of the session. Name the path. |
| "This directory only has three files" | Sets grow. The entrypoint is cheap at three documents and a project to retrofit at thirty. |
| "I'll restructure the neighbouring area while I'm in here" | Its owner made those choices deliberately. Surface the finding; do not silently overwrite it. |
| "I can't edit their entrypoint, so I'll just ship mine" | That is the exception's trigger, not a waiver. State the path and the exact row it needs, and get direction. |

## Before the Change Is Done

- [ ] The set has one entrypoint, and it answers all four contract questions
- [ ] Every document in the set is reachable from that entrypoint by an exact path
- [ ] Task signals describe what the reader is doing, and no signal pulls in most of the set
- [ ] Every path resolves from the document that contains it, or states its base
- [ ] No rule is stated normatively twice without one copy named authoritative and a standalone-load reason
- [ ] Neighbours scanned for redundancy this change introduced or exposed
- [ ] Findings outside your remit surfaced to the user by exact path

## The Bottom Line

```
Document added or moved → its entrypoint updated in the same change
Reader has a task       → the entrypoint names the exact files, and what to skip
Rule stated twice       → one source, unless the other is read alone
```
