# AGENTS.md — omnipowers

Agent and contributor entrypoint for the omnipowers repository: a collection of
normative skills that improve coding effectiveness for AI coding agents.

This file governs how skills in this repo are **authored and structured**. Any
agent that adds or modifies a skill MUST follow the Skill authoring standard
below. To install the skills, see `README.md`. For how an agent discovers and
applies a skill at runtime, see `skills/en/using-omnipowers/SKILL.md`.

## Repository layout

- `skills/<locale>/<name>/SKILL.md` — one self-contained skill per directory; the
  frontmatter `name` MUST match the directory name. `<locale>` is `en` or `zh-CN`.
- `skills/<locale>/<name>/*.md` — supporting files for that skill, included from its
  `SKILL.md` by same-directory reference only (e.g. `@testing-anti-patterns.md`).
- `README.md`, `README.zh-CN.md` — what the collection is and how to install it.
- `Makefile`, `scripts/` — install / dev tooling.
- `FITNESS.md` — the periodic skill-fitness review: measurements and keep/simplify/merge/retire rules.
- `LICENSE` — MIT.

## Skill authoring standard

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD
> NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC
> 8174), and only when capitalized.

### Skills are normative, not advisory

- The majority of a skill's content MUST be hard requirements, not suggestions.
- A firm rule written as mild or balanced prose is a defect.
- **Scope of a skill** — a skill constrains the **process** the agent runs, never the **output** it produces. A divergent skill (brainstorming, prototyping) is one whose output varies by design.

### Throughput is a requirement

An obligation that does not change the outcome of an ordinary task is a defect.

- A rule demands a run, a read, a write, or a review → it MUST accept one already made on the same input in this session. `verification-before-completion` owns that acceptance; other skills point at it.
- A rule fires per action (per commit, per return, per task) → its cost MUST be proportional to the action.
- A skill produces a document → it MUST state when the work is too small for one, and what carries the record instead.
- A description MUST NOT instruct re-invocation at each recurring moment. `using-omnipowers` states once that a loaded skill governs for the session.
- A checklist is a self-check before a claim. It is not a task list and is not reported.
- Heavy material loads on a condition that is false on the ordinary task.

### Classify every normative statement before writing it

- **MANDATORY** — `MUST` / `MUST NOT` / `REQUIRED` / `SHALL` / `SHALL NOT`, for an operation that is **fragile** (the scenario is specific, exactly one answer is correct, and deviation causes concrete damage) AND that corresponds to a **nameable failure mode**: one observed, or one concretely arguable as committed under pressure.
- **RECOMMENDATION** — `SHOULD` / `SHOULD NOT` / `RECOMMENDED`, where the principle applies but the right response varies by situation, or the domain has no single standard answer.
- **DISCRETIONARY** — `MAY` / `OPTIONAL`, a free choice.
- **Softening** — writing a fragile, single-answer rule as "consider" or "try to". It is a defect.
- A `MUST` with no nameable failure mode is a defect.

### Style: rules only

A skill states rules. Every sentence in a skill MUST be exactly one of:

1. **A rule** — `<condition> → <command>`. The command carries a BCP 14 keyword stating its force. A rule that applies to less than the whole skill states its scope in the condition.
2. **A definition** a rule depends on — `<term> — <meaning>`, stated once.
3. **A template** the reader reproduces exactly.

Headings, the BCP 14 note, red-flag tables of `<thought> | <command>`, and conditional pointers of the form `<condition> → read @<file>.md and apply it` are structure, not sentences. A conditional pointer MUST keep that form.

- Every other sentence MUST be deleted: why a rule exists, what follows from breaking it, how it was found, examples, scenarios, emphasis, restatement.
- A condition MUST be checkable: a number, a named event, or a named state. "Large", "a few", "genuinely", "where appropriate" MUST NOT appear in a condition.
- A sentence MUST NOT carry two commands of different force; split it.
- An imperative step inherits a keyword only from a lead-in that carries the keyword and introduces that step: "You MUST:" above a list, or "You MUST complete it" naming the procedure the step belongs to. A complete sentence that merely precedes a list passes no keyword to it.

Rewriting into this style changes wording, never force:

- Every obligation in the result MUST trace to a keyword in the source, and every keyword in the source MUST survive.
- A source sentence with no keyword and no keyword-bearing lead-in MUST become a definition or be deleted. It MUST NOT be promoted to a rule.
- A keyword MUST NOT be added to a table header.

### BCP 14 keyword convention

Every skill MUST express normative force with the BCP 14 keywords, and MUST carry
a one-line BCP 14 interpretation note.

### The exception pattern — one auditable escape

A MANDATORY rule MAY define exactly one escape hatch, and only when a named situation prevents compliance. The escape MUST itself be mandatory and auditable. Canonical shape:

> `MAY <skip> ONLY when <condition>`, gated by a `MUST` checklist + explicit user
> permission + a durable record (a code comment).

### Self-contained

Each skill MUST stand alone: it depends on nothing outside its own directory — no reference outside this repo, no cross-skill prefixed includes. Supporting files live in the skill's own directory and are referenced from its `SKILL.md` only. **Self-contained** — directory-local, not single-file.

### Progressive disclosure — inline vs. supporting file

- **Inline in `SKILL.md`** — content the agent needs on every invocation: the rules, the Iron Law, the core workflow, the triggers, and the red-flag conditions. Load-bearing discipline MUST stay inline and MUST NOT be hidden behind a reference an agent could skip.
- **Supporting file** — content needed only in a specific sub-case, or heavy reference: a technique used in a minority of runs, a large lookup table, a reusable script, a table that elaborates a red-flag condition already stated inline. It is reached by a conditional pointer at the point it applies.
- A block over 100 lines, or one needed in a minority of the skill's invocations, SHOULD be a supporting file.
- **Conditional pointer** — `<condition> → read @<file>.md and apply it`. A pointer without a condition is a defect.
- **Disclosure failure** — a supporting file that is never loaded; it is a defect of its pointer, not of its placement.

### Portable at runtime

- A skill MUST run the same inside any host project.
- At runtime a skill MUST NOT depend on this repository or its dev, test, or optimize tooling (the `Makefile`, the install scripts, any eval or optimization harness, the test suite), or on any service outside the host project.
- Any state a skill needs MUST live inside the host project, and any self-improvement loop a skill defines MUST be self-contained and gated by the host project's user.
- A skill's output is incorrect without a host artifact → the skill MUST state how to bootstrap that artifact.
- A skill only sharpens with a host artifact → it MUST NOT carry a bootstrap pointer or remind the user of the artifact's absence.

### Host declaration — the skill decides what, the host decides where

A skill MUST NOT hardcode where its output lives. The skill owns the artifact's
**role**; the host project owns that role's **location**, its **write
authority**, and its **version-control convention**.

**The five roles.** This list is closed. A skill MUST classify each artifact it
produces as exactly one of these and MUST NOT invent a sixth:

| role | what it holds | lifetime |
|---|---|---|
| `design-docs` | approved designs, decision records, prototype verdicts, research worth keeping | durable — outlives the work |
| `work-state` | the plan, progress, blockers, next action, handoffs | in flight — dies with the work |
| `records` | one-off write-ups: audit reports, research process logs | archival; not consulted while working |
| `scratch` | throwaway: debug harnesses, captured diffs, resume caches | deleted when the work ends |
| `standards` | the source of the project's own criteria (review checklist, coding standards) | maintained by the host, never by a skill |

**Resolving a location.** The resolution ladder below is stated once, at
runtime, in `using-omnipowers`. A skill names only its artifact's role and its
fallback path, and points at that skill for the rest. The ladder:

1. a location the user states in this session;
2. the host's `Omnipowers` declaration — a section by that name in the host's
   `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using the
   row for this artifact's role;
3. where the host already keeps documents of that role, when that is unambiguous;
4. the fallback the skill states.

Resolving to 3 or 4 MUST be confirmed with the user before the first write of
that role in that project, and their answer governs from then on. Resolving to 1
or 2 MUST NOT ask.

**The declaration.** The host writes it once, as Markdown, inside a file its
agents already load — never a new config file, never a machine-readable format:

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
- continuation: <the host's mechanism for work that outlives one round>
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
- **continuation** — the host names the mechanism that carries work past the end
  of a round: a recurring re-invocation, a persistent goal, a scheduled task. A
  skill MUST NOT name one; it states the condition that calls for continuation
  and uses whatever the host declares. No mechanism is declared → the next step
  goes into the host's `work-state` and the round ends stated, not continued.
  Continuation carries out an objective the user already approved; it MUST NOT be
  used to proceed past a decision this collection requires the user to make.

**`.omnipowers/` is a workbench, not an archive.** It is the fallback home for
`work-state` and `scratch`, and nothing else. Durable artifacts MUST NOT
accumulate there. Everything a skill leaves in the workbench MUST be promoted to a
durable role or deleted when the work finishes.

### Locales

- **Locale** — one complete translation of the collection under `skills/<locale>/`. The locales are `en` and `zh-CN`; they have equal standing.
- Every locale MUST hold the same skills, and every skill the same files, under the same names. Skill names, `name` fields, file names, `@` pointers, role names, policy-axis names, the `Omnipowers` section name, and paths MUST be identical in every locale.
- A change to a file in one locale → the same change MUST land in every other locale in the same commit.
- `tests/test-locale-parity.sh` → it MUST pass: per file, equal counts of each BCP 14 keyword, equal `@` pointer sets, equal code-block counts, equal `name` fields.
- `README.md` and `README.zh-CN.md` are translations of each other → an edit MUST land in both in the same commit.
- A script inside a skill exists once, in `en`; every other locale links to it with a relative symlink. Script output stays English.

#### zh-CN writing rules

- Prose MUST be Chinese. BCP 14 keywords MUST stay English and capitalized, and MUST be placed after the subject and before the action. `MUST NOT` and `SHOULD NOT` MUST NOT be split.
- Prose MUST NOT carry a Chinese modal word: 必须, 务必, 应该, 应当, 不应, 不得, 禁止, 严禁, 不宜, 可以, 允许, 不必, 无须, 无需. Force is carried by the BCP 14 keyword alone; capability is written as 能 / 无法.
- The BCP 14 note MUST read: `> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。`
- Each Chinese sentence MUST sit on one source line; a line break MUST NOT fall between two CJK characters.
- Code blocks, commands, paths, identifiers, quoted program output, and file and skill names MUST stay as in `en`. Templates the reader reproduces MUST be translated, except their code.
- A `description` MUST be Chinese, and MUST keep the Chinese trigger words and the English technical terms of the `en` description.
- The text MUST read as written by a native speaker: no 该/其/之 officialese, no nominalized chains, no passive voice where an active subject exists.
- A term in the glossary below MUST be translated as listed.

#### zh-CN glossary

| en | zh-CN |
|---|---|
| skill | 技能 |
| supporting file | 辅助文件 |
| conditional pointer | 条件指针 |
| description | description（frontmatter 字段名，不译） |
| collection | 技能集 |
| host project / host | 宿主项目 / 宿主 |
| host declaration | 宿主声明 |
| role | 角色 |
| workbench | 工作台（`.omnipowers/`） |
| policy axis | 策略轴 |
| round | 轮次 / 一轮 |
| checkpoint | 检查点 |
| gate | 闸门 |
| sentinel | 哨兵文件 |
| ledger | 台账 |
| requirement | 要求 |
| acceptance item | 验收项 |
| delivery criteria | 交付标准 |
| task | 任务 |
| plan | 计划 |
| spec | 规格 |
| review / reviewer | 评审 / 评审者 |
| implementer | 实现者 |
| finding | 发现项 |
| claim | 声明 |
| evidence | 证据 |
| verdict | 结论 |
| blocker | 阻塞项 |
| scope | 范围 |
| dispatch | 派发 |
| tracked (call / task) | 受追踪的（调用 / 任务） |
| idle | 空闲 |
| queue | 队列 |
| you (the reader the skill addresses) | 你 |
| agent / subagent | agent / subagent（不译） |
| handoff | 交接 |
| artifact | 产物 |
| prototype | 原型 |
| commit (n. / v.) | 提交 |
| stage / staging | 暂存 |
| push | 推送 |
| branch | 分支 |
| mainline | 主干 |
| worktree | worktree（不译） |
| merge / rebase | 合并 / rebase（不译） |
| conflict / hunk | 冲突 / hunk（不译） |
| isolation | 隔离 |
| root cause | 根因 |
| hypothesis | 假设 |
| regression | 回归 |
| reproduce / red / green | 复现 / 红 / 绿 |
| fixture / harness | fixture / harness（不译） |
| feedback loop | 反馈回路 |
| sweep | 排查（同类问题） |
| Iron Law | 铁律 |
| red flag | 危险信号 |
| rationalization | 自我开脱 |
| escape hatch | 例外出口 |
| module / interface / depth | 模块 / 接口 / 深度 |
| deep module / shallow module | 深模块 / 浅模块 |
| seam / adapter | 接缝 / 适配器 |
| glossary / ADR | 术语表 / ADR |
| context (agent context window) | 上下文 |
| throughput | 吞吐 |

### Cross-skill consistency

- **A mechanism the collection defers to is added or changed** — a policy axis, an artifact role, a shared gate, a named moment — → you MUST sweep every existing skill for rules written before it, in the same change.
- **A requirement is stated in two skills** → it is a defect. Every requirement has exactly one owning skill; another skill that depends on it names the owner and adds nothing. Within one skill, a rule restated in a second section MUST be changed with the first.
- **A rule fires at a fixed moment** — task start, round end, before a commit — → you MUST read it together with every other rule that fires at that moment, and confirm they can all be satisfied at once and that none of them forbids the moment from arriving.

### Vocabulary

These terms are canonical; the _Avoid_ forms are not.

- **skill** — one directory under `skills/<locale>/` with a `SKILL.md`. _Avoid_: power, command, plugin.
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
- [ ] Skill map synced: adding, renaming, removing, or re-scoping a skill updates `skill-map.md` of `using-omnipowers` in every locale in the same change.
- [ ] Locales synced: the same change landed in every locale; `make test` passes the locale parity and both style gates.
- [ ] Fragile operation + single correct answer + nameable failure mode → `MUST` / `MUST NOT`.
- [ ] Every `MUST` traces to a failure observed or concretely arguable; no nameable failure → downgrade to `SHOULD` or delete.
- [ ] Judgment varies by situation / no standard answer → `SHOULD` / `MAY`.
- [ ] No softening of a real rule ("consider", "try to", "it's good practice").
- [ ] Every sentence is a rule (condition → keyword command), a definition, or a template; nothing else.
- [ ] Any exception uses the one-escape shape above.
- [ ] Self-contained: carries the BCP 14 note; no reference outside this repo.
- [ ] Progressive disclosure: every-invocation discipline stays inline; situational or heavy reference (over 100 lines, or used in a minority of runs) is a same-directory supporting file reached by a conditional pointer.
- [ ] Portable at runtime: works in any host project; no dependency on this repo's tooling; all state stays inside the host project.
- [ ] No hardcoded home: every artifact names one of the five roles and its fallback, and resolves the rest through `using-omnipowers`; the ladder is not restated.
- [ ] Throughput: every run/read/write/review demand accepts a prior result on the same input; per-action cost is proportional; a document has a too-small case; heavy material is behind a condition that is false on the ordinary task.
- [ ] Policy deferred: any commit form, branch/isolation assumption, or write into host-owned space yields to a declared `vcs` / `isolation` / `write-authority` axis.

For the change as a whole:

- [ ] A mechanism the collection defers to was added or changed → every skill predating it was swept in this change.
- [ ] The requirement you added or changed is stated in exactly one skill; every other skill that needs it names that owner.
- [ ] A rule firing at a fixed moment was read against the others firing at that moment: all satisfiable together, and none forbids the moment from arriving.
