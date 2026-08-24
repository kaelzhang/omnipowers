---
name: finishing-a-development-branch
description: Use when a feature branch's work is done and verified and you're ready to wrap it up — merge it, open a PR, ship it, keep it, or discard it (incl. cleaning up the worktree/branch) — you MUST verify tests pass, then present the integration options and let the user choose before any merge or deletion
---

# Finishing a Development Branch

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- You MUST NOT decide the integration path — merge, PR, keep, discard — on the user's behalf. Verify the work is safe to integrate, lay out the options precisely, and carry out the one the user picks.
- Publishing the feature branch is NOT a gated action — the branch is pushed as ordinary work in progress. Gated are only the steps that change the base branch or destroy work.

## The Iron Law

```
NO INTEGRATION WITHOUT GREEN TESTS, AND NO DESTRUCTIVE ACTION WITHOUT EXPLICIT USER CHOICE
```

- You MUST NOT merge, delete a branch, or remove a worktree until the test suite passes in this session AND the user has chosen the action.
- You MUST NOT collapse the menu to a single assumed answer.

## The Process

You MUST execute these phases in order. You MUST NOT present options before tests pass and the workspace is detected.

### Phase 1 — Verify Tests (REQUIRED gate)

- Before presenting any option → you MUST run the project's own test command and read its output in this session.
- The suite fails → you MUST stop, you MUST NOT proceed to Phase 2, and you MUST report:

```
Tests failing (<N> failures). These MUST be fixed before integrating:

<failures>

Integration is blocked until the suite is green.
```

- You MAY proceed to Phase 2 ONLY when the suite passes.
- The project genuinely has no test suite → you MUST state that explicitly to the user and obtain their acknowledgement before continuing. A missing test command MUST NOT be silently treated as "there are no tests".

### Phase 1b — Empty the Workbench (REQUIRED)

This phase runs for the **Merge**, **PR**, and **Discard** options. The **Keep** option MUST leave the workbench alone.

Before integrating you MUST account for everything this work left in the host's in-flight and throwaway state — the plan, progress ledgers, captured diffs, debug harnesses, handoffs — wherever the host puts it, falling back to `.omnipowers/`:

- A decision, a design conclusion, or a rule that outlives this branch MUST move into the host's durable design documents before you integrate.
- Once promoted, the in-flight artifacts for this work MUST be deleted.
- You MUST state in the completion report what you promoted and where, and what you deleted.

### Phase 2 — Detect the Workspace

You MUST determine the workspace shape before choosing a menu.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
HEAD_REF=$(git symbolic-ref -q --short HEAD || echo "DETACHED")
```

You MUST use the matching row:

| State | Menu | Cleanup |
|---|---|---|
| `GIT_DIR == GIT_COMMON` (plain repo, named branch) | Full 4-option menu | No worktree exists — branch-only cleanup |
| `GIT_DIR != GIT_COMMON` (worktree), named branch | Full 4-option menu | Provenance-based cleanup (Phase 6) |
| `GIT_DIR != GIT_COMMON` (worktree), detached HEAD | Reduced 3-option menu — you MUST NOT offer a local merge | None — you MUST NOT remove this workspace |

### Phase 3 — Determine the Base Branch

You MUST establish the base branch NAME the work will integrate into before offering a merge or PR, and it MUST be a branch name, not a commit SHA.

```bash
# Resolve the base branch NAME (prefers main, then master):
BASE=$(git rev-parse --verify --quiet main >/dev/null && echo main \
  || (git rev-parse --verify --quiet master >/dev/null && echo master))
```

`BASE` comes back empty, the base is ambiguous, or the project uses a different integration branch → you MUST confirm the base with the user rather than guessing.

### Phase 4 — Present the Options (let the user choose)

You MUST present the options as a concise, numbered menu and then wait for the user's choice. You MUST NOT add commentary, recommend one option as "what I'll do", or execute any option before the user selects it. The host project's integration policy is unknown → you MUST NOT assume one; the user's choice is authoritative.

**Full menu — plain repo or named-branch worktree. Present exactly these 4 options:**

```
Implementation complete and tests pass. How would you like to integrate this work?

1. Merge into <base-branch> locally
2. Push the branch and open a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Reduced menu — detached HEAD (externally managed workspace). Present exactly these 3 options:**

```
Implementation complete and tests pass. You're on a detached HEAD (externally managed workspace).

1. Push as a new branch and open a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

### Phase 5 — Execute the Chosen Option

You MUST execute only the option the user selected, using the steps below. You MUST NOT force-push without the user's explicit request.

#### Option: Merge Locally

You MUST verify the merge succeeds and re-run tests on the merged result before deleting anything. You MUST run worktree commands and branch deletion from the main checkout, never from inside a worktree that is about to be removed.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git checkout <base-branch>
# Pull only if the base tracks a remote:
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- Re-run the project's test command on the merged result. It fails → STOP; you MUST NOT delete the branch or the worktree.
- The merge conflicts → you MUST resolve it via the `resolving-merge-conflicts` skill (per-hunk, by intent). You MUST NOT `git merge --abort` and report failure — an abort is the user's decision, not an escape from difficulty.
- The merge succeeded AND tests on the merged result passed → clean up the worktree (Phase 6) first, then delete the branch. You MUST NOT delete the branch before removing the worktree that references it.

```bash
git branch -d <feature-branch>
```

#### Option: Push and Open a PR

```bash
git push -u origin <feature-branch>
```

- Then open the PR using the host project's mechanism.
- No PR tooling is available → you MUST report the pushed branch and its remote so the user can open the PR themselves.
- You MUST NOT clean up the worktree for this option.

#### Option: Keep As-Is

- You MUST NOT merge or remove anything.
- You MUST report the state:

```
Keeping branch <name>. Worktree preserved at <path> (if any).
```

- You MUST NOT describe kept work as done or delivered.
- The work is later handed to another agent or session → you MUST return it to the mainline first.

#### Option: Discard (REQUIRED confirmation gate)

You MUST obtain a typed confirmation first:

```
This will permanently delete:
- Branch <name>
- These commits: <commit-list>
- Worktree at <path> (if any)

Type 'discard' to confirm.
```

- You MUST wait for the exact word `discard`. Any other response means do not delete; you MUST NOT proceed on a vague "yes", "ok", or silence.
- After confirmation, clean up the worktree (Phase 6), then force-delete the branch:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git branch -D <feature-branch>
```

### Phase 6 — Clean Up Only What You Created

Cleanup runs for the **Merge** and **Discard** options only. The **PR** and **Keep** options MUST always preserve the worktree.

You MUST only remove a worktree that this skill (or your own workflow) created. You MUST NOT remove a workspace the host environment provisioned.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

Apply the matching case:

- **`GIT_DIR == GIT_COMMON`** — plain repo, no worktree exists. Nothing to clean up. Done.
- **`WORKTREE_PATH` is under `.worktrees/` or `worktrees/` AND you created this worktree in this session** — you own it; remove it. A path match alone is NOT proof of ownership. You MUST `cd` to the main checkout before removing:

  ```bash
  MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
  cd "$MAIN_ROOT"
  git worktree remove "$WORKTREE_PATH"
  git worktree prune   # clear any stale worktree registrations
  ```

- **Otherwise — including any worktree you did not create this session or whose provenance is uncertain** — the host environment owns this workspace and you MUST NOT remove it. The host provides a workspace-exit mechanism → use it; otherwise leave the workspace in place and report that the host owns it.

## Red Flags — STOP if you catch yourself thinking

You MUST stop and correct course if you catch yourself thinking any of these:

| Thought | What to do instead |
|---|---|
| "Tests probably pass — I ran them earlier." / "The merge looks fine, skip the re-test." | Run the suite now, on the current result, and read the output. |
| "There's no test command, so there are no tests." | State the missing-suite finding and get the user's acknowledgement first. |
| "It's a single-maintainer repo, just merge it." / "The user clearly wants a PR." | Present the menu and wait for the user's choice. |
| "`yes` is good enough to discard." | Wait for the exact typed word `discard`. |
| "I'll force-push to tidy this up." | Do not force-push without the user's explicit request. |
| "I'll clean up the worktree now to be tidy." | Clean up only for Merge and Discard; PR and Keep preserve the worktree. |
| "The merge is done — I'll remove the worktree now." | Confirm the merge succeeded and its tests passed first. |
| "I'm inside the worktree; `git worktree remove` will sort it out." | `cd` to the main checkout first; removal fails from inside the worktree being removed. |
| "This worktree is in the way, I'll just remove it." | You did not create it this session → leave it; the host owns it. |
| "I'll delete the branch first, then the worktree." | Remove the worktree first; `git branch -d` fails while a worktree holds the branch. |

## Completion Checklist

You MUST be able to check every applicable box before calling the work finished:

- [ ] Ran the test suite this session and it passed (or the no-test state was acknowledged by the user).
- [ ] Detected the workspace shape and chose the matching menu.
- [ ] Confirmed the base branch.
- [ ] Presented the exact menu (4 options, or 3 for detached HEAD) and waited for the user's choice.
- [ ] Executed only the chosen option.
- [ ] For Merge: verified the merge and re-ran tests on the result before any deletion.
- [ ] For Discard: obtained the typed `discard` confirmation.
- [ ] Cleaned up the worktree only for Merge/Discard, and only if you created it.
- [ ] `cd`'d to the main checkout before any worktree removal, and ran `git worktree prune` after.
- [ ] Left host-owned workspaces untouched.
