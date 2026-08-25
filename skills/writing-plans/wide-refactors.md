# Wide Refactors — Expand–Contract

**Load this reference when:** the plan contains a wide mechanical refactor — a rename, retype, signature change, module move, or API migration whose blast radius fans across many files or packages.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Scope

A **wide refactor** is one mechanical change — rename a shared symbol, change a signature, move a module, migrate callers from an old API to its replacement — whose **blast radius** (the set of call sites the change breaks) spans so many files that a single atomic edit cannot land as one reviewable, testable task.

All call sites fit in one right-sized task — one diff a reviewer can gate, one test cycle, one commit → you MUST plan the refactor as a single ordinary task and MUST NOT apply this file. Blast radius, not importance, decides: a rename touching four files is one task; a rename touching forty packages is expand–contract.

## The Green Invariant

- After every task in the sequence, the codebase MUST build and the full test suite MUST pass.
- Each task's verification step MUST run the **full** suite, not only the tests near the files touched.

## Sequencing — three phases

### 1. EXPAND — introduce the new form beside the old

- You MUST add the new form alongside the old with both fully working. One of the two MUST delegate to the other so the behavior is defined exactly once.
- This task MUST NOT change any caller.
- The new form's tests belong in this task; they MUST pass while every existing test (still exercising the old form) also passes.
- EXPAND MUST be its own plan task and MUST block every migrate batch.

### 2. MIGRATE — move callers over in batches

- You MUST move callers in batches grouped by package or directory — a unit that changes together and reviews together. Each batch MUST be its own plan task.
- Batch size SHOULD track blast radius: small enough that the diff fits one review and one fresh context window (sizing varies by codebase density, so this is a judgment call).
- Each batch task depends only on EXPAND. Batches are mutually independent and MAY be executed in any order or in parallel.
- Each batch MUST end green (full suite) and MUST end with a commit.
- A batch MUST be purely mechanical. You MUST NOT fold behavior changes, cleanups, or unrelated fixes into a migrate batch.

### 3. CONTRACT — remove the old form

- You MUST remove the old form only when zero callers remain. CONTRACT MUST be the final task, blocked by every migrate batch.
- The task MUST verify zero callers with an exact search command (per the Iron Law, the plan spells out the command and its expected empty result), then delete the old form, then re-run the full suite green, then commit.
- The old form is part of a published interface the host cannot yet break → CONTRACT MAY be deferred behind a deprecation marker; the deferral is the host user's decision to confirm, and the deferred removal becomes its own future plan, not a silent forever-shim.

## Degradation — when both forms cannot coexist

Some changes cannot expand: a database column with no dual-write path, a serialized format, an external ABI, a signature the language will not overload.

- The host genuinely cannot keep both forms alive → you MUST fall back to a short-lived integration branch with the same batch discipline: the same task sequence — the breaking change first, then per-package batches — each task committed on the integration branch, and the Green Invariant enforced **on the branch** (branch build + full suite green after every task).
- You MUST merge to the mainline only when the migration is complete and the branch is fully green. You MUST NOT merge a partial migration.
- The branch MUST stay short-lived: you SHOULD sync it with the mainline frequently.
- Coexistence is possible → you MUST NOT reach for the integration branch.

## Mapping into the plan document

Each phase task keeps the standard plan-task shape: exact files, concrete steps, verification commands, commit step.

| Plan task | Phase | Blocked by |
|---|---|---|
| Task N | EXPAND | prior feature tasks, if any |
| Task N+1 … N+k | MIGRATE, one batch per task | Task N only |
| Task N+k+1 | CONTRACT | every migrate batch |
