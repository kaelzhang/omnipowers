---
name: code-auditing
description: Use when reviewing or auditing code (a diff, a file, a feature, or the whole project) — you MUST audit against the project's .omnipowers/rules/CODE_AUDITING.md checklist, record the result, and report a summary
---

# Code Auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A code audit is a deep, evidence-based review against an explicit, project-tuned checklist — not an impression. You MUST check every checklist item against the real code, record the result, and report a summary.

**Core principle:** A finding you did not verify in the actual code is not a finding. Evidence (`file:line`) over impression; technical correctness over reassurance.

## When to Use

Use this skill whenever you are asked to review, audit, or assess the quality of code — a diff, a file, a feature, a pull request, or the whole project. This skill governs **performing** the audit. The rigor below (verify, no performative language, push back) also applies to how you treat any claim you make.

## The Workflow (MANDATORY)

You MUST run all four phases, in order. You MUST NOT skip Phase 0 or shortcut Phase 1.

### Phase 0 — Ensure the project audit checklist exists

You MUST ensure the directory `<project-root>/.omnipowers/rules/` exists and contains `CODE_AUDITING.md` (`<project-root>` is the repository root, or your working directory if it is not a repo).

**If `CODE_AUDITING.md` does NOT exist, you MUST generate it before auditing anything:**

1. **Survey the project.** You MUST read enough of the project to ground the checklist in THIS codebase: languages, frameworks, architecture and layering, the domain, the security/trust surface, the concurrency model, data and schema, build/release, the test setup, and the project's own conventions (`CLAUDE.md` / `AGENTS.md` / docs / linters).
2. **Draft a multi-dimensional checklist.** It MUST cover at least these dimensions, each specialized to this project (drop a dimension only if it genuinely cannot apply, and state why):
   - Correctness & logic
   - Security & trust boundaries (input validation, authn/authz, secrets, injection)
   - Error handling & failure modes
   - Concurrency, ordering & resource lifecycle
   - Performance & algorithmic complexity
   - API / contract / backward compatibility
   - Data, schema & migrations
   - Tests & coverage (including a regression test for every fixed bug)
   - Readability, naming & maintainability
   - Structure, layering & boundaries (no cross-layer or cross-module coupling)
   - Dependencies & supply chain
   - Documentation & comments

   Each item MUST be a concrete, checkable question — not a vague "is it good?".
3. **Iterate three optimization rounds.** Before saving, you MUST run three improvement rounds. In each round you MUST critique the current checklist for: missing failure modes, redundancy, items that are not actionable, items that do not fit THIS project, and wrong granularity — then revise. You MUST keep only the final, optimized checklist.
4. **Write it** to `.omnipowers/rules/CODE_AUDITING.md` with a short header (project, generated date, the dimension list) and the items grouped by dimension.

**If `CODE_AUDITING.md` already exists, you MUST use it as-is for this audit.** You MAY note suggested improvements in the summary, but you MUST NOT silently rewrite it during an audit; regenerating or editing the checklist is a separate, explicit action.

### Phase 1 — Audit against every checklist item

You MUST check the target against EVERY item in `CODE_AUDITING.md`. For each item you MUST:

- Inspect the actual code — read it; do not assume.
- Reach a verdict: **pass**, **fail**, **concern**, or **n/a** (with a one-line reason for n/a).
- For every `fail` or `concern`, record a concrete `file:line`, the evidence, a **severity** (`Critical` / `Important` / `Minor`), and a specific, actionable recommendation.

Audit rigor — you MUST:

- Verify each finding against the real code. You MUST NOT raise a speculative finding you could not confirm; if you cannot verify it, say so and mark it unverified.
- Apply YAGNI and context: before flagging "missing X", confirm X is actually needed or used; before flagging a pattern, check for a legacy, compatibility, or intentional reason (read comments and history).
- Be specific and non-performative: state the issue and the fix. You MUST NOT pad the audit with praise or filler.

### Phase 2 — Record the audit

You MUST create `.omnipowers/reviews/` if it does not exist, and write the full audit to:

```
<project-root>/.omnipowers/reviews/<YYYY-MM-DD>-<HHMMSS>-<review-target>.md
```

`<review-target>` is a short kebab-case slug of what was audited (e.g. `auth-refactor`, `pr-142`, `whole-project`). The file MUST contain: the target and scope, the checklist reference, every item's verdict, all findings (each with `file:line` + severity + recommendation), and the overall assessment.

### Phase 3 — Report a summary

You MUST output a concise summary to the session containing:

- one line per dimension with its result (e.g. ✓ / ⚠ / ✗ plus a count),
- every `Critical` and `Important` finding (location + one-line fix),
- the overall assessment (e.g. ship / fix-first / needs-rework),
- the path to the recorded audit file.

Both outputs are REQUIRED: the full record on disk AND the summary in the session. You MUST NOT report only the summary without recording the full audit, and you MUST NOT record the file without reporting the summary.

## Severity

| Severity | Meaning |
|---|---|
| **Critical** | Breaks correctness, security, or data integrity; MUST be fixed before shipping. |
| **Important** | A real defect or risk; SHOULD be fixed before proceeding. |
| **Minor** | Style, clarity, or a non-urgent improvement; MAY be deferred. |

## Red Flags — STOP

- Auditing without `.omnipowers/rules/CODE_AUDITING.md` present — generate it first.
- Skimming the checklist instead of checking each item against the real code.
- A finding with no `file:line` evidence.
- Praise or "looks good" instead of per-item verdicts.
- Generating the checklist in fewer than three optimization rounds.
- Reporting the session summary but not recording the full audit to disk (or vice versa).

## The Bottom Line

Check every item, against the real code, with evidence. Record it. Summarize it. No impressions, no performative praise.
