---
name: code-auditing
description: Use when reviewing, auditing, or assessing code ("代码评审", "审计") — a diff, a branch, a commit range, a pull request, a file, a feature, or the whole project — or when finished work is about to advance — a merge, a pull request, a release, a handover. An ordinary commit is not a review trigger.
---

# Code Auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Definitions

Checkpoint review — an independent review of finished work before it advances, governed by the work's requirements and the reviewer brief.

Standards audit — an assessment against the host project's checklist.

Standards source — the host's `standards` artifact resolved per `using-omnipowers`; step 3 is a standards set the project publishes and expects contributors to follow; step 4 is the absence of published standards.

Audit report — a `records` artifact with its location resolved per `using-omnipowers` and this fallback:

```
<project-root>/.omnipowers/reviews/<YYYY-MM-DD>-<HHMMSS>-<review-target>.md
```

`<project-root>` — the repository root, or the working directory outside a repository.

`<review-target>` — a short kebab-case slug of what was reviewed.

## Governing rules

- Before claiming code is reviewed → you MUST NOT make that claim without an independent pass over the actual code with evidence for every finding.
- For every artifact this skill creates → it MUST live inside the audited project, in the locations that project declares (fallback: `<project-root>/.omnipowers/`).
- When using this skill → it MUST NOT depend on any tool, service, or repository outside the audited project.

## When to Use

Completion of one task inside an unfinished plan — not a review trigger.

When any of these conditions holds → you MUST use this skill:

- a plan, a major feature, or a complex bug fix is complete;
- work is about to be merged, opened as a pull request, released, handed over, depended on, or taken into a refactor;
- you are asked to audit or assess a codebase, a PR, a diff, or a commit range;
- you are stuck and a fresh perspective would help.

A review is warranted → you MUST NOT skip or shallow it on the grounds that the change "is simple," "is small," or "obviously works."

## Phase 1 — Route: checkpoint review or standards audit

A finished branch has a project checklist → you MUST run the checkpoint review and use the checklist as an additional lens.

### 1a. Checkpoint review

For a checkpoint review → the reviewed range MUST cover the entire body of work, not just the last commit:

```bash
BASE_SHA=$(git merge-base HEAD <main-branch>)   # feature / pre-merge review
HEAD_SHA=$(git rev-parse HEAD)
```

- The review is not an exactly-one-commit single-task checkpoint → you MUST NOT use `BASE_SHA=$(git rev-parse HEAD~1)`.
- For a checkpoint review → you MUST review a committed range.
- For a checkpoint review → you MUST review the work against what it was supposed to do.
- No requirements source exists → you MUST state explicitly that the review ran without a requirements source (quality-axis only, degraded).

#### Independent pass (checkpoint review)

Checkpoint review → read `@reviewer-brief.md` and apply it.

- Subagents are available → you MUST dispatch one independent reviewer using that brief with the placeholders filled in.
- An independent reviewer is dispatched → it MUST run read-only.
- No subagents are available → you MUST perform the review yourself as a deliberate, separate pass: treat the diff as if written by someone else, work only from the requirements and the diff (never your memory of writing it), read the entire diff top to bottom before concluding, apply the full brief, and keep the pass read-only (record findings first; act in Phase 4).
- The no-subagent fallback is used → it MUST NOT be a token gesture.

### 1b. Standards audit

- Standards-source step 1, 2, or 3 applies → you MUST audit against that source.
- Standards-source step 1, 2, or 3 applies → you MUST NOT generate a checklist of your own.
- The published source leaves a checklist dimension below uncovered → you MAY audit that dimension against the portable baseline in `@code-smells.md`.
- The portable baseline is used for an uncovered dimension → you MUST say so in the report.

Standards-source step 4 applies → you MUST generate the checklist before auditing anything, using these steps:

1. Survey the project: read enough of it to ground the checklist in this codebase, covering languages, frameworks, architecture and layering, the domain, the security/trust surface, the concurrency model, data and schema, build/release, the test setup, and the project's own conventions (`CLAUDE.md` / `AGENTS.md` / docs / linters).
2. Draft a multi-dimensional checklist specialized to this project; if the project has no code or behavior to which a dimension applies, drop it and state why.
3. Optimize it by bounded iteration: apply at least three distinct improvement lenses — completeness / missing failure modes, project-fit / actionability, redundancy / granularity — each as its own round; run a further round only if the last one still found a real gap; stop at the first round that produces no material change.
4. Write it in the resolved `standards` location, falling back to `<project-root>/.omnipowers/rules/CODE_AUDITING.md` when the project has none; give it a short header (project, generated date, dimension list) and group items by dimension.
5. Present it with the resolved location and obtain approval, incorporating the user's edits, before auditing against it.

- When generating a checklist → it MUST cover at least these dimensions, each specialized to this project: correctness & logic; security & trust boundaries; error handling & failure modes; concurrency, ordering & resource lifecycle; performance & complexity; API / contract / backward compatibility; data, schema & migrations; tests & coverage (incl. a regression test for every fixed bug); readability, naming & maintainability; structure, layering & boundaries; dependencies & supply chain; documentation & comments.
- For each generated checklist item → it MUST be a concrete, checkable question, never a vague "is it good?".
- When optimizing a generated checklist → you MUST NOT exceed **5** rounds.
- Before first use of a generated checklist → you MUST present it with its resolved location and obtain approval, incorporating the user's edits, before auditing against it.
- For a generated checklist → you SHOULD treat it as a commit-worthy project artifact.
- A generated checklist already exists → you MUST use it as-is for this audit.
- A generated checklist already exists → you MUST NOT rewrite it mid-audit.
- During a change audit → you MUST NOT re-audit unrelated code line by line.

## Phase 2 — Rigor (both modes)

For everything you check → you MUST:

- inspect the actual code — read it, do not assume;
- reach a verdict — **pass**, **fail**, **concern**, or **n/a**, with a one-line reason for n/a;
- for every `fail` / `concern`, record a concrete `file:line`, the evidence, a **severity**, and a specific, actionable fix;
- verify each finding against the real code and raise no speculative finding; if you cannot verify one, state that and mark it unverified;
- apply YAGNI and context — before flagging "missing X", confirm X is needed; before flagging a pattern, check for a legacy / compatibility / intentional reason;
- skip anything the project's tooling already enforces (linter, formatter, type checker);
- be specific and non-performative — state the issue and the fix, with no praise or filler.

For every finding → it MUST NOT be re-ranked across the spec-conformance and code-quality axes.

## Phase 3 — Record the audit

- A standards audit, a whole-project or subsystem assessment, a pre-release review, or an audit the user asked to have on file is performed → a written file is REQUIRED.
- A checkpoint review of a change about to merge is performed → the report file is OPTIONAL.
- For every audit → the report MUST contain the target and scope (including the reviewed range for a checkpoint review), the requirements or checklist reference, every verdict, all findings (each with `file:line` + severity + fix), and the overall assessment.

## Phase 4 — Report and act

- For every audit → you MUST output a concise summary to the session: the findings grouped by axis and severity, every `Critical` and `Important` finding (location + one-line fix), and the overall assessment (ship / fix-first / needs-rework).
- In every mode → the session summary is REQUIRED.
- Phase 3 required a written record → its path MUST appear in the summary.
- The target is a pull request and you post findings to it → you SHOULD place each inline finding in its code comment thread rather than as one top-level comment.
- A finding is **Critical** → you MUST fix it before proceeding.
- A finding is **Important** → you MUST fix it before any further implementation work (the next task, a refactor, or a merge).
- A finding is **Minor** → you MUST record it in task notes or an issue tracker.
- A finding is wrong → you MUST push back with specific technical reasoning citing the code, the tests, or the requirement.
- A finding is incorrect → you MUST NOT accept it just to close it out.
- A finding is wrong → you MUST NOT dismiss it without specific technical reasoning citing the code, the tests, or the requirement.

## Phase 5 — Evolve the checklist (gated; standards audits)

- After an audit that used or created a checklist → you MUST evaluate whether it should change and propose **bounded** edits.
- The user has not approved a change to `CODE_AUDITING.md` → you MUST NOT change it.
- A real defect was not caught through the checklist → it MUST become a **proposed new item**.
- A finding type recurs across audits → it MUST be proposed for promotion (higher severity, or a hard project rule).
- An item produced false positives or proved unactionable → it MUST be proposed for revision.

## Severity

Critical — a finding that breaks correctness, security, or data integrity.

Important — a finding that is a real defect or risk.

Minor — a finding about style, clarity, or a non-urgent improvement.

- A finding is Critical → it MUST be fixed before shipping.
- A finding is Important → it MUST be fixed before further implementation work.
- A finding is Minor → it MAY be deferred.
- A finding is Minor → it MUST be recorded.

## Red Flags — STOP

| Red flag | Do this instead |
| --- | --- |
| "I'll just re-read my own reasoning." | Run the independent pass of 1a. |
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
