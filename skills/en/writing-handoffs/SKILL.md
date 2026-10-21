---
name: writing-handoffs
description: Use only when the user explicitly asks to hand off or compact this session for another agent ("handoff", "continuation/resume doc", "写交接文档") — you MUST produce a handoff document a zero-context agent can resume from, and MUST NOT fire without that explicit request
---

# Writing Handoffs

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- When writing a handoff → you MUST make the handoff and its referenced artifacts sufficient for an agent with zero access to this conversation to continue the work.

## User-Initiated Only

- Without an explicit user request to hand off or compact the session → this skill MUST NOT fire on your own initiative.
- You believe a handoff would help → you MAY say so in one sentence.
- Until the user asks for a handoff → you MUST NOT write the document.

## Scope — Purpose-Tailored

- The user states what the next session is for → the handoff MUST be scoped to that purpose: full detail for it, at most a one-line pointer for unrelated open threads.
- No purpose is stated → the handoff MUST cover **all** open work in the session.

## Required Sections

When writing the document → you MUST include all of the following sections, in this order, with the specified content:

1. **Goal** — what the work is trying to achieve, and the definition of done.
   - When reading Goal alone → the successor MUST be able to tell when to stop.
2. **Current state — with evidence** — what is done and what is in progress.
   - For every "done" claim → you MUST cite the verification you actually observed (the test command and its result, the review outcome, the command output).
   - For a claim you did not verify → you MUST label it unverified.
3. **Artifact index** — every spec, plan, commit, diff, and file the work touches or depends on, referenced **by path, commit hash, or identifier**, with at most one line of relevance per entry.
   - When writing the handoff → you MUST NOT duplicate an artifact's content into it.
4. **Next steps** — concrete, ordered actions.
   - For each step → you MUST make it specific enough to start without re-deriving the analysis.
5. **Open questions / blockers** — every unresolved decision, missing input, and external blocker; "none" explicitly when there are none.
6. **Suggested skills** — skills for the successor agent to invoke and their purposes.
   - When resuming the work → the successor agent SHOULD invoke the suggested skills for their stated purposes.
   - When writing the handoff → the Suggested skills section is REQUIRED.
7. **Constraints** — every rule that binds the work: user preferences stated this session, project rules, locked decisions, things explicitly ruled out.

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

Before writing the file → you MUST scan the material for secrets, credentials, API keys, tokens, connection strings, and PII, and redact each occurrence without exception.

## Location

- Handoff location — the `work-state` location resolved per `using-omnipowers`, with fallback `.omnipowers/handoffs/YYYY-MM-DD-<purpose>.md`, where `<purpose>` is a short kebab-case slug.
- Handoff in an isolated workspace — a handoff written after the return to mainline governed by `using-git-worktrees`.
- The host already keeps live work-state documents → you MUST update them and write the handoff as a pointer to them: the current state, blockers, and next action stated once, in the host's documents, and referenced here.
- After writing the handoff → you MUST report the file's path to the user.

## Writing Rules

- When writing the handoff → you MUST NOT reference the conversation itself ("as discussed above", "the approach we agreed on", "see my earlier message"); restate the substance or point to an artifact.

## Rationalizations — Rejected

| Excuse | Reality |
|--------|---------|
| "The next agent will figure out which skills to use" | The Suggested skills section is REQUIRED. |
