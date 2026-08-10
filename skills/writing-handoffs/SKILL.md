---
name: writing-handoffs
description: Use only when the user explicitly asks to hand off or compact this session for another agent ("handoff", "continuation/resume doc") — you MUST produce a handoff document a zero-context agent can resume from, and MUST NOT fire without that explicit request
---

# Writing Handoffs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A good handoff is a single document from which an agent with zero access to this conversation can resume the work: what it is for, what is verifiably done, where every artifact lives, what to do next, and which skills to arm. You MUST write the handoff so that it alone — plus the artifacts it points to — is sufficient to continue; anything that exists only in this conversation and is not captured or pointed to is lost at the session boundary.

**Core principle:** The handoff carries *state* and *pointers*, never copies of content. It compacts the session; it does not archive it.

## User-Initiated Only

- This skill MUST NOT fire on your own initiative. Only an explicit user request ("hand off", "compact this session", "write a continuation doc", or equivalent) triggers it. An unrequested "helpful" mid-task compaction is harmful: it interrupts live work and tempts you to treat the summary as a substitute for the real context.
- If you believe a handoff would help (context nearly exhausted, natural stopping point), you MAY say so in one sentence. The user decides; you MUST NOT write the document until they ask.

## Scope — Purpose-Tailored

- If the user states what the next session is for, the handoff MUST be scoped to that purpose: full detail for it, at most a one-line pointer for unrelated open threads.
- If no purpose is stated, the handoff MUST cover **all** open work in the session — a thread silently dropped here is a thread lost.

## Required Sections

The document MUST contain all of the following, in this order:

1. **Goal** — what the work is trying to achieve, and the definition of done. The successor MUST be able to tell from this section alone when to stop.
2. **Current state — with evidence** — what is done and what is in progress. Every "done" claim MUST cite the verification you actually observed (the test command and its result, the review outcome, the command output). A claim you did not verify MUST be labeled unverified — an evidence-free "done" sends the successor past broken work.
3. **Artifact index** — every spec, plan, commit, diff, and file the work touches or depends on, referenced **by path, commit hash, or identifier**. You MUST NOT duplicate an artifact's content into the handoff: duplication forks the truth (the copy goes stale) and bloats the document past what a fresh agent can load whole. One line of *why it matters* per entry is the maximum.
4. **Next steps** — concrete, ordered actions. Each step MUST be specific enough to start without re-deriving the analysis ("add the range check in `parse_window()` per plan step 4", not "continue the fix").
5. **Open questions / blockers** — every unresolved decision, missing input, and external blocker. If there are none, state "none" explicitly.
6. **Suggested skills** — which skills the successor agent SHOULD invoke and for what (e.g. "invoke the executing-plans skill against the plan above"; "invoke the test-driven-bug-fixing skill for the open bug"). Skill triggers do not survive the session boundary — this section is REQUIRED because it is what re-arms them.
7. **Constraints** — every rule that binds the work: user preferences stated this session, project rules, locked decisions, things explicitly ruled out. An unrecorded constraint WILL be violated by a successor who never saw it.

## Template

```markdown
# Handoff — <purpose> (<date>)

## Goal
<what the work achieves; definition of done>

## Current state
- DONE: <item> — evidence: <command/test/review observed and its result>
- IN PROGRESS: <item> — <exactly where it stands>
- UNVERIFIED: <item> — <why verification is still owed>

## Artifact index
- <path | commit hash | id> — <one line: why it matters>

## Next steps
1. <concrete, ordered action>

## Open questions / blockers
- <item, or "none">

## Suggested skills
- <skill name> — <invoke for what>

## Constraints
- <binding rule, preference, or locked decision>
```

## Redaction — Before Anything Touches Disk

You MUST scan the material for secrets, credentials, API keys, tokens, connection strings, and PII, and redact each occurrence (e.g. `[REDACTED:api-key]`) **before** writing the file. A handoff persists conversation content to disk; leaking a credential into it is unrecoverable. This rule has no exception.

## Location

- A handoff is **work state**. You MUST resolve where it goes in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `work-state` row; (3) where the host already records progress, blockers, and the next action for work in progress, when that is unambiguous; (4) the fallback `.omnipowers/handoffs/YYYY-MM-DD-<purpose>.md`, with `<purpose>` a short kebab-case slug. Resolving to 3 or 4 MUST be confirmed with the user before the project's first handoff is written; resolving to 1 or 2 MUST NOT ask. You MUST create any missing parent directories.
- **Where the host already keeps live work-state documents, you MUST update them and write the handoff as a pointer to them** — the current state, blockers, and next action stated once, in the host's documents, and referenced here. A handoff that copies them creates a second claim on the same facts, and the copy the successor reads is the one that has already gone stale.
- If the host declares an `isolation` unit and the work is sitting inside one (a worktree, a branch checkout), you MUST return the work to the mainline before handing off — merged or pushed as the host requires. A successor handed work stranded in an isolated workspace cannot see it.
- After writing, you MUST report the file's path to the user.

## Writing Rules

- **Zero-context test.** Read the draft as someone with no access to this conversation. You MUST NOT reference the conversation itself ("as discussed above", "the approach we agreed on", "see my earlier message") — restate the substance or point to an artifact.
- **Compact.** The successor loads this document whole. Keep it as short as completeness allows; the artifact index is what keeps it short.
- **Facts over narrative.** Record decisions and their reasons, not the journey that produced them.

## Red Flags — STOP

- You are writing a handoff and the user never asked for one
- A "done" item with no cited evidence
- File contents, diffs, or plan text pasted into the handoff instead of referenced by path
- Any sentence that only makes sense with the conversation open
- No Suggested skills section, or no Constraints section
- A secret, token, or personal detail in the draft

## Rationalizations — Rejected

| Excuse | Reality |
|--------|---------|
| "Context is running low — I'll compact proactively" | Not your call. Suggest it in one sentence; write it ONLY when the user asks. |
| "Pasting the plan in is easier than referencing it" | The copy goes stale the moment the plan changes, and the doc stops fitting in one load. Reference by path. |
| "The next agent will figure out which skills to use" | It won't — triggers don't cross the session boundary. The Suggested skills section is REQUIRED. |
| "It's basically done; evidence is overkill" | An unverified "done" is exactly what strands the successor. Cite what you observed, or label it unverified. |
| "No secrets in this session, skip the scan" | The scan is how you know that. Redaction runs before every write, without exception. |

## The Bottom Line

A handoff succeeds only if a zero-context agent can resume from it alone. User-initiated, evidence-cited, pointer-not-copy, redacted — or it is not a handoff, it is a liability on disk.
