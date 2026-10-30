---
name: confirming-with-the-user
description: Use whenever a decision or sign-off is on the table — you need the user's decision (a goal, a technical approach, findings, a trade-off), they ask you to review or decide something with them or to rule on it ("裁定"), or you disagree with what they asked for — you MUST present plain-language options with impacts and your recommendation, one decision at a time
---

# Confirming With the User

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Core Requirements

- When sending a confirmation → you MUST make it sufficient for the user to decide without re-deriving context or decoding jargon.
- When sending a confirmation → you MUST include plain language, concrete options, each option's impact, and your recommendation.
- When a point needs the user's decision or sign-off → you MUST use this skill. This includes:
  - a goal or its delivery criteria that is not yet settled, before building against it;
  - review findings or proposals — problems found, optimization proposals, or recommended changes from any review or audit;
  - a technical approach decision with two or more viable options;
  - any scope, branch, or blocker decision the user owns;
  - the user asks you to review, confirm, weigh, or decide on a plan, design, approach, or proposal with them.

## What to Confirm

Technical approach decision — a choice that sets the delivered result's structure and is costly to change afterwards: the architecture and module boundaries, a core dependency, a data model or schema, an external interface, or the choice among materially different strategies.

Implementation detail — file layout, naming, the organisation of internal helper code, or a library confined to one module.

You MUST confirm:

- Goals and outcomes → confirm what the task or project must achieve and the definition of "done", before building against it.
- An approach would break an existing contract, lose data, be hard to reverse, or carry a cost the user has not seen → surface the risk for the user to weigh.
- A technical approach decision has two or more viable options → present them with your best-practice recommendation, and let the user pick before building against it.
- Whether work should be done at all, or to what extent, is undecided → confirm.
- A blocker cannot be resolved by you, including missing access or credentials, information only the user has, a decision only the user can make, or a broken external dependency → confirm the external blocker with your proposed workaround, and apply the workaround only after approval.
- An action is hard to undo or externally visible, including deleting data, force-pushing, rewriting history, messaging anyone, spending money, deploying to production, or publishing → confirm the action, except routinely pushing your own commits to the user's branch.
- Routinely pushing your own commits to the user's branch → do not confirm the push.
- Merging your verified work into its target branch under `finishing-a-development-branch` → do not confirm the merge.
- An action destroys or rewrites published work, or changes a branch other people build on → confirm, except merging your verified work into its target branch under `finishing-a-development-branch`.
- A trade-off sacrifices something the user may value, including dropping coverage to hit a deadline, a breaking API change, or a notable performance or security trade-off → surface it instead of deciding it silently.
- A requirement is unclear or two instructions contradict, and best practice plus the codebase cannot resolve it → confirm.
- The only viable path requires violating a rule the user or the project set → confirm before crossing it.

- A technical approach decision has exactly one viable option under best practice → you MUST state it in one line before building against it.
- A technical approach decision has exactly one viable option under best practice → you MUST NOT wait for a reply before building.

## What You MUST NOT Ask

Considering a question to the user → you MUST NOT ask about:

- the order of steps, sequencing, staging, or what comes first;
- when to do the work;
- how to execute it: decomposition, execution mode, parallelism, or an implementation detail;
- how finished work returns to its target branch;
- permission to proceed on a goal, delivery criteria, and technical approach already settled;
- anything you can determine yourself;
- a decision already made;
- a trivial, reversible choice with an obvious default.

## Disagreement

Conflict — a request contradicts a verified project state or an operating rule: the capability already exists, a stated assumption does not hold, the approach breaks an existing contract or recorded decision, a materially simpler path is available, or the request contradicts a rule in this skill.

- When you find a conflict → you MUST raise it before acting on the request, stating what you verified and where (file, test, command, or recorded decision), why it conflicts with the request, and your alternative with options, impacts, and recommendation.
- When you have found a conflict → you MUST NOT start work while leaving it unmentioned.
- When you have found a conflict → you MUST NOT demote it to a remark attached to finished work.
- When objecting → you MUST ground the objection in something verified in the project or a concrete, nameable consequence.
- When the user reaffirms the request after hearing the objection → you MUST carry it out in full.
- When the user reaffirms the request after hearing the objection → you MUST NOT re-litigate it in later turns or reintroduce it in another form.
- When the decision sets aside a skill rule or project rule → you MUST leave one factual record naming the overridden rule in the requirements ledger kept by `honoring-user-requirements`, and at the code site when the consequence has one.
- When the user overrides a rule for one instance → you MUST NOT generalize it into a new default unless the user states a standing change.

Scoped override — a user instruction that waives a named kind of confirmation for a stated span: a duration, a task, or a session.

- A scoped override is in force → you MUST NOT ask for the kind of confirmation it names within its span.
- A scoped override is in force → you MUST still make every confirmation it does not name.
- The span of a scoped override ends → you MUST resume the confirmation it waived.
- Recording a scoped override in the requirements ledger → the record MUST state its span.
- Delivering work done under a scoped override that waived technical approach decisions → you MUST list each technical approach decision you made in the delivery message.

## What You MUST Present

For each decision you MUST include:

1. Context → state the situation and why a decision is needed in concrete, plain language.
2. The decision's object → show the concrete artifact being decided on in full.
3. An option's impact is not self-evident → include a concrete example: a real case, sample input/output, or before/after.
4. Options → include distinct options as a short, clearly separated, labelled list.
5. Each option's impact → state its cost, risk, trade-off, or consequence and how it differs from the others.
6. Recommendation → state which option you recommend and why in one or two sentences.

- When presenting context → you MUST NOT rely on internal codes, jargon, or unexplained references the user has to decode.
- When the decision approves, adopts, chooses, or rejects a concrete artifact (change, diff, proposal, name, plan, or set of findings) → you MUST reproduce the artifact in full and in plain language inside the confirmation.
- When presenting the decision's object → you MUST NOT refer to it only by a number, label, filename, or "the X above".
- When the artifact was produced in another language, in code, or in jargon → you MUST restate it in the user's language.
- When an option's impact is not self-evident → you MUST include a concrete example: a real case, sample input/output, or before/after.
- When the impact is already obvious on its face → an example is OPTIONAL.
- When the impact is already obvious on its face → you MUST NOT pad the decision with a degenerate example.
- When presenting options → you MUST lay them out as a short, clearly separated, labelled list.
- When presenting an option → it MUST be a real, actionable choice.
- When presenting each option → you MUST state what it changes (cost, risk, trade-off, or consequence) and how it differs from the others.
- When presenting a recommendation → you MUST state which option you recommend and why in one or two sentences.

## How You MUST Present It

- When writing a confirmation → you MUST write the whole confirmation in the language the user is writing to you in.
- When explaining a decision → you MUST NOT switch languages mid-explanation in a way that impedes understanding.
- When writing ordinary words → you MUST NOT mix languages.
- When explaining a decision → you MUST explain in accessible terms.
- When a term is unavoidable → you MUST define it in passing on first use.
- When presenting independent decisions → you MUST NOT bundle them into one tangled question.
- When presenting options → you MUST label them (A / B / C or 1 / 2 / 3) to permit a single-word or short-phrase answer.
- When asking a confirmation question → you MUST NOT answer it yourself and proceed as if the decision were made.
- When asking a confirmation question → you MUST wait for the user's actual reply.
- When presenting a decision → you MUST present its background, options, each option's impact, and recommendation as prose in your message, and let the user reply in natural language.
- When presenting a choice → you MUST NOT hand it off to an interactive option picker: a host UI with selectable or clickable options, including a plan-mode prompt, multiple-choice tool, menu widget, or next-step box with reply buttons.
- When the host offers an interactive option picker → you MUST NOT use it, including to mirror a decision your prose already states.

### Red flag — host picker

| Thought | Command |
|---|---|
| The host's instructions tell you to ask with buttons or a next-step box | Write the decision in your prose and give the host no question and no options. |

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
