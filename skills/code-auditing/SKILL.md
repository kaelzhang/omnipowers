---
name: code-auditing
description: Use when reviewing, auditing, or assessing code — a diff, a branch, a commit range, a pull request, a file, a feature, or the whole project — or when finished work is about to advance — before a merge, a pull request, a release, or a handover — you MUST review the real code with evidence, report findings by severity, and act on every Critical and Important one before proceeding; an ordinary commit is not a review trigger
---

# Code Auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

This skill has two modes — **checkpoint review** of finished work before it advances (a branch, a task, a diff), and **standards audit** against the project's own checklist. Phase 1 routes; Phases 2, 3, and 4 apply to both.

**Iron Law: You MUST NOT claim code is reviewed without an independent pass over the actual code with evidence for every finding.**

Everything this skill creates MUST live inside the audited project, in the locations that project declares (fallback: `<project-root>/.omnipowers/`). This skill MUST NOT depend on any tool, service, or repository outside the audited project.

## When to Use

You MUST use this skill when:

- a discrete task in a plan, a major feature, or a complex bug fix is complete;
- work is about to be merged, opened as a pull request, released, handed over, depended on, or taken into a refactor;
- you are asked to audit or assess a codebase, a PR, a diff, or a commit range;
- you are stuck and a fresh perspective would help.

- An ordinary commit on your own branch → not a review trigger.
- Work committed onto a branch you will review as a range → review it then, once, against the whole range.
- A review is warranted → you MUST NOT skip or shallow it because the change "is simple," "is small," or "obviously works." Only the absence of work about to advance lifts the review; size never does.

## Phase 1 — Route: checkpoint review or standards audit

Determine the mode from the target, then follow that branch.

| The target is… | Mode | What governs the checks |
|---|---|---|
| Finished work advancing to the next step (a branch, a plan task, a feature, a PR, a diff before merge or refactor) | **Checkpoint review** | The work's own requirements + the reviewer brief |
| The codebase, a subsystem, or a change being assessed against the project's standard | **Standards audit** | The project checklist (generated on first use) |

Both apply — a finished branch in a project that has a checklist → you MUST run the checkpoint review and use the checklist as an additional lens.

### 1a. Checkpoint review

**Capture the range first.** The reviewed range MUST cover the entire body of work, not just the last commit:

```bash
BASE_SHA=$(git merge-base HEAD <main-branch>)   # feature / pre-merge review
HEAD_SHA=$(git rev-parse HEAD)
```

- Exactly one commit is under review, as a single-task checkpoint → `BASE_SHA=$(git rev-parse HEAD~1)` is permitted; in every other case you MUST NOT use it.
- The work is uncommitted → commit it, or stash it and review the stash. You MUST review a committed range.

**Find the requirements.** You MUST review the work against what it was supposed to do. Discover the requirements source in this order: the design document this work implements, wherever the project keeps them → the task brief the implementer worked from → the plan file → requirement references in the commit messages → ask the user. No source exists → you MUST state explicitly that the review ran without a requirements source (quality-axis only, degraded).

**Run an independent pass.** Checkpoint review → read `@reviewer-brief.md` and apply it.

- **Subagents available:** you MUST dispatch one independent reviewer using that brief with the placeholders filled in; it MUST run read-only.
- **No subagents:** you MUST perform the review yourself as a deliberate, separate pass — treat the diff as if written by someone else, work only from the requirements and the diff (never your memory of writing it), read the entire diff top to bottom before concluding, apply the full brief, and keep the pass read-only (record findings first; act in Phase 4). This fallback MUST NOT be a token gesture.

### 1b. Standards audit

**First, find the criteria.** You MUST resolve where this project's audit criteria come from, stopping at the first that applies:

1. a source the user names in this session;
2. the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `standards` row;
3. a standards set the project already publishes and expects its contributors to follow (a standards directory, a contributor guide, a documented coding standard);
4. none of the above — the project publishes no criteria.

**1, 2, or 3 applies → you MUST audit against that source, and you MUST NOT generate a checklist of your own.** The published source leaves one of the dimensions below uncovered → you MAY audit that dimension against the portable baseline in `@code-smells.md`, and you MUST say so in the report.

**4 applies → generate a checklist, and you MUST generate it before auditing anything:**

1. **Survey the project.** Read enough of it to ground the checklist in THIS codebase: languages, frameworks, architecture and layering, the domain, the security/trust surface, the concurrency model, data and schema, build/release, the test setup, and the project's own conventions (`CLAUDE.md` / `AGENTS.md` / docs / linters).
2. **Draft a multi-dimensional checklist.** It MUST cover at least these dimensions, each specialized to this project: correctness & logic; security & trust boundaries; error handling & failure modes; concurrency, ordering & resource lifecycle; performance & complexity; API / contract / backward compatibility; data, schema & migrations; tests & coverage (incl. a regression test for every fixed bug); readability, naming & maintainability; structure, layering & boundaries; dependencies & supply chain; documentation & comments. A dimension genuinely cannot apply → drop it and state why. Each item MUST be a concrete, checkable question, never a vague "is it good?".
3. **Optimize it by bounded iteration.** Apply at least three distinct improvement lenses — completeness / missing failure modes, project-fit / actionability, redundancy / granularity — each as its own round; run a further round only if the last one still found a real gap. Stop at the first round that produces no material change, and you MUST NOT exceed **5** rounds.
4. **Write it** where the project keeps its criteria — the `standards` location resolved above, falling back to `<project-root>/.omnipowers/rules/CODE_AUDITING.md` when the project has none (`<project-root>` is the repository root, or your working directory if it is not a repo). Give it a short header (project, generated date, dimension list) and group items by dimension.
5. **Get approval before first use.** You MUST present it — with the location you resolved — and obtain approval, incorporating the user's edits, before auditing against it. You SHOULD treat it as a commit-worthy project artifact.

**A generated checklist already exists → you MUST use it as-is for this audit**, and you MUST NOT rewrite it mid-audit; improvements go through Phase 5.

Scope the depth to the target:

- Whole-project audit → check every item against the whole codebase.
- Change audit → consider every item, but focus the deep checks on the changed surface and its blast radius, ordered by risk. You MUST NOT re-audit unrelated code line by line.

## Phase 2 — Rigor (both modes)

For everything you check, you MUST:

- inspect the actual code — read it, do not assume;
- reach a verdict — **pass**, **fail**, **concern**, or **n/a**, with a one-line reason for n/a;
- for every `fail` / `concern`, record a concrete `file:line`, the evidence, a **severity**, and a specific, actionable fix;
- verify each finding against the real code and raise no speculative finding; you cannot verify one → say so and mark it unverified;
- apply YAGNI and context — before flagging "missing X", confirm X is needed; before flagging a pattern, check for a legacy / compatibility / intentional reason;
- skip anything the project's tooling already enforces (linter, formatter, type checker);
- be specific and non-performative — state the issue and the fix, with no praise or filler.

**Report the two axes separately** — spec conformance (missing / unrequested / wrong, each quoting the requirement it violates) and code quality. A finding MUST NOT be re-ranked across axes.

## Phase 3 — Record the audit

Scale the record to the audit:

- A standards audit, a whole-project or subsystem assessment, a pre-release review, or any audit the user asked to have on file → a written file is REQUIRED.
- A checkpoint review of a change about to merge → reporting the findings in your reply is sufficient; the file is OPTIONAL.

Either way, the report MUST contain: the target and scope (including the reviewed range for a checkpoint review), the requirements or checklist reference, every verdict, all findings (each with `file:line` + severity + fix), and the overall assessment.

An audit report is a **record**. You MUST resolve where it goes in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `records` row; (3) where the host already keeps review write-ups, when that is unambiguous; (4) the fallback:

```
<project-root>/.omnipowers/reviews/<YYYY-MM-DD>-<HHMMSS>-<review-target>.md
```

`<review-target>` is a short kebab-case slug of what was reviewed.

- Resolved to 3 or 4 → you MUST confirm the location with the user before the project's first audit is recorded.
- Resolved to 1 or 2 → you MUST NOT ask.
- Parent directories missing → you MUST create them.

## Phase 4 — Report and act

You MUST output a concise summary to the session: the findings grouped by axis and severity, every `Critical` and `Important` finding (location + one-line fix), the overall assessment (ship / fix-first / needs-rework), and the path to the recorded file. Both outputs are REQUIRED — the record on disk AND the session summary.

The target is a pull request and you post findings to it → you SHOULD place each inline finding in its code comment thread rather than as one top-level comment.

Then act on the findings:

- **Critical** → you MUST fix it before proceeding.
- **Important** → you MUST fix it before any further implementation work (the next task, a refactor, or a merge).
- **Minor** → you MUST record it (task notes or an issue tracker) rather than silently dropping it.
- A finding is wrong → you MUST push back with specific technical reasoning citing the code, the tests, or the requirement. You MUST NOT accept an incorrect finding just to close it out, and MUST NOT dismiss one without that reasoning.

## Phase 5 — Evolve the checklist (gated; standards audits)

After an audit that used or created a checklist, you MUST evaluate whether it should change and propose **bounded** edits. You MUST NOT change `CODE_AUDITING.md` without the user's approval.

- A real defect the checklist did **not** lead you to catch → MUST become a **proposed new item**.
- A finding type that recurs across audits → MUST be proposed for promotion (higher severity, or a hard project rule).
- An item that produced false positives or proved unactionable → MUST be proposed for revision.

Propose at most a few edits per audit. Present them in the summary; apply only what the user approves.

## Severity

| Severity | Meaning |
|---|---|
| **Critical** | Breaks correctness, security, or data integrity; MUST be fixed before shipping. |
| **Important** | A real defect or risk; MUST be fixed before further implementation work. |
| **Minor** | Style, clarity, or a non-urgent improvement; MAY be deferred, MUST be recorded. |

## Red Flags — STOP

| Red flag | Do this instead |
| --- | --- |
| "I'll just re-read my own reasoning." | Not a review. Run the independent pass of 1a. |
| "No subagent here, so I'll skip it." | Run the no-subagent fallback pass. |
| "I'll edit while I review." | Keep the pass read-only; act in Phase 4. |
| "The Critical issue is probably fine." | Fix it before proceeding. |
| "I'll fix the Important issue later." | Fix it before any further implementation work. |
| A finding with no `file:line` evidence | Verify it in the code, or mark it unverified. |

## Rationalizations — all REJECTED

| Rationalization | Do this instead |
| --- | --- |
| "I already checked it as I wrote it." / "I'm the author, I know it's correct." | Review the finished diff cold, as a separate pass. |
| "Minor issues don't matter, I'll drop them." | Record every Minor issue. |
| "The checklist is close enough, I'll tweak it as I go." | Propose the edit in Phase 5; MUST NOT rewrite mid-audit. |

## Verification Checklist

Before treating code as reviewed, confirm every item:

- [ ] The mode was chosen deliberately (checkpoint review, standards audit, or both)
- [ ] For a checkpoint review: the range is committed, `BASE_SHA`/`HEAD_SHA` captured from the merge-base, and the requirements source named (or its absence stated)
- [ ] For a standards audit: the checklist exists, is approved, and every item has a verdict
- [ ] The real code was read; every finding carries `file:line` evidence
- [ ] Spec and quality findings are reported separately, without cross-axis re-ranking
- [ ] The full record is on disk AND the summary is in the session
- [ ] Every Critical is fixed; every Important is fixed before further implementation work; every Minor is recorded
- [ ] Any disputed finding was answered with specific technical reasoning
- [ ] For a standards audit: checklist improvements were proposed (or none were warranted)
