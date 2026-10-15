# Wide Refactors — Expand–Contract

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Scope

Wide refactor — one mechanical change (a shared-symbol rename, signature change, module move, or caller migration to a replacement API) whose blast radius cannot fit in one reviewable, testable task.

Blast radius — the set of call sites the change breaks.

All call sites fit in one right-sized task — one diff a reviewer can gate, one test cycle, one commit → you MUST plan the refactor as a single ordinary task and MUST NOT apply this file.

## The Green Invariant

- After every task in the sequence → the codebase MUST build and the full test suite MUST pass.
- For each task → its verification step MUST run the **full** suite, not only the tests near the files touched.

## Sequencing — three phases

### 1. EXPAND — introduce the new form beside the old

- When planning EXPAND → you MUST add the new form alongside the old with both fully working.
- When planning EXPAND → one of the two forms MUST delegate to the other, with behavior defined exactly once.
- When planning EXPAND → this task MUST NOT change any caller.
- When verifying EXPAND → the new form's tests in this task MUST pass while every existing test (still exercising the old form) also passes.
- When sequencing the refactor → EXPAND MUST be its own plan task and MUST block every migrate batch.

### 2. MIGRATE — move callers over in batches

- When planning MIGRATE → you MUST move callers in batches grouped by package or directory, as a unit that changes together and reviews together.
- When planning MIGRATE → each batch MUST be its own plan task.
- When sizing a migrate batch → batch size SHOULD track blast radius, with a diff that fits one review and one fresh context window.
- After EXPAND → migrate batches MAY be executed in any order or in parallel.
- At the end of each migrate batch → the batch MUST be green (full suite) and MUST end with a commit.
- When planning a migrate batch → the batch MUST be purely mechanical.
- When planning a migrate batch → you MUST NOT fold behavior changes, cleanups, or unrelated fixes into it.

### 3. CONTRACT — remove the old form

- When planning CONTRACT → you MUST remove the old form only when zero callers remain.
- When sequencing the refactor → CONTRACT MUST be the final task, blocked by every migrate batch.
- When planning CONTRACT → the task MUST verify zero callers with an exact search command (per the Iron Law, the plan spells out the command and its expected empty result), then delete the old form, then re-run the full suite green, then commit.
- The old form is part of a published interface the host cannot yet break → CONTRACT MAY be deferred behind a deprecation marker, with the host user confirming the deferral and the removal recorded as its own future plan.

## Degradation — when both forms cannot coexist

- The host cannot keep both forms alive → you MUST fall back to a short-lived integration branch with the same batch discipline: the same task sequence — the breaking change first, then per-package batches — each task committed on the integration branch, and the Green Invariant enforced **on the branch** (branch build + full suite green after every task).
- When merging the integration branch to the mainline → you MUST merge only when the migration is complete and the branch is fully green.
- The migration is partial → you MUST NOT merge it.
- When using an integration branch → the branch MUST stay short-lived.
- When using an integration branch → you SHOULD sync it with the mainline frequently.
- Coexistence is possible → you MUST NOT reach for the integration branch.

## Mapping into the plan document

| Plan task | Phase | Blocked by |
|---|---|---|
| Task N | EXPAND | prior feature tasks, if any |
| Task N+1 … N+k | MIGRATE, one batch per task | Task N only |
| Task N+k+1 | CONTRACT | every migrate batch |
