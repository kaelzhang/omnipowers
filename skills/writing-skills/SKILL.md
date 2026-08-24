---
name: writing-skills
description: Use when creating, editing, writing, hardening, or verifying any skill (a SKILL.md) before deployment, when tuning a skill's description so it triggers/fires reliably, or when a skill keeps getting rationalized around — you MUST develop it test-first, watching an agent fail without it before you write a word
---

# Writing Skills

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

You MUST develop every skill through the RED → GREEN → REFACTOR cycle: watch an agent fail **without** the skill, write the skill that addresses exactly those failures, then close every loophole the agent finds under pressure.

The skill you produce MUST also satisfy these authoring invariants:

- **BCP 14 keywords.** Every normative statement MUST express its force with a BCP 14 keyword (MUST / MUST NOT / REQUIRED / SHALL / SHALL NOT / SHOULD / SHOULD NOT / RECOMMENDED / MAY / OPTIONAL), and the skill MUST carry the one-line BCP 14 interpretation note.
- **Failure-driven MANDATORY classification.** MUST / MUST NOT is reserved for fragile operations — a specific scenario, exactly one correct answer, AND a nameable failure mode (observed, or concretely arguable under pressure); such a rule MUST NOT be softened to "consider" / "try to". The model's own judgment is reliable → leave freedom. Genuine judgment → SHOULD / MAY, and say why it varies.
- **One auditable escape.** A MANDATORY rule MAY define at most one escape hatch, of the shape `MAY <skip> ONLY when <condition>`, gated by a MUST checklist plus explicit user permission plus a durable record (e.g. a code comment). Never a soft "if you can't, skip it".
- **Self-contained.** The skill MUST stand alone: no reference to anything outside the host project, and supporting files included by same-directory reference only.
- **Runtime-portable.** The skill MUST run the same in any host project, MUST NOT depend on any authoring/test/optimize tooling, and MUST keep any state it needs inside the host project.
- **No hardcoded home.** A skill decides *what* it produces, never *where* it lives. Every artifact MUST be classified as `design-docs`, `work-state`, `records`, `scratch`, or `standards`, and its location resolved in this order: what the user states, then the host's declared mapping, then the host's existing convention, then the skill's own fallback — stated as a fallback, never as the answer. The same yielding applies to the host's commit convention, its isolation unit, and its write-authority model.

This skill MUST NOT be used to justify shipping a skill that violates these invariants.

## When to Use

You MUST apply this skill whenever you:
- Create a new skill.
- Edit an existing skill.
- Verify a skill before deploying it.

You MUST NOT treat any of these as exempt from this skill or from its baseline requirement:
- "It's just a small addition."
- "It's just a documentation update."
- "It's just adding one section."
- "It's just an obvious rule."

### When to create a skill at all

You SHOULD create a skill when the technique is reusable beyond this one task and not intuitively obvious — weigh reuse, non-obviousness, and breadth together, no single one being dispositive.

You MUST NOT create a skill for:
- One-off solutions with no reuse.
- Project-specific conventions (those belong in the host project's instructions file).
- A constraint enforceable by regex, a linter, or validation — automate it instead; reserve skills for judgment calls.

**Splitting economics.** Split content into a new skill only when independent reach pays for the permanent context load of another model-invoked description in every session of every host project; discipline reachable only from inside one workflow belongs in that skill, inline or as a supporting file, not as a sibling.

### Classify the invocation surface first

Before writing a skill, classify who may invoke it:
- **Model-invoked (the default).** The agent reaches for it autonomously when the situation matches. Guardrail skills — disciplines that protect the user from the agent's own shortcuts — MUST be model-invoked.
- **Explicit-invocation-only.** A heavyweight orchestrator whose ceremony would bury ordinary tasks, or a skill with outward side effects (posting to public surfaces, persisting conversation content), SHOULD be gated to explicit user request: scope its description to the user's literal ask ("Use only when the user explicitly asks to …") and use the host's manual-only frontmatter where supported.

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

You MUST NOT write or edit a skill's content before you have run a baseline that demonstrates the failure the skill is meant to prevent. This applies to NEW skills AND to EDITS.

You wrote the skill before the baseline → you MUST delete it and start over:
- You MUST NOT keep the unverified draft "as reference".
- You MUST NOT "adapt" the draft while running the baseline.

**Violating the letter of this rule is violating its spirit.** "I'm following the spirit while skipping the baseline" is not an exception — run the baseline.

A baseline is not required in exactly one case: the skill is a **pure reference skill** with no rule to violate (see "Pure Reference Skills"). The skill states a rule an agent has any incentive to bypass → the baseline is REQUIRED.

## RED → GREEN → REFACTOR for Skills

### RED — Watch It Fail Without the Skill

You MUST run a realistic scenario against a fresh-context agent that does NOT have the skill, you MUST observe what it naturally does, and you MUST NOT skip this step.

Requirements:
- You MUST construct a scenario that genuinely tempts the failure (see "Writing Pressure Scenarios"); an academic prompt ("what does best practice say?") does not qualify.
- You MUST run a **no-skill control**. The control does not exhibit the failure → you MUST stop and not author the guidance.
- You MUST document the agent's choices and its rationalizations **verbatim** — the exact words, not a characterization.
- You SHOULD run 3 or more fresh-context samples; variance across samples tells you which failures are reliable.

**How to run the baseline:** The host environment provides subagents or parallel agents → you MAY dispatch each scenario to a fresh subagent. The host has no subagents → you MUST open a fresh-context session (a new conversation, a single one-shot API call, or a clean agent invocation) per scenario and run it manually. You MUST NOT skip the baseline because subagents are unavailable.

### GREEN — Write the Minimal Skill

You MUST write the skill so that it addresses the specific rationalizations you captured in RED — and only those. You MUST NOT pad the skill with counters for hypothetical failures you never observed.

Then you MUST re-run the same scenarios **with** the skill present. The agent MUST now comply.

The agent still fails → the skill is unclear or incomplete; you MUST revise and re-test. You MUST NOT declare success because the skill "reads correctly to you."

### REFACTOR — Close Every Loophole

The agent complies on the original scenario but finds a NEW rationalization under added pressure → you MUST close that loophole explicitly and re-test. You MUST repeat this cycle until no new rationalization appears.

For each new rationalization you MUST do all of:
1. Add an explicit negation to the rule, forbidding the specific workaround by name (see "Close Every Loophole Explicitly").
2. Add a row to the skill's rationalization table.
3. Add an entry to the skill's Red Flags list.
4. The rationalization is a symptom of being *about to* violate → add that symptom to the `description` trigger.

A skill is bulletproof when, under maximum pressure, the agent chooses the correct action, cites the skill's own sections as justification, and acknowledges the temptation but follows the rule anyway. It is NOT bulletproof while the agent still invents new rationalizations, argues the skill is wrong, or proposes "hybrid" approaches.

## Match the Form to the Failure

Before writing any guidance, you MUST classify the baseline failure, and you MUST choose the form from this table rather than reaching for a prohibition by default.

| Baseline failure | Form you MUST use | Form you MUST NOT use |
|---|---|---|
| Knows the rule, skips it under pressure | Prohibition + rationalization table + red flags | Soft guidance ("prefer", "consider") |
| Complies, but output has the wrong shape (bloated, buried, restated) | Positive recipe/contract: state what the output IS — its parts, in order | Prohibition list ("don't restate", "never narrate") |
| Omits a required element from something it already produces | Structural: a REQUIRED field or slot in the template it fills | Prose reminders near the template |
| Behavior should depend on a condition | Conditional keyed to an observable predicate ("if the brief exists, reference it") | Unconditional rule + exemption clauses |
| Ends a step early, declares done prematurely | A checkable AND exhaustive completion criterion the agent can test its state against | Prose reminders ("don't stop early", "be thorough") |

Two rules apply whichever form you pick:
- **No nuance clauses.** "Don't X unless it matters" is forbidden; a real exception MUST be its own conditional keyed to an observable predicate.
- **Exemption clauses don't scope.** Part of the output must be exempt → you MUST restructure so the rule cannot reach it, rather than exempting it in prose.

Four craft rules that raise any form's yield:
- **Artifact gates beat confirm gates.** Phrase a phase gate as "produce/paste the artifact" (the failing output, the file, the diff), not "confirm that you did X".
- **Lead with the positive model.** Open with one crisp definition of the desired end state before any MUST/MUST NOT machinery.
- **Name the center of gravity.** One step dominates outcome quality → say so explicitly ("this step IS the skill; the rest is mechanical").
- **Upgrade SHOULDs to decidable tests.** For every SHOULD, attempt an operational test that would make it a checkable MUST (the deletion test, the zero-context test); a SHOULD that survives is genuine judgment — say why it varies.

### Leading words

Anchor each skill on ONE compact, pretrained concept word (its *leading word*) and repeat that exact token at every load-bearing point: the description, the Iron Law, the section names. Within one skill, near-synonyms of the leading word MUST NOT be substituted for it; drift is likely → name the banned synonyms. Grade a candidate word with the micro-test protocol below.

### Pruning an existing skill

When editing an existing skill you MUST also prune:
- Delete any line the current model already does correctly without guidance, verified with a no-guidance control, not intuition.
- State each rule ONCE at its most load-bearing location within the skill; cross-SKILL repetition remains required by self-containment.
- Treat sediment as the default fate of guidance — a rule written for last year's model failure MAY no longer pay its context cost.

## Bulletproofing Against Rationalization

Discipline-enforcing skills MUST resist rationalization.

This toolkit applies ONLY to discipline failures (the agent knows the rule and skips it). The failure is wrong-shaped or omitted output → use "Match the Form to the Failure" instead.

### Close Every Loophole Explicitly

You MUST forbid specific workarounds by name, not just state the rule.

### State the Foundational Principle Early

You MUST include, near the top of any discipline skill, a line equivalent to: **"Violating the letter of the rule is violating its spirit."**

### Build the Rationalization Table

Every excuse the agent produced in RED and REFACTOR MUST appear in a two-column table that names the excuse and rejects it in concrete terms:

```markdown
| Excuse | Reality |
|--------|---------|
```

Each row MUST counter a *specific* observed rationalization, never a generic counter ("don't cheat").

### Create the Red Flags List

You MUST provide a self-check list so the agent can catch itself mid-rationalization.

### Persuasion Force

You MUST use authority and commitment framing (imperatives, forced explicit choices, required announcements) for discipline skills. You MUST NOT rely on liking or reciprocity ("it would help me if…").

## Writing Pressure Scenarios

You MUST build each scenario to these requirements:
- **Multiple pressures.** You MUST combine 3 or more of: time, sunk cost, authority, economic, exhaustion, social, pragmatic ("being pragmatic, not dogmatic").
- **Concrete forced choice.** You MUST present explicit options (A/B/C) and require the agent to pick and act — not "what should you do?" but "what do you do?".
- **Real specifics.** Concrete file paths, times, and consequences.
- **No free escape.** The agent MUST NOT be able to defer to "I'd ask the user" without choosing.

## Micro-Test the Wording First

Before committing to wording, you SHOULD verify the wording itself with cheap micro-tests:

1. Run one fresh-context sample per variant. System context = the realistic surrounding the guidance will live in (the full skill, not the line in isolation); user message = a task that tempts the failure.
2. Always include a no-guidance control. The control does not fail → stop; there is nothing to author.
3. Use 5 or more reps per variant.
4. You MUST read every flagged match by hand.
5. Treat variance as a metric. Reps diverge into different interpretations → the wording is not binding; tighten the form before adding words.

Micro-tests verify wording; they do NOT replace full pressure scenarios for discipline skills.

## Meta-Testing When GREEN Won't Hold

An agent reads the skill and still chooses wrong → you MUST ask it directly:

```markdown
You read the skill and chose the wrong option. How should the skill have been written to make the correct option unmistakable?
```

Its answer routes the fix:
- **"The skill was clear; I ignored it."** → strengthen the foundational principle ("violating the letter is violating the spirit").
- **"The skill should have said X."** → add X verbatim.
- **"I didn't see section Y."** → make the key point more prominent and move it earlier.

## Pure Reference Skills

A skill that only retrieves facts (API reference, command syntax, a lookup table) has no rule to violate → the baseline-failure cycle does not apply. For these you MUST still verify usefulness:
- A fresh-context agent MUST be able to find the right entry for a realistic question (retrieval test).
- It MUST be able to apply what it found correctly (application test).
- Common use cases MUST be covered (gap test).

You MUST NOT claim "pure reference" to skip the baseline for a skill that states any rule an agent has incentive to bypass.

## Anti-Patterns

You MUST NOT ship a skill containing any of these:

- **Narrative.** A story about one incident. State the rule and the technique directly.
- **Multi-language dilution.** Five mediocre examples in five languages. One excellent, complete, well-commented example in the most relevant language is REQUIRED instead.
- **Code inside flowcharts.** Flowcharts are for non-obvious decisions only. Code MUST live in fenced code blocks; reference material MUST be tables or lists; linear steps MUST be numbered lists.
- **Semantically empty labels.** Every label MUST carry meaning.

## STOP — Before Moving to the Next Skill

After writing or editing ANY skill, you MUST complete its full verification before starting another. You MUST NOT batch-create skills and test them later, MUST NOT move to the next skill before the current one is verified, and MUST NOT skip testing because "batching is more efficient."

## Skill Development Checklist

You MUST be able to check every applicable box before deploying the skill. Track each as a separate item.

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
- [ ] Updated the `description` with about-to-violate symptoms where relevant
- [ ] Re-tested until no new rationalization appeared

**Quality:**
- [ ] A flowchart appears only where a decision is genuinely non-obvious
- [ ] No narrative storytelling, no multi-language dilution, no code in flowcharts
- [ ] Supporting files used only for reusable tools or heavy reference

## Description Field — The Trigger

You MUST write the `description` as a normative trigger of the form **"Use when `<situation>` — you MUST `<core requirement>`"**, in third person.

You MUST NOT summarize the skill's workflow in the description. State only the triggering situation and the single core requirement; the body carries the process.

You MUST seed the trigger with the terms a future agent would actually search — the symptoms, error phrases, and synonyms that signal the skill applies.

Prune alongside seeding: keep **one trigger per distinct situation branch**, and collapse branches that merely restate each other in different words — synonym seeds within one branch stay; whole restated branches go. Front-load the skill's leading word. Two adjacent skills are chronically confused → add an explicit anti-routing clause to both descriptions, naming which skill governs the other branch.
