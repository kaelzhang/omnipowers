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
  when the scenario is **specific** AND has **exactly one correct answer**.
- **RECOMMENDATION** → `SHOULD` / `SHOULD NOT` / `RECOMMENDED`. Use when the
  principle applies but the right response **varies by situation**, or the domain
  has **no single standard answer**.
- **DISCRETIONARY** → `MAY` / `OPTIONAL`. Genuinely free choice.

**Default bias: MANDATORY.** When a statement meets "specific scenario + single
correct answer", it MUST be written as `MUST` / `MUST NOT` and MUST NOT be
softened to `SHOULD` / "consider" / "try to". Reserve `SHOULD` / `MAY` for real
judgment, not politeness.

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
  the rationalization and red-flag tables. Load-bearing discipline MUST stay
  inline — it MUST NOT be hidden behind a reference an agent could skip.
- **Move to a same-directory supporting file** — content needed only in a
  **specific sub-case**, or **heavy reference**: a deep technique used in a
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
live inside the host project (under `.omnipowers/`), and any self-improvement loop
a skill defines MUST be self-contained and gated by the host project's user.

`.omnipowers/` holds the skill's own **runtime state**. A human-facing project
document a skill creates for the host's team (a domain glossary, ADRs) MAY
instead live at the host's conventional location (project root, `docs/`) — with
the user's consent on first creation, since the skill is writing into space the
user owns.

Host-artifact dependencies split hard vs soft: a skill whose output is
**incorrect** without a host artifact MUST state how to bootstrap that artifact;
a skill that merely **sharpens** with one MUST NOT carry a bootstrap pointer or
nag about its absence — consumers proceed silently.

### Vocabulary

Use these terms exactly; the _Avoid_ list prevents synonym drift.

- **skill** — one directory under `skills/` with a `SKILL.md`. _Avoid_: power, command, plugin.
- **supporting file** — a same-directory file loaded via a conditional `@`-pointer. _Avoid_: sub-skill, attachment, resource.
- **host project** — the downstream project a skill is installed into. _Avoid_: client project, target repo, downstream (bare).
- **collection** — this repository's shipped set of skills. _Avoid_: library, suite, framework.
- **description** — the frontmatter trigger line. _Avoid_: summary, blurb.

### Authoring & review checklist

For each statement in a skill:

- [ ] Normative? Then it carries a BCP 14 keyword.
- [ ] Invocation surface classified: guardrail → model-invoked; heavyweight orchestrator / outward side effects → explicit-invocation-only description.
- [ ] Specific scenario + single correct answer → `MUST` / `MUST NOT`.
- [ ] Genuine judgment / no standard answer → `SHOULD` / `MAY`, and say why it varies.
- [ ] No softening of a real rule ("consider", "try to", "it's good practice").
- [ ] Every MANDATORY rule states the consequence of violating it.
- [ ] Any exception uses the one-escape shape above.
- [ ] Self-contained: carries the BCP 14 note; no reference outside this repo.
- [ ] Progressive disclosure: every-invocation discipline stays inline; situational or heavy reference (>~100 lines, or used in a minority of runs) is a same-directory supporting file reached by a conditional `@`-pointer.
- [ ] Portable at runtime: works in any host project; no dependency on this repo's tooling; runtime state stays under the host project's `.omnipowers/`.
