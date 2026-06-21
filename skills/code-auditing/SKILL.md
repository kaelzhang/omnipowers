---
name: code-auditing
description: Use when reviewing or auditing code (a diff, a file, a feature, or the whole project) — you MUST audit against the project's .omnipowers/rules/CODE_AUDITING.md checklist, record the result, report a summary, and evolve the checklist over time
---

# Code Auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A code audit is a deep, evidence-based review against an explicit, project-tuned checklist that **gets sharper with use** — not a one-shot impression. You MUST check every checklist item against the real code, record the result, report a summary, and feed what you learn back into the checklist (gated).

**Core principle:** A finding you did not verify in the actual code is not a finding. The checklist is a living project asset; each audit MUST make it sharper.

**Self-contained & portable:** This skill and everything it creates live entirely inside the audited project, under `<project-root>/.omnipowers/`. The skill MUST NOT depend on any tool, service, or repository outside that project. It MUST work the same in any project it is installed into.

## When to Use

Use this skill whenever you are asked to review, audit, or assess the quality of code — a diff, a file, a feature, a pull request, or the whole project. This skill governs **performing** the audit. The rigor below (verify, no performative language, push back) also applies to how you treat any claim you make.

## The Workflow (MANDATORY)

You MUST run phases 0–4, in order. You MUST NOT skip Phase 0 or shortcut Phase 1.

### Phase 0 — Ensure the project audit checklist exists and is approved

You MUST ensure `<project-root>/.omnipowers/rules/CODE_AUDITING.md` exists (`<project-root>` is the repository root, or your working directory if it is not a repo).

**If it does NOT exist, you MUST generate it before auditing anything:**

1. **Survey the project.** You MUST read enough of it to ground the checklist in THIS codebase: languages, frameworks, architecture and layering, the domain, the security/trust surface, the concurrency model, data and schema, build/release, the test setup, and the project's own conventions (`CLAUDE.md` / `AGENTS.md` / docs / linters).
2. **Draft a multi-dimensional checklist.** It MUST cover at least these dimensions, each specialized to this project (drop a dimension only if it genuinely cannot apply, and state why): correctness & logic; security & trust boundaries; error handling & failure modes; concurrency, ordering & resource lifecycle; performance & complexity; API / contract / backward compatibility; data, schema & migrations; tests & coverage (incl. a regression test for every fixed bug); readability, naming & maintainability; structure, layering & boundaries; dependencies & supply chain; documentation & comments. Each item MUST be a concrete, checkable question — not a vague "is it good?".
3. **Optimize it by bounded iteration.** You MUST apply at least three distinct improvement lenses before accepting the checklist — completeness / missing failure modes, project-fit / actionability, and redundancy / granularity — each as its own round (you MAY add a further round only if it still finds a real gap). Once all three lenses are covered, you MUST **stop at the first round that produces no material change** (convergence). You MUST NOT exceed **5** rounds: beyond the cap, extra rounds tend to invent unsupported items (hallucination) and drift — stop and keep the last good version.
4. **Write it** to `.omnipowers/rules/CODE_AUDITING.md` with a short header (project, generated date, the dimension list) and the items grouped by dimension.
5. **Get approval before first use.** The checklist becomes this project's durable audit standard, so you MUST present it to the user and obtain approval (incorporating any edits they give) before you audit against it or treat it as fixed. You SHOULD treat it as a commit-worthy project artifact.

**If `CODE_AUDITING.md` already exists, you MUST use it as-is for this audit.** Improvements go through Phase 4 (gated); you MUST NOT silently rewrite it mid-audit.

### Phase 1 — Audit against the checklist

You MUST cover every checklist item. Scope the depth to the target:

- **Whole-project audit** — check every item against the whole codebase.
- **Change / diff audit** (a PR, a commit range, a feature) — you MUST still consider every item, but you MUST focus the deep checks on the **changed surface and its blast radius**, ordered by risk and severity. You MUST NOT re-audit unrelated, unchanged code line by line.

For each item you check, you MUST: inspect the actual code (read it; do not assume); reach a verdict — **pass**, **fail**, **concern**, or **n/a** (with a one-line reason for n/a); and for every `fail` / `concern` record a concrete `file:line`, the evidence, a **severity** (`Critical` / `Important` / `Minor`), and a specific, actionable fix.

Audit rigor — you MUST: verify each finding against the real code (raise no speculative finding you could not confirm; if you cannot verify, say so and mark it unverified); apply YAGNI and context (before flagging "missing X", confirm X is needed/used; before flagging a pattern, check for a legacy/compatibility/intentional reason); be specific and non-performative (state the issue and the fix; no praise or filler).

### Phase 2 — Record the audit

You MUST create `.omnipowers/reviews/` if it does not exist, and write the full audit to:

```
<project-root>/.omnipowers/reviews/<YYYY-MM-DD>-<HHMMSS>-<review-target>.md
```

`<review-target>` is a short kebab-case slug of what was audited (e.g. `auth-refactor`, `pr-142`, `whole-project`). The file MUST contain: the target and scope, the checklist reference, every item's verdict, all findings (each with `file:line` + severity + fix), and the overall assessment.

### Phase 3 — Report a summary

You MUST output a concise summary to the session: one line per dimension with its result (`pass` / `concern` / `fail`, optionally with a ✓ / ⚠ / ✗ glyph) plus a count; every `Critical` and `Important` finding (location + one-line fix); the overall assessment (ship / fix-first / needs-rework); and the path to the recorded audit file. Both outputs are REQUIRED — the full record on disk AND the summary in the session.

### Phase 4 — Evolve the checklist (gated)

The checklist MUST get sharper with use. After the audit you MUST evaluate whether it should change, and propose **bounded** edits when it should — but you MUST NOT apply any change to `CODE_AUDITING.md` without the user's approval. Specifically:

- A real defect the checklist did **not** lead you to catch MUST become a **proposed new item** (a regression item, so that defect class is caught next time).
- A finding type that recurs across audits MUST be proposed for promotion (higher severity, or a hard project rule).
- An item that produced false positives or proved unactionable MUST be proposed for revision.

Propose at most a few edits per audit (bounded — avoid churn). Present them in the summary; apply only those the user approves.

## Severity

| Severity | Meaning |
|---|---|
| **Critical** | Breaks correctness, security, or data integrity; MUST be fixed before shipping. |
| **Important** | A real defect or risk; SHOULD be fixed before proceeding. |
| **Minor** | Style, clarity, or a non-urgent improvement; MAY be deferred. |

## Red Flags — STOP

- Auditing without `.omnipowers/rules/CODE_AUDITING.md` present — generate it first.
- Accepting the checklist before applying all three improvement lenses, or grinding past the 5-round cap and inventing unsupported items.
- Using a freshly generated checklist without the user's approval.
- Skimming the checklist instead of checking each item against the real code.
- A finding with no `file:line` evidence.
- Reporting the session summary but not recording the full audit to disk (or vice versa).
- Finishing an audit that exposed a checklist gap without proposing a checklist improvement.
- Depending on any tool or repository outside the audited project's `.omnipowers/`.

## The Bottom Line

Check every item against the real code, with evidence. Record it. Summarize it. Then make the checklist sharper. No impressions, no performative praise, no runaway iteration.
