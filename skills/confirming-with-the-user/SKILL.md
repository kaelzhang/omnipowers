---
name: confirming-with-the-user
description: Use whenever you reach a point that needs the user's decision or sign-off — a design to approve, review findings or proposals, or a choice with trade-offs — you MUST present it as plain-language options with each option's impact and your recommendation, one decision at a time, in one consistent language
---

# Confirming With the User

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

When you reach a point where the user must decide or approve something, *how* you present it decides whether they can actually decide. A vague or jargon-laden hand-off forces the user to do your thinking for you. You MUST present every such confirmation as a clear, self-contained decision: plain language, concrete options, each option's impact, and your recommendation.

**Core principle:** The user MUST be able to decide from what you wrote alone — without re-deriving the context or decoding your jargon.

## When to Use

You MUST use this skill at any point that needs the user's decision or sign-off — not only during implementation. This includes:

- a **design or plan** you have produced and need approved before building;
- **review findings or proposals** — problems found, optimization proposals, or recommended changes from any review or audit;
- an **implementation choice** with real trade-offs (a library, an approach, a schema, a name);
- any **scope, branch, or blocker** decision the user owns.

A completed design awaiting sign-off, and a review's proposals, are exactly the cases this skill governs — not just mid-implementation choices.

## What You MUST Present

For each decision you MUST include the following (the example in item 3 applies as noted):

1. **Context, in plain language.** State the situation and why a decision is needed, in concrete terms the user can follow. You MUST NOT rely on internal codes, jargon, or unexplained references the user has to decode.
2. **The decision's object, shown in full.** When the decision is to approve, adopt, choose, or reject a concrete artifact — a change or diff, a proposal, a name, a plan, a set of findings — you MUST reproduce that artifact in full and in plain language inside the confirmation itself. You MUST NOT refer to it only by a number, label, filename, or "the X above" that the user would have to scroll back, reopen, or decode. If it was produced in another language, in code, or in jargon, you MUST restate it in the user's language so the user can judge it from this message alone.
3. **A concrete example, when the impact is not obvious.** You MUST include a concrete example (a real case, a sample input/output, a before/after) whenever an option's impact is not self-evident, so the impact is tangible rather than abstract. For a decision whose impact is already obvious on its face — a simple binary sign-off, for instance — an example is OPTIONAL; you MUST NOT pad such a decision with a degenerate example.
4. **The options.** You MUST lay out the distinct options as a short, clearly separated, labelled list. Each option MUST be a real, actionable choice.
5. **Each option's impact.** For every option you MUST state what it changes — its cost, risk, trade-off, or consequence — and how it differs from the others. An option with no stated impact is not a real option.
6. **Your recommendation.** You MUST state which option you recommend and why, in one or two sentences.

## How You MUST Present It

- **One language — the user's.** You MUST write the whole confirmation in the language the user is writing to you in. You MUST NOT switch languages mid-explanation in a way that impedes understanding; mixing languages for ordinary words is not allowed.
- **Plain language.** You MUST explain in accessible terms. If a term is unavoidable, you MUST define it in passing the first time you use it.
- **One decision at a time.** You MUST NOT bundle several independent decisions into one tangled question. If there are several, present the most important first, or enumerate them so each item has its own options and recommendation.
- **Make responding trivial.** You MUST label the options (A / B / C or 1 / 2 / 3) so the user can answer with a single word or short phrase.

## Template

```
<Decision title — one line>

Background: <what is going on, in plain language, and the concrete reason a decision is needed>

What you're deciding on: <the actual artifact — the change, proposal, findings, or name — reproduced in full and in plain language; omit only when the decision has no concrete object>

Example: <a specific case that makes the impact tangible>

Options:
  A) <option> — Impact: <cost / risk / trade-off / consequence>
  B) <option> — Impact: <...>
  C) <option> — Impact: <...>

Recommendation: <which one, and why, in 1-2 sentences>
```

## Red Flags — STOP

You are presenting a decision badly if any of these is true:

- you ask "what do you want?" with no options and no recommendation;
- an option has no stated impact;
- you give a recommendation with no options, or options with no recommendation;
- the user would have to re-read earlier context, open files, or decode jargon/codes to understand the choice;
- you named the thing being decided only by a number, label, or filename — or "the X above" — instead of restating its content in this message;
- you switched languages mid-explanation;
- you piled multiple unrelated decisions into one question;
- an option's impact is not obvious and you gave no concrete example to anchor it.

## The Bottom Line

A confirmation that omits any element required above forces the user to do your work — re-deriving context, decoding jargon, or inventing the options you failed to lay out.
