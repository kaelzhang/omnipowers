---
name: finishing-a-development-branch
description: Use when a branch's or worktree's work is done and verified and the branch is about to end — merge it into the branch it was cut from, an integration branch or the mainline ("回主干", "合并到主干", "合入集成分支"), ship it, clean up the worktree/branch — you MUST verify it, merge it into its target branch without a PR and without asking the user, unless the host declares a PR workflow, then remove every merged worktree
---

# Finishing a Development Branch

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
EVERY BRANCH ENDS VERIFIED, MERGED INTO ITS TARGET BRANCH, AND REMOVED, WITHOUT ASKING
```

- Finishing a branch or worktree → you MUST NOT ask the user how to integrate it, whether to merge it, or whether to clean up.
- Finishing a branch or worktree → you MUST NOT leave it unmerged or discard its work.
- The host declares no PR workflow → you MUST NOT open a PR.

Mainline — the integration branch the host declares; otherwise the remote's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`); otherwise the one of `main` and `master` that exists.

Target branch — the branch the host or the user names as this branch's merge target; otherwise the branch this branch was created from (`git reflog show --format=%gs refs/heads/<branch> | tail -1` prints `branch: Created from <target>`); otherwise the mainline.

Integration branch — a branch other branches merge into before it reaches the mainline.

Main checkout — the repository's primary working tree, `git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel`.

Host PR workflow — a host `vcs` or `isolation` declaration requiring changes to reach the target branch through a pull request.

- The target branch is an integration branch and not the mainline → merging into it ends this branch, and this skill applies in full.

## The Process

When finishing a branch or worktree → you MUST complete these steps in order:

1. Verify.
2. Empty the workbench.
3. Merge into the target branch, or follow the host PR workflow.
4. Push.
5. Remove every merged worktree.
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

### 3. Merge into the Target Branch

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- Merging → you MUST run the merge from the main checkout, never from inside a worktree about to be removed.
- The main checkout is on a branch other than the target branch → you MUST NOT switch it.
- The main checkout holds uncommitted changes you did not make → you MUST NOT stash, reset, or overwrite them.
- The work sits on a detached HEAD → you MUST create a branch at that commit before merging it.
- The host declares a merge form (merge commit, rebase, fast-forward, squash) → you MUST use it.
- The host declares no merge form → you SHOULD use the form the target branch's existing history uses.
- The merge conflicts → you MUST resolve it under `resolving-merge-conflicts`.
- The merge conflicts → you MUST NOT `git merge --abort` and report failure.
- The merge is done → the completeness gate MUST pass on the merged tree before you delete anything.
- The merged-tree check fails → you MUST fix it on the target branch before you delete anything.

### Host PR Workflow

- The host declares a PR workflow → you MUST push the branch and open a PR instead of merging locally.
- The host declares a PR workflow → you MUST NOT ask the user before opening the PR.
- No PR tooling is available → you MUST report the pushed branch and its remote.
- A PR is open and unmerged → you MUST NOT remove its worktree or branch.
- A PR is open and unmerged → you MUST NOT report the work as merged.

### 4. Push

- The merged-tree check passes and the target branch tracks a remote → you MUST push the target branch under `committing-work`'s push rules.
- The push is rejected by a protection the host has not declared → you MUST report it as a blocker under `confirming-with-the-user`.

### 5. Remove Every Merged Worktree

Worktree directory — the directory the host's `isolation` declaration names for worktrees; otherwise `.worktrees/` or `worktrees/` at the project root.

Merged worktree — a linked worktree that meets every condition:

1. it sits in the worktree directory;
2. its branch has at least one commit of its own;
3. its branch is merged into the target branch;
4. `git status --porcelain` in it prints nothing;
5. no task, subagent, or session is running in it.

```bash
cd "$MAIN_ROOT"
git worktree list --porcelain
# for each <path> on <branch> in the worktree directory:
test "$(git reflog show --format=%gs refs/heads/<branch> | grep -vc '^branch: Created from')" -gt 0  # 2
git merge-base --is-ancestor <branch> <target-branch>                                               # 3
test -z "$(git -C <path> status --porcelain)"                                                        # 4
git worktree remove <path>
git branch -d <branch>
# after the loop:
git worktree prune
```

- The merge is pushed, or the target branch tracks no remote → you MUST remove every merged worktree whose target is this branch's target branch, then delete its branch, from the main checkout.
- This branch has no worktree → you MUST delete it with `git branch -d` from the main checkout.
- Deciding whether a worktree is a merged worktree → you MUST NOT use which session created it, or whether the context was compacted since, as a criterion.
- A worktree fails any condition → you MUST NOT remove it.
- Removing a worktree → you MUST NOT pass `--force` to `git worktree remove` or use `git branch -D`.
- A worktree sits outside the worktree directory → you MUST NOT remove it.

### 6. Report

The work is merged and cleaned up → you MUST report it in this form:

```
Merged <feature-branch> into <target-branch> at <commit>; pushed to <remote> (or: no remote).
Verified: <check> on the merged tree.
Promoted: <item → location>; deleted: <workbench items>.
Removed: <branch> and <worktree path>, for each merged worktree; kept: <worktree path> — <failed condition>.
```

## Red Flags — STOP

You catch yourself thinking any thought in this table → you MUST stop and correct course:

| Thought | What to do instead |
|---|---|
| "I should ask whether to merge, open a PR, or keep the branch." | Merge into the target branch; the host's declared PR workflow is the only other path. |
| "I merged into an integration branch, not the mainline, so this skill does not apply." | The branch ends at that merge; run every step. |
| "Tests probably pass — I ran them earlier." | A run on this exact tree stands; no such run → run it now and read the output. |
| "There's no test command, so there's nothing to check." | Run the smallest proving check and name it in the report. |
| "The main checkout has someone's edits; I'll stash them." | Leave them; merge only what is yours. |
| "I'll keep the branch around in case." | Merge it; an unmerged branch is not finished work. |
| "The merge is done — I'll remove the worktree now." | The merged-tree check passes first. |
| "I'm inside the worktree; `git worktree remove` will sort it out." | `cd` to the main checkout first. |
| "This worktree is in the way, I'll just remove it." | Remove it only when it meets every merged-worktree condition. |
| "An earlier session created that merged worktree, so its provenance is uncertain." | Provenance is not a condition; check the five conditions. |

## Completion Checklist

Before calling the work finished → you MUST be able to check every applicable box:

- [ ] The completeness gate passed on the branch tree, and again on the merged tree.
- [ ] The workbench was emptied: durable conclusions promoted, in-flight artifacts deleted.
- [ ] The work was merged into the target branch, or a PR was opened under a declared host PR workflow.
- [ ] Nothing was asked of the user about integration or cleanup.
- [ ] The target branch was pushed where it tracks a remote.
- [ ] Every merged worktree was removed, worktree before branch, from the main checkout; every other worktree was kept.
- [ ] The report names the merge commit, the check, what was promoted and deleted, and what was removed.
