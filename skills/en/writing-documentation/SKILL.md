---
name: writing-documentation
description: Use when creating or changing durable documentation — "write a README", "document this module", "reorganize the docs", "our docs are a mess", "nobody can find the right doc" — or when adding, removing, splitting, or renaming any long-lived Markdown (README, architecture doc, contributor/agent entrypoint, a docs tree) — you MUST keep the set reachable from one entrypoint.
---

# Writing Documentation

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Scope

Long-lived documentation — `README.md` files, architecture and engineering documents, service / product / operations docs, contributor and agent entrypoints, and Markdown a future reader is expected to load to do work correctly.

Transient text — scratch plans, task notes, chat, commit messages, PR descriptions, and review comments; outside this skill's scope apart from the clarity and authoritative-link recommendations below.

- Writing transient text → it SHOULD be clear.
- Transient text depends on an authoritative document → it SHOULD link to that document.

### Other Skill Boundaries

- `writing-skills` — the governing skill for authoring a skill (`SKILL.md` and its supporting files).
- `writing-handoffs` — the governing skill for compacting this session for the next agent.
- `writing-plans` — the governing skill for writing an implementation plan.
- `researching` — the governing skill for a research findings file's contents and claim citations; this skill's scope includes such a file only when it joins a durable set.
- `domain-modeling` — the governing skill for domain term meanings and decisions deserving records; this skill's scope covers how the glossary and records are reached and written.

## The Iron Law

```
EVERY DOCUMENT IS REACHED FROM ITS SET'S ENTRYPOINT — NEVER BY SCANNING
```

- Writing documentation → you MUST NOT require a reader to open every Markdown file in a directory to discover which one applies.

## The Entrypoint Contract

- For every documentation set → the set MUST have exactly **one** entrypoint.
- For every documentation set → its entrypoint MUST answer all four questions:
  1. **What the set is responsible for** — one line, in terms of the work it governs.
  2. **How files are selected** — the reader picks by task signal, or the whole set is required; state which.
  3. **Exactly which files to read** — by exact path, spelled out.
  4. **What to skip by default** — for task-selected sets, the neighbouring files a reader leaves unloaded unless the task expands into them.
- Using either entrypoint template → the contract content MUST be present.

### Shape A — task-signal resolver

```markdown
# <Area>

<One line: the work this set governs.>

## Loading Map

| Task signal | Read | Skip unless the task expands |
| --- | --- | --- |
| <a condition matched against the reader's actual task> | `<exact-file.md>` | `<neighbouring files left unloaded>` |
```

### Shape B — required reading

```markdown
# <Area>

<One line: the work this set governs.>

## Required Reading

Read every document in this set before starting:

- `<exact-file.md>` — <what it governs>
```

- For one documentation set → you MUST NOT leave two live entrypoints.

## The Resolver Table

- Choosing a routing mechanism → you MUST NOT make a generated index, manifest, machine-readable data file, or script the routing mechanism.
- For purposes other than routing → such artifacts MAY exist.
- Writing an entrypoint → those artifacts MUST NOT be what the entrypoint sends the reader to.
- Writing signals → signals MUST be natural-language conditions describing what the reader is **about to do**, not restated document titles.
- Writing resolver paths → paths MUST be exact and MUST resolve from the entrypoint's own directory.
- For every document in the set → the document MUST appear in at least one row, in `Read` or in `Skip unless the task expands`.
- Writing a signal → the signal SHOULD resolve to a small load set.
- A signal pulls in most of the set → the signal MUST be split into narrower signals.
- Writing the entrypoint → the entrypoint MUST state what to do when no signal matches: read the single smallest plausible document, or ask.

## Path Resolution

- Writing relative paths → paths MUST resolve from the directory containing the document that carries them.
- A path is written against another base (repository root, workspace root, or the reader's shell working directory) → that base MUST be stated immediately next to the path.
- Describing a convention → placeholder patterns MAY describe it.
- Referencing an actual file → the reference MUST be a real path valid from the current document.

## Signal Density

- Writing documentation → you SHOULD use the shortest prose that preserves the normative meaning, omit rationale unless it changes how the rule is applied, and omit examples that do not disambiguate.
- For each rule → the rule MUST have exactly one source, subject to the standalone-document limit below.

## The Limit of the No-Restatement Rule

- A document is designed to be loaded **alone** → it MUST carry everything needed to apply it correctly, even where a neighbour says the same thing.
- Before removing any restatement → you MUST determine whether the two documents are ever loaded together.
- Either document is loaded alone → the entrypoint MUST name which copy is authoritative.

## Same-Change Obligations

- Adding, removing, splitting, renaming, or re-scoping a document → the change MUST update that set's entrypoint **in the same change**.
- Making a documentation change → the change MUST include scanning the changed document's neighbours in the same set for redundancy the change **introduced or exposed**, and resolving it in the same change, subject to the standalone-document limit above.
- The entrypoint lies outside your write authority in this project → you MAY land a document change without the entrypoint update ONLY under this condition.
- Using this exception, before treating the change as done → you MUST:
  1. State the entrypoint's exact path and the exact row or line it now needs.
  2. Obtain the user's explicit direction on how it gets updated.
  3. Leave that request in your reply, not only in your reasoning.

## Red Flag — Repair Required

- The set you are about to change has no entrypoint, has more than one, or has an entrypoint that no longer matches what is on disk → read `@repairing-a-doc-set.md` and apply it before making your change.

## Findings Outside Your Remit

- A redundancy, dead path, or structural defect you find lives outside what you were asked to change → you MUST surface it to the user by exact path and exact overlap, naming the file and what is wrong with it in your reply.
- A redundancy, dead path, or structural defect you find lives outside what you were asked to change → you MUST NOT restructure it silently.

## Where Documentation Lives

- A document describes an existing directory, package, or module, and the host project does not deliberately centralize its documentation → the document SHOULD live in that directory.
- `design-docs` — the artifact role of a new durable documentation set with no obvious home; location resolution per `using-omnipowers`, fallback `docs/`.
- The host already uses an entrypoint filename → you MUST NOT introduce a second entrypoint filename alongside it.
- Documentation is the host's own **standards** (review checklists, coding rules, or criteria it holds work to) → you MUST NOT restructure it on your own initiative.
