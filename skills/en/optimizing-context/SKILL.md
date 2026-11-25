---
name: optimizing-context
description: Use only when the user explicitly asks to shrink repository context, knowledge-base load, or model input volume — "slim context", "slim the knowledge base", "optimize input size", "精简上下文", "精简知识库", "优化输入大小" — you MUST cut resident load without losing any applicable rule or verbatim ruling, and this skill MUST NOT fire without an explicit request
---

# Optimizing Context

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Iron Law

```
CUT RESIDENT LOAD — PRESERVE EVERY APPLICABLE RULE AND VERBATIM RULING — PROVE BOTH BY MEASUREMENT
```

- Applying this skill → you MUST treat violating the letter of any rule below as violating its spirit.

## User-Initiated Only & Scope

- The user has not explicitly asked to shrink repository context, knowledge-base load, or model input size → this skill MUST NOT fire.
- You notice bloated resident instructions during another task → you MAY note it in one sentence.
- The user has not asked to optimize context → you MUST NOT restructure instruction files on your own initiative.

Out-of-scope siblings — compacting a live chat session (`writing-handoffs` or host compaction), cutting down a single skill (`writing-skills`), and ordinary documentation edits (`writing-documentation`); durable documentation sets created during a split MUST follow `writing-documentation`, and domain glossaries or ADRs MUST follow `domain-modeling`.

## 1. Inventory Actual Load

Runtime load inventory — per supported host and real launch directory, every input entering the model: global and ancestor instructions, root entrypoints, inline `@` imports, unscoped rule files, subagent preloaded skills, auto-memory, active MCP tool schemas, dispatch brief templates, and high-volume command outputs.

- Before editing any file → you MUST build the runtime load inventory from the working directory and launch mode agents use.
- Counting static bytes → you MUST resolve symlinks to their canonical target once, while keeping duplicate entries in the runtime load inventory when a host injects the same text twice.
- A host enforces a cumulative byte cap across ancestor and nested instruction files, or truncates memory past a line or byte cutoff → you MUST check whether root size starves or truncates nested files.
- The request targets model input size → your inventory MUST include unused MCP servers and commands whose raw output floods context.

## 2. Eliminate Before Relocating

- A formatting, lint, or style rule is already enforced by a deterministic check in pre-commit or CI → you MUST remove its prose restatement from resident instructions.
- A static directory overview only repeats paths and roles readable directly from the tree or manifest → you MUST remove it from resident instructions, keeping only non-obvious traps and routes.
- Instruction sources state conflicting commands or rules → you MUST reconcile them to one canonical source before splitting.
- Unused MCP servers or raw verbose command outputs inflate turn input → you SHOULD disable unused servers and route verbose commands through a quiet reporter, filter, or log file returning only actionable lines.

## 3. Assign Canonical Homes

Move ledger — a mapping of each retained item's old path, owner, load tier, new path, and verification check; a `design-docs` artifact resolved per `using-omnipowers` with fallback `docs/design/YYYY-MM-DD-context-plan.md` when the split spans multiple roles or documentation sets, or an inline table in your reply when a single entrypoint is split in one round.

Load tiers — the five canonical homes for retained material:

1. **Universal root** (`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`) — product boundaries, immediate safety and authority rules, core build/test commands, and routes needed before the first tool call.
2. **Role resident** — constraints needed on every dispatch of one subagent role and nowhere else.
3. **Path- or action-triggered** — host path-scoped rules carrying explicit path globs, subdirectory JIT files, or on-demand `SKILL.md` packs.
4. **Domain or module contract** — module entrypoints and interfaces reached via `writing-documentation` resolver tables.
5. **Queryable record** — rulings, ledgers, and rollout histories addressed by stable ID rather than whole-file reads.

- Moving multiple documentation sets or changing host entrypoint layout → you MUST confirm the move ledger with the user under `confirming-with-the-user` before moving files.
- Splitting resident instructions → you MUST NOT replace inline text with bare `@path` imports, rule files lacking path filters, or subagent `skills:` preloads unless that role requires the full text on every run.
- Agents launch from one checkout to edit a sibling worktree → you MUST verify whether path-scoped or subdirectory rules fire in that launch mode, and add an explicit route when they do not.
- Rewriting a dispatch brief template → you MUST delete copied standing-rule blocks.
- Rewriting a dispatch brief template → you MUST NOT instruct workers to re-read an entrypoint the host already injects at startup.
- Recording an approved deviation from a common standard → you MUST state it once where it takes effect, naming the original rule, authorization, date, local replacement, and upkeep owner.
- Historical records omit a required deviation field → you MUST flag the missing field to the user rather than inventing or dropping the deviation.
- Splitting a ruling register or ledger → you MUST preserve every binding quotation, ID, date, and scope verbatim, separating archival progress logs from active rulings instead of summarizing binding words.
- Migrating a ruling register or ledger → you MUST verify conservation against the pre-split Git blob by comparing the multiset of entries and checking every ID's ordered quotations byte for byte.
- A record shard still forces broad reads when one ID is needed → you SHOULD provide narrow lookup returning only the requested ID.

## 4. Mechanize and Seed-Test the Gates

- Completing a context or knowledge-base split → you MUST provide a deterministic check enforcing byte budgets on loader units, entrypoint reachability, link resolution, non-overlapping path ownership, and generated-index freshness.
- Setting size budgets in the check → you MUST gate byte counts on the unit the loader reads, never line count alone.
- Before trusting a new or edited check → you MUST seed a broken link, an over-budget file, and an altered quotation or dropped record in a disposable copy, confirm each defect causes a non-zero exit, and then confirm the repaired tree passes.

## 5. Verify Savings and Rule Survival

- The repository dispatches multiple agent roles, alters prompt-cache prefixes, or the user asks for measured token savings → read `@paired-measurement.md` and apply it.
- Before claiming optimization success → you MUST report before-and-after canonical resident bytes and verify on representative tasks that moved rules still surface with source citations while unrelated packs stay unloaded.
- Evaluating byte or token numbers → you MUST NOT compare different runners or models, report uncached input alone without total and cached figures, or count an errored, permission-blocked, or incomplete run as a saving.

## Rationalizations — Rejected

| Excuse | Reality |
| --- | --- |
| "`@docs/arch.md` shrinks `CLAUDE.md` to 60 lines" | Bare `@` imports expand at launch and save zero tokens; wrap paths in backticks with a task-signal route or use path-scoped rules. |
| "Summarizing 150 rulings into a 5 KB digest is faster" | Summarizing destroys exact exemption bounds and dates; split by domain and preserve binding quotations byte for byte. |
| "Telling the brief to `Read AGENTS.md` avoids copying rules" | The host already injects `AGENTS.md`; telling workers to read it again pays for it twice. |
| "The gate script exited 0 on the repo; seeding bugs wastes time" | An unseeded check can match nothing and exit 0; prove each defect turns red in a disposable copy first. |
| "A 100-line cap stops bloat" | One 14 KB line bypasses a line cap; gate bytes on the unit the loader reads. |
| "Valid `paths:` YAML guarantees firing in worktrees" | Path globs anchored to the main checkout miss sibling worktrees; verify the real launch directory. |
| "Input tokens dropped 52% on the new run" | Cross-runner comparisons and permission-blocked early exits fake savings; require comparable completion on the same runner. |

## Red Flags — STOP

| Thought | Command |
| --- | --- |
| "I'll reorganize `CLAUDE.md` using `@` imports to save context." | Stop; use conditional routes or path-scoped rules instead. |
| "I'll rewrite old rulings into clean one-line takeaways." | Stop; keep verbatim quotations and verify byte-for-byte conservation. |
| "IDs D01..D150 all exist in the new shards, so nothing was lost." | Compare the entry multiset and ordered per-ID quotations against `HEAD`. |
| "The check passed on the refactored tree, time to commit." | Seed a broken link, an over-budget file, and a mutated quote in a temp copy first. |
