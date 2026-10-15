---
name: finishing-a-development-branch
description: Use when a feature branch's work is done and verified and you're ready to wrap it up — merge it back to the mainline ("回主干", "合并到主干"), open a PR, ship it, keep it, or discard it (incl. cleaning up the worktree/branch) — you MUST verify tests pass, then integrate the way the host declares or the user states — and only where neither does, present the options and let the user choose
---

# Finishing a Development Branch

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- When resolving the integration path (merge, PR, keep, discard) → you MUST NOT decide on the user's behalf.
- Gated actions — steps that change the base branch or destroy work; publishing the feature branch is ordinary work in progress.

## The Iron Law

```
NO INTEGRATION WITHOUT GREEN TESTS, AND NO DESTRUCTIVE ACTION WITHOUT EXPLICIT USER CHOICE
```

- Until the test suite passes in this session AND the user has chosen the action → you MUST NOT merge, delete a branch, or remove a worktree.
- When presenting the menu → you MUST NOT collapse it to a single assumed answer.

## The Process

When finishing a development branch → you MUST execute these phases in order.

Before tests pass and the workspace is detected → you MUST NOT resolve the option.

### Phase 1 — Verify Tests (REQUIRED gate)

- Before resolving the option → the project's own test command MUST have passed on this exact tree in this session, under the `verification-before-completion` rule.
- The suite fails → you MUST stop.
- The suite fails → you MUST NOT proceed to Phase 2.
- The suite fails → you MUST report:

```
Tests failing (<N> failures). These MUST be fixed before integrating:

<failures>

Integration is blocked until the suite is green.
```

- The suite passes → you MAY proceed to Phase 2 ONLY in this state.
- The project has no test suite → you MUST state that explicitly to the user and obtain their acknowledgement before continuing.
- A test command is missing → you MUST NOT silently treat that as "there are no tests".

### Phase 1b — Empty the Workbench (REQUIRED)

Phase 1b scope — the **Merge**, **PR**, and **Discard** options.

The **Keep** option is selected → you MUST leave the workbench alone.

Before integrating → you MUST account for everything this work left in the host's in-flight and throwaway state (the plan, progress ledgers, captured diffs, debug harnesses, handoffs), wherever the host puts it, falling back to `.omnipowers/`:

- A decision, a design conclusion, or a rule outlives this branch → it MUST move into the host's durable design documents before you integrate.
- Promotion is complete → the in-flight artifacts for this work MUST be deleted.
- When reporting completion → you MUST state what you promoted and where, and what you deleted.

### Phase 2 — Detect the Workspace

Before choosing a menu → you MUST determine the workspace shape.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
HEAD_REF=$(git symbolic-ref -q --short HEAD || echo "DETACHED")
```

The workspace shape is detected → you MUST use the matching row:

| State | Menu | Cleanup |
|---|---|---|
| `GIT_DIR == GIT_COMMON` (plain repo, named branch) | Full 4-option menu | No worktree exists — branch-only cleanup |
| `GIT_DIR != GIT_COMMON` (worktree), named branch | Full 4-option menu | Provenance-based cleanup (Phase 6) |
| `GIT_DIR != GIT_COMMON` (worktree), detached HEAD | Detached HEAD → you MUST NOT offer a local merge; reduced 3-option menu | Detached HEAD → you MUST NOT remove this workspace |

### Phase 3 — Determine the Base Branch

Before offering a merge or PR → you MUST establish the base branch NAME the work will integrate into.

When establishing the base → it MUST be a branch name, not a commit SHA.

```bash
# Resolve the base branch NAME (prefers main, then master):
BASE=$(git rev-parse --verify --quiet main >/dev/null && echo main \
  || (git rev-parse --verify --quiet master >/dev/null && echo master))
```

`BASE` comes back empty, the base is ambiguous, or the project uses a different integration branch → you MUST confirm the base with the user rather than guessing.

### Phase 4 — Resolve the Option

- The host's `Omnipowers` declaration (its `isolation` or `vcs` row) or the user in this session states how finished work returns to the mainline → you MUST execute that choice in Phase 5.
- The host's `Omnipowers` declaration (its `isolation` or `vcs` row) or the user in this session states how finished work returns to the mainline → you MUST NOT present a menu.
- Neither the host declaration nor the user states the integration choice → you MUST present the options as a concise, numbered menu with your recommendation, as the `confirming-with-the-user` skill requires, and wait for the user's choice.
- Neither the host declaration nor the user states the integration choice → you MUST NOT execute an option before the user selects it, and MUST NOT assume a policy the host has not stated.

#### Full menu — plain repo or named-branch worktree

```
Implementation complete and tests pass. How would you like to integrate this work?

1. Merge into <base-branch> locally
2. Push the branch and open a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

#### Reduced menu — detached HEAD (externally managed workspace)

```
Implementation complete and tests pass. You're on a detached HEAD (externally managed workspace).

1. Push as a new branch and open a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

### Phase 5 — Execute the Chosen Option

The option is resolved in Phase 4 (declared, stated, or chosen) → you MUST execute only that option using the steps below.

History integrity — the `committing-work` skill's rule governing force-pushes and rewriting published commits.

#### Option: Merge Locally

The **Merge** option is selected → you MUST verify the merge succeeds and re-run tests on the merged result before deleting anything.

The **Merge** option is selected → you MUST run worktree commands and branch deletion from the main checkout, never from inside a worktree that is about to be removed.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git checkout <base-branch>
# Pull only if the base tracks a remote:
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- Tests on the merged tree fail → you MUST NOT delete the branch or the worktree.
- The merge conflicts → you MUST resolve it via the `resolving-merge-conflicts` skill (per-hunk, by intent).
- The merge conflicts → you MUST NOT `git merge --abort` and report failure.
- A worktree references the branch → you MUST NOT delete the branch before removing that worktree.

```bash
git branch -d <feature-branch>
```

#### Option: Push and Open a PR

```bash
git push -u origin <feature-branch>
```

- No PR tooling is available → you MUST report the pushed branch and its remote.
- The **PR** option is selected → you MUST NOT clean up the worktree.

#### Option: Keep As-Is

- The **Keep** option is selected → you MUST NOT merge or remove anything.
- The **Keep** option is selected → you MUST report the state:

```
Keeping branch <name>. Worktree preserved at <path> (if any).
```

- The **Keep** option is selected → you MUST NOT describe kept work as done or delivered.
- Handoff mainline rule — the `using-git-worktrees` rule on returning to the mainline before handing work to another agent or session.

#### Option: Discard (REQUIRED confirmation gate)

Before discarding work → you MUST obtain a typed confirmation:

```
This will permanently delete:
- Branch <name>
- These commits: <commit-list>
- Worktree at <path> (if any)

Type 'discard' to confirm.
```

- Before discarding work → you MUST wait for the exact word `discard`.
- The response is anything other than the exact word `discard`, or there is no response → you MUST NOT proceed.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git branch -D <feature-branch>
```

### Phase 6 — Clean Up Only What You Created

Phase 6 scope — the **Merge** and **Discard** options only.

The **PR** or **Keep** option is selected → you MUST always preserve the worktree.

When removing a worktree → you MUST only remove one that this skill (or your own workflow) created.

The host environment provisioned a workspace → you MUST NOT remove it.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

Plain repo — `GIT_DIR == GIT_COMMON`; no worktree exists.

- `WORKTREE_PATH` is under `.worktrees/` or `worktrees/` AND you created this worktree in this session → you MUST `cd` to the main checkout before removing:

  ```bash
  MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
  cd "$MAIN_ROOT"
  git worktree remove "$WORKTREE_PATH"
  git worktree prune   # clear any stale worktree registrations
  ```

- `WORKTREE_PATH` is not under `.worktrees/` or `worktrees/`, you did not create the worktree this session, or its provenance is uncertain → you MUST NOT remove it.

## Red Flags — STOP if you catch yourself thinking

You catch yourself thinking any thought in this table → you MUST stop and correct course:

| Thought | What to do instead |
|---|---|
| "Tests probably pass — I ran them earlier." / "The merge looks fine, skip the re-test." | A run on this exact tree stands; no such run → run it now and read the output. |
| "There's no test command, so there are no tests." | State the missing-suite finding and get the user's acknowledgement first. |
| "It's a single-maintainer repo, just merge it." / "The user clearly wants a PR." | Nothing declared or stated → present the menu and wait. |
| "`yes` is good enough to discard." | Wait for the exact typed word `discard`. |
| "I'll force-push to tidy this up." | `committing-work` governs history integrity. |
| "I'll clean up the worktree now to be tidy." | Clean up only for Merge and Discard; PR and Keep preserve the worktree. |
| "The merge is done — I'll remove the worktree now." | Confirm the merge succeeded and its tests passed first. |
| "I'm inside the worktree; `git worktree remove` will sort it out." | `cd` to the main checkout first. |
| "This worktree is in the way, I'll just remove it." | You did not create it this session → leave it. |
| "I'll delete the branch first, then the worktree." | Remove the worktree first. |

## Completion Checklist

Before calling the work finished → you MUST be able to check every applicable box:

- [ ] Ran the test suite this session and it passed (or the no-test state was acknowledged by the user).
- [ ] Detected the workspace shape and chose the matching menu.
- [ ] Confirmed the base branch.
- [ ] The option came from the host's declaration or the user's words; otherwise the exact menu was presented and I waited for their choice.
- [ ] Executed only the chosen option.
- [ ] For Merge: verified the merge and re-ran tests on the result before any deletion.
- [ ] For Discard: obtained the typed `discard` confirmation.
- [ ] Cleaned up the worktree only for Merge/Discard, and only if you created it.
- [ ] `cd`'d to the main checkout before any worktree removal, and ran `git worktree prune` after.
- [ ] Left host-owned workspaces untouched.
