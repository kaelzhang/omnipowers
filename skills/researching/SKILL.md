---
name: researching
description: Use when asked to research, investigate, or look something up — how X works, which library to pick, the current state of Y, docs or API facts to gather, current authoritative practice ("调研", "权威实践") — you MUST trace every claim to the primary source that owns it and deliver the findings as a cited Markdown file
---

# Researching

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## When to Use

The task is to answer a question by investigation rather than by building → you MUST apply this skill, whether the sources are on the web, in installed packages, or in a local codebase.

## The Iron Law

```
EVERY CLAIM TRACES TO THE PRIMARY SOURCE THAT OWNS IT
```

- When researching → you MUST follow every claim back to the source that **owns** it: official documentation, the spec or standard, the source code itself, the project's changelog or release notes, or a benchmark/experiment you ran and recorded.
- The owning source is reachable → you MUST NOT cite a paraphrase — a blog post, Stack Overflow answer, tutorial, or AI summary — as the authority for a claim.
- When locating an owning source → secondary sources MAY point the way: use them to discover *where* the owning source is, then verify the claim there and cite the owner.

## Output Contract

Pinned question — exactly what is being asked, including version/date constraints.

- When delivering research findings → findings MUST land in a single Markdown file.
- Research that settles a decision — a `design-docs` artifact with fallback `docs/research/YYYY-MM-DD-<topic>.md` under the location resolution of `using-omnipowers`.
- A claim is in the findings file → it MUST carry its citation inline: a link (with the version or retrieval date when the source is versioned or volatile), a `file:line` reference for source code, or the command and environment for a measurement you ran.
- A claim has no citation → it MUST NOT be presented as a finding; either verify it, move it to the leads section explicitly marked unverified, or drop it.
- When delivering the findings file → the file MUST answer the pinned question directly, near the top, before the supporting detail.

## Conflicting Sources

- Sources disagree → you MUST report the conflict honestly: what each source says, with each source's version and date.
- Sources disagree → you MUST NOT silently resolve the conflict by presenting one side as the answer.
- Sources disagree → you SHOULD state which source is more likely authoritative and why (newer version, closer to the implementation).

## When You Cannot Reach the Sources

- The environment has no web access, or the owning source is otherwise unreachable → the findings file MUST state prominently that it rests on built-in knowledge as of your training data.
- The environment has no web access, or the owning source is otherwise unreachable → each such claim MUST be flagged as unverified.
- When researching → you MUST NOT present recall as verified research.

## Scope Discipline

- When researching → you MUST answer the question asked — that question, at that scope.
- The user has not asked to investigate a lead → you MUST NOT expand the investigation to chase it.

## Rationalizations — STOP

| Excuse | Command |
|--------|---------|
| "The blog post explains it better than the docs" | Let it point you to the docs and cite those. |
| "I already know the answer" | Verify it against the owner, or flag it as unverified recall. |
| "This adjacent topic is clearly relevant" | Park it in Leads. |
| "I'll add the citations at the end" | Record each citation at the moment of verification. |

## Red Flags — STOP and Re-verify

| Red flag | Command |
|---|---|
| A claim cites a blog/SO/AI summary while the official docs are reachable | Trace the claim to the owner. |
| Findings written without opening a single source | Verify or flag every claim. |
| The findings file answers three questions when one was asked | Cut back to the question; move the rest to Leads. |
