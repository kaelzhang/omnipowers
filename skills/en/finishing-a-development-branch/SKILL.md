---
name: finishing-a-development-branch
description: Use when a branch's or worktree's work is done and verified and the branch is about to end — merge it back to the mainline ("回主干", "合并到主干"), ship it, clean up the worktree/branch — you MUST verify it, merge it into the mainline without a PR and without asking the user, unless the host declares a PR workflow
---

# Finishing a Development Branch

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
EVERY BRANCH ENDS VERIFIED AND MERGED INTO THE MAINLINE, WITHOUT ASKING
```

- Finishing a branch or worktree → you MUST NOT ask the user how to integrate it, whether to merge it, or whether to clean up.
- Finishing a branch or worktree → you MUST NOT leave it unmerged or discard its work.
- The host declares no PR workflow → you MUST NOT open a PR.

Mainline — the integration branch the host declares; otherwise the remote's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`); otherwise the one of `main` and `master` that exists.

Host PR workflow — a host `vcs` or `isolation` declaration requiring changes to reach the mainline through a pull request.

## The Process

When finishing a branch or worktree → you MUST complete these steps in order:

1. Verify.
2. Empty the workbench.
3. Merge into the mainline, or follow the host PR workflow.
4. Push.
5. Clean up only what you created.
6. Report.

### 1. Verify

- Before merging → the project's completeness gate (tests, type checks, linters, build) MUST have passed on this exact tree, under `verification-before-completion`.
- The project has no test suite → you MUST run the smallest check that proves the change holds, and MUST name it in the report.
- The check fails → you MUST fix the work and re-run it.
- The check fails → you MUST NOT merge.

### 2. Empty the Workbench

Before merging → you MUST account for everything this work left in the host's in-flight and throwaway state (the plan, progress ledgers, captured diffs, debug harnesses, handoffs), wherever the host puts it, falling back to `.omnipowers/`:

- A decision, a design conclusion, or a rule outlives this branch → it MUST move into the host's durable design documents before you merge.
- Promotion is complete → the in-flight artifacts for this work MUST be deleted.

### 3. Merge into the Mainline

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- Merging → you MUST run the merge from the mainline checkout, never from inside a worktree about to be removed.
- The mainline checkout is on a branch other than the mainline → you MUST NOT switch it.
- The mainline checkout holds uncommitted changes you did not make → you MUST NOT stash, reset, or overwrite them.
- The work sits on a detached HEAD → you MUST create a branch at that commit before merging it.
- The host declares a merge form (merge commit, rebase, fast-forward, squash) → you MUST use it.
- The host declares no merge form → you SHOULD use the form the mainline's existing history uses.
- The merge conflicts → you MUST resolve it under `resolving-merge-conflicts`.
- The merge conflicts → you MUST NOT `git merge --abort` and report failure.
- The merge is done → the completeness gate MUST pass on the merged tree before you delete anything.
- The merged-tree check fails → you MUST fix it on the mainline before you delete anything.

### Host PR Workflow

- The host declares a PR workflow → you MUST push the branch and open a PR instead of merging locally.
- The host declares a PR workflow → you MUST NOT ask the user before opening the PR.
- No PR tooling is available → you MUST report the pushed branch and its remote.
- A PR is open and unmerged → you MUST NOT remove its worktree or branch.
- A PR is open and unmerged → you MUST NOT report the work as merged.

### 4. Push

- The merged-tree check passes and the mainline tracks a remote → you MUST push the mainline under `committing-work`'s push rules.
- The push is rejected by a protection the host has not declared → you MUST report it as a blocker under `confirming-with-the-user`.

### 5. Clean Up Only What You Created

The merge is pushed, or the mainline tracks no remote → you MUST delete the merged branch from the mainline checkout:

```bash
git branch -d <feature-branch>
```

- A worktree references the branch → you MUST remove that worktree before deleting the branch.
- When removing a worktree → you MUST only remove one that this skill or your own workflow created.
- The host environment provisioned a workspace → you MUST NOT remove it.

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

**Host-owned workspace** — a worktree you did not create this session, or whose provenance is uncertain. The host's workspace-exit mechanism ends it; without one it stays in place and is reported as host-owned.

### 6. Report

The work is merged and cleaned up → you MUST report it in this form:

```
Merged <feature-branch> into <mainline> at <commit>; pushed to <remote> (or: no remote).
Verified: <check> on the merged tree.
Promoted: <item → location>; deleted: <workbench items>.
Removed: <branch>, <worktree path> (or: host-owned workspace left in place).
```

## Red Flags — STOP

You catch yourself thinking any thought in this table → you MUST stop and correct course:

| Thought | What to do instead |
|---|---|
| "I should ask whether to merge, open a PR, or keep the branch." | Merge into the mainline; the host's declared PR workflow is the only other path. |
| "Tests probably pass — I ran them earlier." | A run on this exact tree stands; no such run → run it now and read the output. |
| "There's no test command, so there's nothing to check." | Run the smallest proving check and name it in the report. |
| "The mainline checkout has someone's edits; I'll stash them." | Leave them; merge only what is yours. |
| "I'll keep the branch around in case." | Merge it; an unmerged branch is not finished work. |
| "The merge is done — I'll remove the worktree now." | The merged-tree check passes first. |
| "I'm inside the worktree; `git worktree remove` will sort it out." | `cd` to the main checkout first. |
| "This worktree is in the way, I'll just remove it." | You did not create it this session → leave it. |

## Completion Checklist

Before calling the work finished → you MUST be able to check every applicable box:

- [ ] The completeness gate passed on the branch tree, and again on the merged tree.
- [ ] The workbench was emptied: durable conclusions promoted, in-flight artifacts deleted.
- [ ] The work was merged into the mainline, or a PR was opened under a declared host PR workflow.
- [ ] Nothing was asked of the user about integration or cleanup.
- [ ] The mainline was pushed where it tracks a remote.
- [ ] Only branches and worktrees you created were removed, worktree before branch, from the main checkout.
- [ ] The report names the merge commit, the check, what was promoted and deleted, and what was removed.
