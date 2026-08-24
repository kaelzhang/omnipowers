# AGENTS.md — omnipowers

Agent and contributor entrypoint for the omnipowers repository: a collection of
normative skills that improve coding effectiveness for AI coding agents.

This file governs how skills in this repo are **authored and structured**. Any
agent that adds or modifies a skill MUST follow the Skill authoring standard
below. To install the skills, see `README.md`. For how an agent discovers and
applies a skill at runtime, see `skills/using-omnipowers/SKILL.md`.

## Repository layout

- `skills/<name>/SKILL.md` — one self-contained skill per directory; the
  frontmatter `name` MUST match the directory name.
- `skills/<name>/*.md` — supporting files for that skill, included from its
  `SKILL.md` by same-directory reference only (e.g. `@testing-anti-patterns.md`).
- `README.md` — what the collection is and how to install it.
- `Makefile`, `scripts/` — install / dev tooling.
- `FITNESS.md` — the periodic skill-fitness review: measurements and keep/simplify/merge/retire rules.
- `LICENSE` — MIT.

## Skill authoring standard

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD
> NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC
> 8174), and only when capitalized.

### Skills are normative, not advisory

A skill exists to remove discretion where discretion is harmful. The majority of
a skill's content MUST be a hard requirement, not a suggestion. Prose that reads
as "mild" or "balanced" where a firm rule applies is a defect: it invites the
agent to rationalize its way out of the rule.

Constrain the **process**, never the **output**: a skill makes the agent run the
same process every time, not produce the same result every time. A divergent
skill (brainstorming, prototyping) must predictably *diverge* — over-constraining
its output defeats it as surely as under-constraining its process.

### Classify every normative statement before writing it

- **MANDATORY** → `MUST` / `MUST NOT` / `REQUIRED` / `SHALL` / `SHALL NOT`. Use
  when the operation is **fragile** — the scenario is specific, exactly one
  answer is correct, and deviation causes concrete damage — AND the rule
  corresponds to a **nameable failure mode**: one you observed, or one you can
  concretely argue an agent commits under pressure.
- **RECOMMENDATION** → `SHOULD` / `SHOULD NOT` / `RECOMMENDED`. Use when the
  principle applies but the right response **varies by situation**, or the domain
  has **no single standard answer**.
- **DISCRETIONARY** → `MAY` / `OPTIONAL`. Genuinely free choice.

**Bias: match force to fragility, and MUSTs are failure-driven.** Where an
operation is fragile and one answer is correct, write `MUST` / `MUST NOT` and
never soften it to "consider" / "try to". Where the model's own judgment is
reliable — calibration, style, weighing context — leave freedom: a `MUST` with
no nameable failure mode is a defect, not rigor. It spends the reader's limited
compliance budget, fights the model's improving judgment, and trains the agent
to rationalize around the MUSTs that matter. Instruction-following degrades
measurably as the number of simultaneous hard constraints grows — every
unearned MUST taxes every earned one.

### Style: condition + command

Write rules, not arguments. Each normative statement MUST be a condition and the
command it triggers, and nothing else.

- MUST NOT: persuasion, justification, or any clause explaining why the rule is
  right ("because…", "this is how…", "which is why…").
- MUST NOT: illustrative examples, worked scenarios, or sample dialogue. A format
  the reader must reproduce exactly MAY be shown as a template.
- MUST NOT: restating a rule for emphasis.
- MAY: one clause naming the consequence, only where the consequence changes what
  the reader does. Where it only motivates, cut it.

The reader is an agent that will comply once instructed. Prose spent convincing
it is paid for on every invocation and buys nothing.

### BCP 14 keyword convention

Every skill MUST express normative force with the BCP 14 keywords, and MUST carry
a one-line BCP 14 interpretation note so it is self-contained when loaded alone.

### The exception pattern — one auditable escape

A MANDATORY rule MAY define exactly one escape hatch, and only when a specific,
narrow situation genuinely prevents compliance. The escape MUST itself be
mandatory and auditable — never a soft "if you can't, skip it". Canonical shape:

> `MAY <skip> ONLY when <condition>`, gated by a `MUST` checklist + explicit user
> permission + a durable record (e.g. a code comment).

Worked example (`test-driven-bug-fixing`): the reproducing test is REQUIRED; it
MAY be skipped ONLY when reproduction is genuinely impossible, and only after the
agent (1) summarizes the complete reasons, (2) obtains the user's explicit
permission, and (3) adds an explanatory comment in the relevant production code.

### Self-contained

Each skill MUST stand alone: it depends on nothing outside its own directory. No
reference to anything outside this repo, no cross-skill prefixed includes;
supporting files live in the skill's own directory and are referenced from its
`SKILL.md` only (e.g. `@testing-anti-patterns.md`). Self-contained means
directory-local — it does NOT mean single-file (see Progressive disclosure).

### Progressive disclosure — inline vs. supporting file

A host loads a skill's `SKILL.md` into context every time the skill fires, but
loads a supporting file only when the `SKILL.md` directs the agent to read it —
so a supporting file costs no context until it is needed. Split a skill's content
by **load frequency**:

- **Inline in `SKILL.md`** — everything the agent needs on **every** invocation:
  the rules (`MUST` / `MUST NOT`), the Iron Law, the core workflow, the triggers,
  and the red-flag conditions. Load-bearing discipline MUST stay
  inline — it MUST NOT be hidden behind a reference an agent could skip.
- **Move to a same-directory supporting file** — content needed only in a
  **specific sub-case**, or **heavy reference**, including a table that merely
  elaborates a red-flag condition already stated inline: a deep technique used in a
  minority of runs, a long worked example, a large lookup table, a reusable
  tool/script. Reference it at the relevant point with a **conditional pointer**
  ("when `<situation>`, read `@<file>.md` and apply it") so the agent loads it
  exactly when it applies.

Heuristic: a block over ~100 lines, or one needed in only a fraction of the
skill's invocations, SHOULD be a supporting file; the discipline that must never
be missed stays inline. When in doubt, ask "does the agent need this on every
run?" — yes → inline; only sometimes → supporting file.

The pointer's **wording**, not its target, decides whether the disclosed
material is ever reached: a vague pointer ("more detail in X") gets skipped; a
conditional imperative ("when `<situation>`, read `@<file>.md` and apply it")
fires. A supporting file that never gets loaded is a disclosure failure — fix
the pointer, do not reflexively inline the content back.

### Portable at runtime

omnipowers is a skills library that OTHER projects install. A skill MUST run the
same inside any project it is installed into. At runtime a skill MUST NOT depend
on this repository or on its dev / test / optimize tooling (the `Makefile`, the
install scripts, any eval or optimization harness, the test suite) or on any
service outside the host project — that tooling exists only to author and improve
the skills here and is not available downstream. Any state a skill needs MUST
live inside the host project, and any self-improvement loop a skill defines MUST
be self-contained and gated by the host project's user.

Host-artifact dependencies split hard vs soft: a skill whose output is
**incorrect** without a host artifact MUST state how to bootstrap that artifact;
a skill that merely **sharpens** with one MUST NOT carry a bootstrap pointer or
nag about its absence — consumers proceed silently.

### Host declaration — the skill decides what, the host decides where

A skill MUST NOT hardcode where its output lives. The skill owns the artifact's
**role**; the host project owns that role's **location**, its **write
authority**, and its **version-control convention**. A hardcoded path is correct
only in a project that has no conventions of its own; in every other project it
silently creates a second home for something the host already files somewhere,
and the two copies drift.

**The five roles.** This list is closed. A skill MUST classify each artifact it
produces as exactly one of these and MUST NOT invent a sixth:

| role | what it holds | lifetime |
|---|---|---|
| `design-docs` | approved designs, decision records, prototype verdicts, research worth keeping | durable — outlives the work |
| `work-state` | the plan, progress, blockers, next action, handoffs | in flight — dies with the work |
| `records` | one-off write-ups: audit reports, research process logs | archival; not consulted while working |
| `scratch` | throwaway: debug harnesses, captured diffs, resume caches | deleted when the work ends |
| `standards` | the source of the project's own criteria (review checklist, coding standards) | maintained by the host, never by a skill |

**Resolving a location.** Before writing any artifact a skill MUST resolve its
location in this order, stopping at the first that applies:

1. a location the user states in this session;
2. the host's `Omnipowers` declaration — a section by that name in the host's
   `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using the
   row for this artifact's role;
3. where the host already keeps documents of that role, when that is unambiguous;
4. the fallback the skill states.

Resolving to 3 or 4 MUST be confirmed with the user before the first write of
that role in that project, and their answer governs from then on. Resolving to 1
or 2 MUST NOT ask — the host has already answered.

**The declaration.** The host writes it once, as Markdown, inside a file its
agents already load. Never a new config file, and never a machine-readable
format an agent has to parse — the reader is a model, not a parser:

````markdown
## Omnipowers

| role | location |
|---|---|
| design-docs | docs/design/ |
| work-state  | tasks/<id>/ |
| records     | tasks/<id>/reviews/ |
| scratch     | .omnipowers/ (not version-controlled) |
| standards   | standards/ |

- write-authority: <who may write where; how to get authorization otherwise>
- vcs: <the host's commit, staging, and message convention>
- isolation: <the host's isolation unit; paths that MUST stay on the mainline>
````

Every row is OPTIONAL, and a host that declares nothing gets the fallbacks.

**The three policy axes** bind the same way, and a declared axis MUST override a
skill's own default:

- **write-authority** — the user's approval of an artifact's *content* is not by
  itself authority to write it *where the host does not permit*. Where the host
  declares an authority model, a skill MUST obtain authorization through it
  rather than writing directly.
- **vcs** — commit, staging, branch, and message conventions belong to the host.
  Git commands shown inside a skill are illustrative; a declared convention
  governs over them.
- **isolation** — the host names the unit work happens in, and the paths that
  MUST stay on the mainline instead of being copied into an isolated workspace.

**`.omnipowers/` is a workbench, not an archive.** It is the fallback home for
`work-state` and `scratch`, and nothing else. Durable artifacts MUST NOT
accumulate there: an agent-only directory has no entry point in the host's
documentation, so whatever is filed there is written and never read again.
Everything a skill leaves in the workbench MUST be promoted to a durable role or
deleted when the work finishes.

### Vocabulary

Use these terms exactly; the _Avoid_ list prevents synonym drift.

- **skill** — one directory under `skills/` with a `SKILL.md`. _Avoid_: power, command, plugin.
- **supporting file** — a same-directory file loaded via a conditional `@`-pointer. _Avoid_: sub-skill, attachment, resource.
- **host project** — the downstream project a skill is installed into. _Avoid_: client project, target repo, downstream (bare).
- **collection** — this repository's shipped set of skills. _Avoid_: library, suite, framework.
- **description** — the frontmatter trigger line. _Avoid_: summary, blurb.
- **role** — one of the five artifact classes a skill's output is filed under. _Avoid_: kind, category, bucket.
- **host declaration** — the host's `Omnipowers` section binding roles to locations and policy. _Avoid_: config, profile, manifest.
- **workbench** — `.omnipowers/`, the fallback home for in-flight and throwaway artifacts. _Avoid_: state dir, cache, archive.

### Authoring & review checklist

For each statement in a skill:

- [ ] Normative? Then it carries a BCP 14 keyword.
- [ ] Invocation surface classified: guardrail → model-invoked; heavyweight orchestrator / outward side effects → explicit-invocation-only description.
- [ ] Skill map synced: adding, renaming, removing, or re-scoping a skill updates `skills/using-omnipowers/skill-map.md` in the same change — a map that lies mis-routes worse than no map.
- [ ] Fragile operation + single correct answer + nameable failure mode → `MUST` / `MUST NOT`.
- [ ] Every `MUST` traces to a failure observed or concretely arguable; no nameable failure → downgrade to `SHOULD` or delete.
- [ ] Genuine judgment / no standard answer → `SHOULD` / `MAY`, and say why it varies.
- [ ] No softening of a real rule ("consider", "try to", "it's good practice").
- [ ] Condition + command only: no persuasion, no justification, no illustrative examples; a consequence appears only where it changes what the reader does.
- [ ] Any exception uses the one-escape shape above.
- [ ] Self-contained: carries the BCP 14 note; no reference outside this repo.
- [ ] Progressive disclosure: every-invocation discipline stays inline; situational or heavy reference (>~100 lines, or used in a minority of runs) is a same-directory supporting file reached by a conditional `@`-pointer.
- [ ] Portable at runtime: works in any host project; no dependency on this repo's tooling; all state stays inside the host project.
- [ ] No hardcoded home: every artifact declares one of the five roles and resolves its location through the host declaration, with the skill's own path stated only as the fallback.
- [ ] Policy deferred: any commit form, branch/isolation assumption, or write into host-owned space yields to a declared `vcs` / `isolation` / `write-authority` axis.
