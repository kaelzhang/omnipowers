---
name: writing-skills
description: Use when creating, editing, writing, hardening, verifying, or cutting down any skill (a SKILL.md) — "大砍", "精简" — before deployment, when tuning a skill's description so it triggers/fires reliably, or when a skill keeps getting rationalized around — you MUST develop it test-first, watching an agent fail without it before you write a word
---

# Writing Skills

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- When developing a skill → you MUST follow RED → GREEN → REFACTOR: observe an agent fail without the skill, write guidance addressing exactly those failures, and close every loophole the agent finds under pressure.
- When producing a skill → the skill MUST satisfy the authoring invariants below.
- When writing a normative statement → it MUST express its force with a BCP 14 keyword.
- When producing a skill → the skill MUST carry the one-line BCP 14 interpretation note.
- Fragile operation — a specific scenario with exactly one correct answer and a nameable failure mode, observed or concretely arguable under pressure.
- MANDATORY classification — MUST / MUST NOT, reserved for fragile operations.
- When a rule governs a fragile operation → it MUST NOT be softened to "consider" / "try to".
- Genuine judgment classification — SHOULD / MAY, with the variation stated.
- When defining a MANDATORY rule → it MAY define at most one escape hatch of the shape `MAY <skip> ONLY when <condition>`, gated by a MUST checklist, explicit user permission, and a durable record.
- When producing a skill → it MUST stand alone, with no reference outside the host project and supporting files included by same-directory reference only.
- When producing a skill → it MUST run the same in any host project.
- At runtime → the skill MUST NOT depend on authoring/test/optimize tooling.
- When the skill needs state → it MUST keep that state inside the host project.
- When producing an artifact → it MUST be classified as `design-docs`, `work-state`, `records`, `scratch`, or `standards`, with its location resolved in this order: the user's stated location, the host's declared mapping, the host's existing convention, the skill's fallback stated as a fallback.
- When producing a skill → it MUST yield to the host’s commit convention, isolation unit, and write-authority model.
- When a skill violates these invariants → you MUST NOT use this skill to justify shipping it.

## Applicability

When creating a skill, editing a skill, or verifying a skill before deployment → you MUST apply this skill.

When considering any of these thoughts → you MUST NOT treat the task as exempt from this skill or its baseline requirement:
- "It's just a small addition."
- "It's just a documentation update."
- "It's just adding one section."
- "It's just an obvious rule."

### When to Create a Skill

- When the technique is reusable beyond this task and not intuitively obvious → you SHOULD create a skill, weighing reuse, non-obviousness, and breadth together without treating any one as dispositive.
- For a one-off solution with no reuse → you MUST NOT create a skill.
- For project-specific conventions → you MUST NOT create a skill.
- For a constraint enforceable by regex, a linter, or validation → you MUST NOT create a skill; automate it instead and reserve skills for judgment calls.

### Invocation Surface

- When authoring a guardrail skill protecting the user from the agent's shortcuts → the skill MUST be model-invoked.
- When authoring a heavyweight orchestrator whose ceremony would bury ordinary tasks, or a skill with outward side effects → it SHOULD be gated to explicit user request by scoping its description to the user's literal ask ("Use only when the user explicitly asks to …") and using the host's manual-only frontmatter where supported.

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

- Before writing or editing a skill's content → you MUST NOT proceed without a baseline demonstrating the failure the skill is meant to prevent, except for a pure reference skill.
- When you wrote the skill before the baseline → you MUST delete it and start over.
- When you wrote the skill before the baseline → you MUST NOT keep the unverified draft "as reference".
- When you wrote the skill before the baseline → you MUST NOT "adapt" the draft while running the baseline.
- Pure reference skill — a skill that only retrieves facts and has no rule to violate.
- When the skill states a rule an agent has any incentive to bypass → the baseline is REQUIRED.

## RED → GREEN → REFACTOR for Skills

### RED — Watch It Fail Without the Skill

- When running RED → you MUST run a realistic scenario against a fresh-context agent without the skill.
- When running RED → you MUST observe what the agent naturally does.
- When running RED → you MUST NOT skip this step.
- When constructing a baseline scenario → you MUST genuinely tempt the failure using Writing Pressure Scenarios.
- Academic prompt — a prompt asking what best practice says rather than tempting the failure; not a qualifying baseline scenario.
- When running RED → you MUST run a no-skill control.
- When the control does not exhibit the failure → you MUST stop and not author the guidance.
- When running RED → you MUST document the agent's choices and rationalizations verbatim.
- When running RED → you SHOULD run 3 or more fresh-context samples.
- When the host environment provides subagents or parallel agents → you MAY dispatch each scenario to a fresh subagent.
- When the host has no subagents → you MUST open a fresh-context session per scenario and run it manually.
- When subagents are unavailable → you MUST NOT skip the baseline.

### GREEN — Write the Minimal Skill

- When writing GREEN guidance → you MUST address only the specific rationalizations captured in RED.
- When writing GREEN guidance → you MUST NOT add counters for hypothetical failures you never observed.
- After writing the skill → you MUST re-run the same scenarios with the skill present.
- When re-running those scenarios with the skill → the agent MUST comply.
- When the agent still fails → you MUST revise and re-test the skill.
- When the skill "reads correctly to you" → you MUST NOT declare success on that basis.

### REFACTOR — Close Every Loophole

- When the agent complies on the original scenario but finds a new rationalization under added pressure → you MUST close that loophole explicitly and re-test.
- When new rationalizations appear → you MUST repeat this cycle until none appears.

For each new rationalization → you MUST:
1. Add an explicit negation to the rule, forbidding the specific workaround by name.
2. Add a row to the skill's rationalization table.
3. Add an entry to the skill's Red Flags list.
4. When the rationalization is a symptom of being about to violate → add that symptom to the `description` trigger.

## Match the Form to the Failure

- Before writing guidance → you MUST classify the baseline failure.
- Before writing guidance → you MUST choose its form from this table rather than defaulting to a prohibition.
- For each baseline failure in the table → you MUST use the specified form.
- For each baseline failure in the table → you MUST NOT use the prohibited form.

| Baseline failure | Specified form | Prohibited form |
|---|---|---|
| Knows the rule, skips it under pressure | Prohibition + rationalization table + red flags | Soft guidance ("prefer", "consider") |
| Complies, but output has the wrong shape (bloated, buried, restated) | Positive recipe/contract: state what the output IS — its parts, in order | Prohibition list ("don't restate", "never narrate") |
| Omits a required element from something it already produces | Structural: a REQUIRED field or slot in the template it fills | Prose reminders near the template |
| Behavior should depend on a condition | Conditional keyed to an observable predicate ("if the brief exists, reference it") | Unconditional rule + exemption clauses |
| Ends a step early, declares done prematurely | A checkable AND exhaustive completion criterion the agent can test its state against | Prose reminders ("don't stop early", "be thorough") |

- When defining an exception → it MUST be its own conditional keyed to an observable predicate.
- When part of the output must be exempt → you MUST restructure the rule to exclude that part from its scope rather than exempting it in prose.

### Leading Words

- Leading word — the skill's compact, pretrained concept word.
- Within one skill → near-synonyms MUST NOT be substituted for the leading word.

### Pruning an Existing Skill

When editing an existing skill → you MUST also prune:
- Delete any line the current model already follows correctly without guidance, verified with a no-guidance control rather than intuition.
- State each rule once at its most load-bearing location within the skill, retaining cross-SKILL repetition for self-containment.
- Treat sediment as the default fate of guidance.

Potential sediment — a rule written for last year's model failure that MAY no longer pay its context cost.

## Bulletproofing Against Rationalization

- When authoring a discipline-enforcing skill → it MUST resist rationalization.
- Discipline failure — the agent knows the rule and skips it.

### Close Every Loophole Explicitly

When closing loopholes in a discipline skill → you MUST forbid specific workarounds by name rather than only stating the rule.

### State the Foundational Principle Early

When authoring a discipline skill → you MUST include near its top a line equivalent to **"Violating the letter of the rule is violating its spirit."**

### Build the Rationalization Table

When authoring a discipline skill → every excuse produced in RED and REFACTOR MUST appear in a two-column table naming the excuse and rejecting it in concrete terms:

```markdown
| Excuse | Reality |
|--------|---------|
```

When writing a discipline skill's rationalization-table row → it MUST counter a specific observed rationalization rather than a generic counter ("don't cheat").

### Create the Red Flags List

When authoring a discipline skill's rationalization defenses → you MUST provide a self-check list for detecting mid-rationalization thoughts.

### Persuasion Force

- When authoring a discipline skill → you MUST use authority and commitment framing: imperatives, forced explicit choices, and required announcements.
- When authoring a discipline skill → you MUST NOT rely on liking or reciprocity ("it would help me if…").

## Writing Pressure Scenarios

For each scenario → you MUST meet these requirements:
- For each scenario → you MUST combine 3 or more of time, sunk cost, authority, economic, exhaustion, social, and pragmatic ("being pragmatic, not dogmatic").
- For each scenario → you MUST present explicit options (A/B/C) and require the agent to pick and act ("what do you do?").
- Include concrete file paths, times, and consequences.
- In each scenario → the agent MUST NOT be able to defer to "I'd ask the user" without choosing.

## Micro-Test the Wording First

Before committing to wording → you SHOULD verify the wording with cheap micro-tests:
1. Run one fresh-context sample per variant, with the full skill as realistic surrounding system context and a user task that tempts the failure.
2. Include a no-guidance control; when the control does not fail, stop.
3. Use 5 or more reps per variant.
4. Treat variance as a metric; when reps diverge into different interpretations, tighten the form before adding words.

When micro-testing wording → you MUST read every flagged match by hand.

## Meta-Testing When GREEN Won't Hold

When an agent reads the skill and still chooses wrong → you MUST ask it directly:

```markdown
You read the skill and chose the wrong option. How should the skill have been written to make the correct option unmistakable?
```

## Pure Reference Skills

When a skill only retrieves facts and has no rule to violate → you MUST still verify usefulness:
- In the retrieval test → a fresh-context agent MUST be able to find the right entry for a realistic question.
- In the application test → the agent MUST be able to apply what it found correctly.
- In the gap test → common use cases MUST be covered.
- When a skill states any rule an agent has incentive to bypass → you MUST NOT claim "pure reference" to skip the baseline.

## Anti-Patterns

When shipping a skill → you MUST NOT include:
- Narrative storytelling about one incident.
- Multi-language dilution: five mediocre examples in five languages.
- Code inside flowcharts.
- Semantically empty labels.

- When replacing multi-language dilution → one excellent, complete, well-commented example in the most relevant language is REQUIRED instead.
- When including code → it MUST live in fenced code blocks.
- When including reference material → it MUST be tables or lists.
- When including linear steps → they MUST be numbered lists.
- When writing a label → it MUST carry meaning.

## STOP — Before Moving to the Next Skill

- After writing or editing a skill → you MUST complete its full verification before starting another.
- When writing or editing skills → you MUST NOT batch-create them and test them later.
- Before the current skill is verified → you MUST NOT move to the next skill.
- When considering "batching is more efficient" → you MUST NOT skip testing.

## Skill Development Checklist

Before deploying the skill → you MUST be able to check every applicable box:

**RED — Watch It Fail:**
- [ ] Built scenarios that genuinely tempt the failure (3+ combined pressures for discipline skills)
- [ ] Ran the no-skill control; confirmed the failure actually occurs
- [ ] Documented the agent's rationalizations verbatim

**GREEN — Write the Minimal Skill:**
- [ ] Conforms to the authoring invariants in Overview (BCP 14 keywords, MANDATORY-by-default, one-escape exceptions, self-contained, runtime-portable)
- [ ] `name` matches the directory name exactly
- [ ] `description` is a normative "Use when … — you MUST …" trigger with concrete symptoms, in third person, with no workflow summary
- [ ] Guidance form matches the failure type (see Match the Form to the Failure)
- [ ] Addresses the specific baseline failures — no padding for unobserved cases
- [ ] One excellent example, inline (not multi-language)
- [ ] Re-ran scenarios WITH the skill; the agent now complies

**REFACTOR — Close Loopholes:**
- [ ] Captured every NEW rationalization verbatim
- [ ] Added an explicit negation, a rationalization-table row, and a red-flag entry for each
- [ ] Updated the `description` with each new rationalization that is a symptom of being about to violate
- [ ] Re-tested until no new rationalization appeared

**Quality:**
- [ ] A flowchart appears only where a decision is genuinely non-obvious
- [ ] No narrative storytelling, no multi-language dilution, no code in flowcharts
- [ ] Supporting files used only for reusable tools or heavy reference

## Description Field — The Trigger

- When writing the `description` → you MUST use a normative trigger of the form **"Use when `<situation>` — you MUST `<core requirement>`"**, in third person.
- When writing the description → you MUST NOT summarize the skill's workflow.
- When writing the trigger → you MUST seed it with the terms a future agent would search: symptoms, error phrases, and synonyms signaling that the skill applies.
