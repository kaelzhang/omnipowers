---
name: code-auditing
description: Use when reviewing, auditing, or assessing code — a diff, a branch, a commit range, a pull request, a file, a feature, or the whole project; before a merge, commit, push, or refactor; after finishing work or a complex bug fix — you MUST review the real code with evidence, report findings by severity, and act on every Critical and Important one before proceeding
---

# Code Auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A code audit is a deep, evidence-based review of real code — never a one-shot impression. Two situations need it, and this skill covers both: **checkpoint review** of finished work before it advances (a branch, a task, a diff), and **standards audit** against the project's own checklist. Phase 1 routes to the right one.

**Iron Law: You MUST NOT claim code is reviewed without an independent pass over the actual code with evidence for every finding.** Re-reading your own justification is not a review; an impression is not an audit.

**Core principle:** A finding you did not verify in the actual code is not a finding.

**Self-contained & portable:** This skill and everything it creates live inside the audited project, in the locations that project declares (falling back to `<project-root>/.omnipowers/`). It MUST NOT depend on any tool, service, or repository outside that project.

## When to Use

You MUST use this skill whenever code is to be reviewed, audited, or assessed:

- After completing a discrete task in a plan, a major feature, or a complex bug fix.
- Before merging, committing, pushing, or starting a refactor (a pre-refactor review sets the baseline).
- When asked to audit or assess a codebase, a PR, a diff, or a commit range.
- When stuck and a fresh perspective would help.

You MUST NOT skip review because the change "is simple," "is small," or "obviously works." Those are exactly the changes where a self-audit misses the most.

## Phase 1 — Route: checkpoint review or standards audit

Determine the mode from the target, then follow that branch. Both modes share Phase 2's rigor, Phase 3's recording, and Phase 4's reporting.

| The target is… | Mode | What governs the checks |
|---|---|---|
| Finished work advancing to the next step (a branch, a plan task, a feature, a PR, a diff before merge/commit/push/refactor) | **Checkpoint review** | The work's own requirements + the reviewer brief |
| The codebase, a subsystem, or a change being assessed against the project's standard | **Standards audit** | The project checklist (generated on first use) |

When both apply — a finished branch in a project that has a checklist — you MUST run the checkpoint review and use the checklist as an additional lens.

### 1a. Checkpoint review

**Capture the range first.** The reviewed range MUST cover the entire body of work, not just the last commit:

```bash
BASE_SHA=$(git merge-base HEAD <main-branch>)   # feature / pre-merge review
HEAD_SHA=$(git rev-parse HEAD)
```

Use `BASE_SHA=$(git rev-parse HEAD~1)` ONLY for a single-task checkpoint where exactly one commit is under review — scoping to one commit when the work spans several silently leaves most of the diff unreviewed. You MUST review a committed range: if the work is uncommitted, commit it (or stash and review the stash) so the diff is stable.

**Find the requirements.** You MUST review the work against what it was supposed to do. Discover the requirements source in this order: the design document this work implements, wherever the project keeps them → the task brief the implementer worked from → the plan file → requirement references in the commit messages → ask the user. If none exists, you MUST state explicitly that the review ran without a requirements source (quality-axis only, degraded) rather than silently reviewing against nothing.

**Run an independent pass.** Read `@reviewer-brief.md` and apply it.
- **With subagents:** you MUST dispatch one independent reviewer using that brief with the placeholders filled in; it MUST run read-only.
- **Without subagents:** you MUST perform the review yourself as a deliberate, separate pass — treat the diff as if written by someone else, work only from the requirements and the diff (never your memory of writing it), read the entire diff top to bottom before concluding, apply the full brief, and keep the pass read-only (record findings first; act in Phase 4).

The fallback MUST NOT be a token gesture. A self-review that merely confirms your prior intent violates the Iron Law.

### 1b. Standards audit

**First, find the criteria.** You MUST resolve where this project's audit criteria come from, stopping at the first that applies:

1. a source the user names in this session;
2. the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `standards` row;
3. a standards set the project already publishes and expects its contributors to follow (a standards directory, a contributor guide, a documented coding standard);
4. none of the above — the project publishes no criteria.

**When 1, 2, or 3 applies you MUST audit against that source, and you MUST NOT generate a checklist of your own.** A model-generated standard filed beside a maintained one competes with it, and the project is left with two answers to every question and no rule for which wins. Where the published source leaves one of the dimensions below uncovered, you MAY audit that dimension against the portable baseline in `@code-smells.md`, and you MUST say so in the report.

**Only when 4 applies do you generate a checklist, and you MUST generate it before auditing anything:**

1. **Survey the project.** Read enough of it to ground the checklist in THIS codebase: languages, frameworks, architecture and layering, the domain, the security/trust surface, the concurrency model, data and schema, build/release, the test setup, and the project's own conventions (`CLAUDE.md` / `AGENTS.md` / docs / linters).
2. **Draft a multi-dimensional checklist.** It MUST cover at least these dimensions, each specialized to this project (drop one only if it genuinely cannot apply, and state why): correctness & logic; security & trust boundaries; error handling & failure modes; concurrency, ordering & resource lifecycle; performance & complexity; API / contract / backward compatibility; data, schema & migrations; tests & coverage (incl. a regression test for every fixed bug); readability, naming & maintainability; structure, layering & boundaries; dependencies & supply chain; documentation & comments. Each item MUST be a concrete, checkable question — not a vague "is it good?".
3. **Optimize it by bounded iteration.** Apply at least three distinct improvement lenses — completeness / missing failure modes, project-fit / actionability, redundancy / granularity — each as its own round (a further round only if it still finds a real gap). Then **stop at the first round that produces no material change**, and MUST NOT exceed **5** rounds: beyond the cap, extra rounds invent unsupported items.
4. **Write it** where the project keeps its criteria — the `standards` location resolved above, falling back to `<project-root>/.omnipowers/rules/CODE_AUDITING.md` when the project has none (`<project-root>` is the repository root, or your working directory if it is not a repo). Give it a short header (project, generated date, dimension list) and group items by dimension.
5. **Get approval before first use.** It becomes this project's durable standard, so you MUST present it — with the location you resolved — and obtain approval (incorporating the user's edits) before auditing against it. You SHOULD treat it as a commit-worthy project artifact.

**If a generated checklist already exists, you MUST use it as-is for this audit.** Improvements go through Phase 5 (gated); you MUST NOT silently rewrite it mid-audit.

Scope the depth to the target: a **whole-project audit** checks every item against the whole codebase; a **change audit** still considers every item but focuses the deep checks on the **changed surface and its blast radius**, ordered by risk — you MUST NOT re-audit unrelated code line by line.

## Phase 2 — Rigor (both modes)

For everything you check, you MUST: inspect the actual code (read it; do not assume); reach a verdict — **pass**, **fail**, **concern**, or **n/a** (with a one-line reason for n/a); and for every `fail` / `concern` record a concrete `file:line`, the evidence, a **severity**, and a specific, actionable fix.

You MUST also: verify each finding against the real code (raise no speculative finding; if you cannot verify, say so and mark it unverified); apply YAGNI and context (before flagging "missing X", confirm X is needed; before flagging a pattern, check for a legacy/compatibility/intentional reason); skip anything the project's tooling already enforces (linter, formatter, type checker — a finding the machine catches is noise); and be specific and non-performative (state the issue and the fix; no praise or filler).

**Report the two axes separately** — spec conformance (missing / unrequested / wrong, each quoting the requirement it violates) and code quality. A finding MUST NOT be re-ranked across axes: a spec gap is not excused by beautiful code, and a quality defect is not excused by spec conformance.

## Phase 3 — Record the audit

An audit report is a **record**. You MUST resolve where it goes in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `records` row; (3) where the host already keeps review write-ups, when that is unambiguous; (4) the fallback:

```
<project-root>/.omnipowers/reviews/<YYYY-MM-DD>-<HHMMSS>-<review-target>.md
```

Resolving to 3 or 4 MUST be confirmed with the user before the project's first audit is recorded; resolving to 1 or 2 MUST NOT ask. You MUST create any missing parent directories. `<review-target>` is a short kebab-case slug of what was reviewed (e.g. `auth-refactor`, `pr-142`, `whole-project`). The file MUST contain: the target and scope (including the reviewed range for a checkpoint review), the requirements or checklist reference, every verdict, all findings (each with `file:line` + severity + fix), and the overall assessment.

## Phase 4 — Report and act

You MUST output a concise summary to the session: the findings grouped by axis and severity, every `Critical` and `Important` finding (location + one-line fix), the overall assessment (ship / fix-first / needs-rework), and the path to the recorded file. Both outputs are REQUIRED — the record on disk AND the session summary. When the target is a pull request and you post findings to it, you SHOULD place each inline finding in its code comment thread rather than as one top-level comment.

Then act on the findings:

- You MUST fix every **Critical** issue before proceeding.
- You MUST fix every **Important** issue before any further implementation work (the next task, a refactor, or a merge). Deferring it past this checkpoint leaves the defect to compound.
- You MUST record **Minor** issues (task notes or an issue tracker) rather than silently dropping them.
- If a finding is wrong, you MUST push back with specific technical reasoning — cite the code, the tests, or the requirement. You MUST NOT accept an incorrect finding just to close it out, and MUST NOT dismiss one without that reasoning.

## Phase 5 — Evolve the checklist (gated; standards audits)

The checklist MUST get sharper with use. After an audit that used or created one, you MUST evaluate whether it should change and propose **bounded** edits — but you MUST NOT change `CODE_AUDITING.md` without the user's approval:

- A real defect the checklist did **not** lead you to catch MUST become a **proposed new item** (so that defect class is caught next time).
- A finding type that recurs across audits MUST be proposed for promotion (higher severity, or a hard project rule).
- An item that produced false positives or proved unactionable MUST be proposed for revision.

Propose at most a few edits per audit. Present them in the summary; apply only what the user approves.

## Severity

| Severity | Meaning |
|---|---|
| **Critical** | Breaks correctness, security, or data integrity; MUST be fixed before shipping. |
| **Important** | A real defect or risk; MUST be fixed before further implementation work. |
| **Minor** | Style, clarity, or a non-urgent improvement; MAY be deferred, MUST be recorded. |

## Red Flags — STOP

| Red flag | Reality |
| --- | --- |
| "It's simple, skip the review." | Simple changes are where self-audits miss the most. |
| "I'll just re-read my own reasoning." | That is not a review. The pass MUST be independent of your intent. |
| "The Critical issue is probably fine." | You MUST NOT proceed with an unfixed Critical issue. |
| "I'll fix the Important issue later." | Fix it before any further implementation work. |
| "No subagent here, so I'll skip it." | Run the fallback pass. Absence of subagents is not absence of review. |
| "I'll edit while I review." | The review pass MUST be read-only; act only in Phase 4. |
| Reviewing `HEAD~1` for multi-commit work | Most of the diff goes unreviewed. Use the merge-base range. |
| A finding with no `file:line` evidence | Unverified impressions are not findings. |
| Auditing to a standard with no checklist present | Generate and get it approved first (Phase 1b). |
| Summary reported but nothing recorded to disk (or vice versa) | Both outputs are REQUIRED. |
| An audit exposed a checklist gap and you proposed nothing | Phase 5 is not optional. |

## Rationalizations — all REJECTED

| Rationalization | Why it fails |
| --- | --- |
| "It obviously works, review is overhead." | "Obvious" correctness is the most common source of shipped defects. |
| "I already checked it as I wrote it." | Checking-while-writing is not an independent pass. Review the finished diff cold. |
| "I'm the author, I know it's correct." | Author confidence is exactly the bias an independent pass counteracts. |
| "Minor issues don't matter, I'll drop them." | Minor issues MUST be recorded, not dropped. |
| "The checklist is close enough, I'll tweak it as I go." | Silent mid-audit rewrites destroy the standard's meaning. Propose in Phase 5. |

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

## The Bottom Line

Read the real code. Evidence for every finding. Record it, summarize it, act on it — Critical and Important before anything advances. Then make the checklist sharper.
