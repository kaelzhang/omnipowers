---
name: researching
description: Use when asked to research, investigate, or look something up — how X works, which library to pick, the current state of Y, docs or API facts to gather — you MUST trace every claim to the primary source that owns it and deliver the findings as a cited Markdown file
---

# Researching

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Research is done when the question asked has an answer in which every claim is traced to the source that owns it, captured in a Markdown artifact the user can audit claim by claim. Anything less is opinion with formatting.

**Core principle:** A claim you cannot trace to its owning source is not a finding — it is a guess, and presenting it as a finding poisons every decision built on it.

## When to Use

You MUST apply this skill whenever the task is to answer a question by investigation rather than by building: "research X", "investigate Y", "look up Z", "find out how X works", "which library should we use", "what's the current state of Y". It applies whether the sources are on the web, in installed packages, or in a local codebase.

## The Iron Law

```
EVERY CLAIM TRACES TO THE PRIMARY SOURCE THAT OWNS IT
```

- You MUST follow every claim back to the source that **owns** it: official documentation, the spec or standard, the source code itself, the project's changelog or release notes, or a benchmark/experiment you ran and recorded.
- You MUST NOT cite a paraphrase — a blog post, Stack Overflow answer, tutorial, or AI summary — as the authority for a claim when the owning source is reachable. A paraphrase can be wrong, stale, or about a different version, and citing it launders that risk into your findings.
- Secondary sources MAY point the way: use them to discover *where* the owning source is, then verify the claim there. The citation on the claim is always the owner.

## Workflow

1. **Pin the question.** Restate exactly what is being asked, including version/date constraints. This is the scope; everything else is a lead.
2. **Identify the owning sources.** For each sub-question, name where the authoritative answer lives (docs, spec, repo, changelog) before reading anything else.
3. **Verify claim by claim.** For each candidate claim, read the owning source and record the citation at the moment of verification — link plus version/date, or `file:line` for code, or the exact command for a benchmark you ran.
4. **Write the artifact.** Produce the findings file per the output contract below. Findings first, evidence attached to each, conflicts and gaps stated plainly.

## Output Contract

- Findings MUST land in a single Markdown file. Research that settles a decision is a **durable design document**; you MUST resolve its location in this order, stopping at the first that applies: (1) a location or format the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps design documents, when that is unambiguous; (4) the fallback `docs/research/YYYY-MM-DD-<topic>.md`. Resolving to 3 or 4 MUST be confirmed with the user before the first such file is written; resolving to 1 or 2 MUST NOT ask. If the host declares a `write-authority` model, you MUST obtain authorization through it before writing.
- Every claim in the file MUST carry its citation inline: a link (with the version or retrieval date when the source is versioned or volatile), a `file:line` reference for source code, or the command and environment for a measurement you ran.
- A claim without a citation is an unverifiable assertion. It MUST NOT be presented as a finding — either verify it, move it to the leads section explicitly marked unverified, or drop it.
- The file MUST answer the pinned question directly, near the top, before the supporting detail.

## Conflicting Sources

When sources disagree, you MUST report the conflict honestly: what each source says, with each source's version and date. You MUST NOT silently resolve the conflict by presenting one side as the answer. You SHOULD state which source is more likely authoritative and why (newer version, closer to the implementation), but the disagreement itself stays visible.

## When You Cannot Reach the Sources

When the environment has no web access, or the owning source is otherwise unreachable, verification is impossible — say so. The findings file MUST state prominently that it rests on built-in knowledge as of your training data, and each such claim MUST be flagged as unverified. You MUST NOT present recall as verified research; recall dressed up with confident prose is the most dangerous output this skill exists to prevent.

## Scope Discipline

You MUST answer the question asked — that question, at that scope. Adjacent discoveries made along the way (a related bug, a better library for a different problem, an interesting design) go into a short **Leads** section at the end of the findings file, one line each. You MUST NOT expand the investigation to chase a lead without the user asking for it.

## Rationalizations — STOP

| Excuse | Reality |
|--------|---------|
| "The blog post explains it better than the docs" | Then let it point you to the docs and cite those. The blog may describe an old version; the owner is the authority. |
| "I already know the answer" | Knowledge without a source is a hypothesis. Verify it against the owner, or flag it as unverified recall. |
| "This adjacent topic is clearly relevant" | Park it in Leads. Scope is the question asked, not the question you found interesting. |
| "I'll add the citations at the end" | Citations reconstructed after the fact are guesses about where you read something. Record each one at the moment of verification. |

## Red Flags — STOP and Re-verify

| Red flag | What it means |
|---|---|
| A claim cites a blog/SO/AI summary while the official docs are reachable | The Iron Law is being violated — trace the claim to the owner. |
| Findings written without opening a single source | You are presenting recall as research — verify or flag every claim. |
| The findings file answers three questions when one was asked | Scope has ballooned — cut back to the question; move the rest to Leads. |

## The Bottom Line

```
Finding → claim + citation to the source that owns it
No citation → not a finding; flag it or drop it
```
