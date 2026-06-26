---
name: finishing-a-development-branch
description: Use when a feature branch's work is done and verified and you're ready to wrap it up — merge it, open a PR, ship it, keep it, or discard it (incl. cleaning up the worktree/branch) — you MUST verify tests pass, then present the integration options and let the user choose before any merge, push, or deletion
---

# Finishing a Development Branch

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

When implementation is complete, the integration step decides whether the work lands, waits, or is thrown away — and whether the workspace is left clean or corrupted. This skill removes the discretion from that step.

**Core principle:** Verify tests → detect the workspace → determine the base → present structured options → execute the choice → clean up only what you created.

You MUST NOT decide the integration path on the user's behalf. The choice between merging, opening a PR, keeping the branch, and discarding is the user's; your job is to verify the work is safe to integrate, lay out the options precisely, and carry out the one the user picks.

## The Iron Law

```
NO INTEGRATION WITHOUT GREEN TESTS, AND NO DESTRUCTIVE ACTION WITHOUT EXPLICIT USER CHOICE
```

You MUST NOT merge, push, delete a branch, or remove a worktree until the test suite passes in this session and the user has chosen the action. You MUST NOT collapse the menu to a single assumed answer.

## The Process

You MUST execute these phases in order. You MUST NOT present options before tests pass and the workspace is detected.

### Phase 1 — Verify Tests (REQUIRED gate)

Before presenting any option, you MUST run the project's test suite and read its output in this session.

```bash
# Run the project's test command — examples; use the project's actual command:
npm test        # or: cargo test | pytest | go test ./... | make test
```

If the suite fails, you MUST stop. You MUST NOT proceed to Phase 2. Report the failures plainly:

```
Tests failing (<N> failures). These MUST be fixed before integrating:

<failures>

Integration is blocked until the suite is green.
```

You MAY proceed to Phase 2 ONLY when the suite passes. If the project genuinely has no test suite, you MUST state that explicitly to the user and obtain their acknowledgement before continuing; "there are no tests" MUST NOT be inferred silently from a missing command.

### Phase 2 — Detect the Workspace

You MUST determine the workspace shape before choosing a menu, because it dictates which options are valid and how cleanup works.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
HEAD_REF=$(git symbolic-ref -q --short HEAD || echo "DETACHED")
```

Classify the workspace using this table. You MUST use the matching row:

| State | Menu | Cleanup |
|---|---|---|
| `GIT_DIR == GIT_COMMON` (plain repo, named branch) | Full 4-option menu | No worktree exists — branch-only cleanup |
| `GIT_DIR != GIT_COMMON` (worktree), named branch | Full 4-option menu | Provenance-based cleanup (Phase 6) |
| `GIT_DIR != GIT_COMMON` (worktree), detached HEAD | Reduced 3-option menu (no local merge) | No cleanup — workspace is externally managed |

A detached HEAD in a worktree means the host environment manages this workspace. You MUST NOT offer a local merge in that state, and you MUST NOT remove that workspace yourself.

### Phase 3 — Determine the Base Branch

You MUST establish the base branch NAME the work will integrate into before offering a merge or PR — it is consumed downstream as `<base-branch>` in `git checkout` / `git merge`, so it MUST be a branch name, not a commit SHA.

```bash
# Resolve the base branch NAME (prefers main, then master):
BASE=$(git rev-parse --verify --quiet main >/dev/null && echo main \
  || (git rev-parse --verify --quiet master >/dev/null && echo master))
```

If `BASE` comes back empty, the base is ambiguous, or the project uses a different integration branch, you MUST confirm it with the user (for example: "This branch split from `main` — is that the correct base?") rather than guessing. Do not feed a `git merge-base` commit SHA where a branch name is required.

### Phase 4 — Present the Options (let the user choose)

You MUST present the options as a concise, numbered menu and then wait for the user's choice. You MUST NOT add commentary, recommend one option as "what I'll do", or execute any option before the user selects it.

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

If the host project's policy is unknown — single maintainer vs. team, merge-direct vs. PR-required — you MUST NOT assume one. The menu presents both the merge and the PR paths; the user's choice is authoritative.

### Phase 5 — Execute the Chosen Option

You MUST execute only the option the user selected, using the steps below.

#### Option: Merge Locally

You MUST verify the merge succeeds and re-run tests on the merged result before deleting anything.

```bash
# Run worktree commands and branch deletion from the main checkout, never from
# inside a worktree that is about to be removed.
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git checkout <base-branch>
# Pull only if the base tracks a remote — a local-only branch has no upstream
# and `git pull` would error mid-sequence.
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>

# Re-run the project's test command on the merged result. If it fails, STOP —
# do not delete the branch or the worktree.
```

After the merge succeeds AND tests on the merged result pass, in this order:
1. Clean up the worktree (Phase 6).
2. Delete the branch:

```bash
git branch -d <feature-branch>
```

You MUST NOT delete the branch before removing the worktree that references it — `git branch -d` will fail while a worktree still holds the branch.

#### Option: Push and Open a PR

```bash
git push -u origin <feature-branch>
```

Then open the PR using the host project's mechanism (for example a `gh pr create` command, or the project's review workflow). If no PR tooling is available, you MUST report the pushed branch and its remote so the user can open the PR through their own platform.

You MUST NOT clean up the worktree for this option — the user needs it alive to iterate on PR feedback.

#### Option: Keep As-Is

You MUST NOT push, merge, or remove anything. Report the state:

```
Keeping branch <name>. Worktree preserved at <path> (if any).
```

#### Option: Discard (REQUIRED confirmation gate)

Discarding is destructive and irreversible. You MUST obtain a typed confirmation first:

```
This will permanently delete:
- Branch <name>
- These commits: <commit-list>
- Worktree at <path> (if any)

Type 'discard' to confirm.
```

You MUST wait for the exact word `discard`. Any other response means do not delete. You MUST NOT proceed on a vague "yes", "ok", or silence.

After confirmation:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then clean up the worktree (Phase 6) and force-delete the branch:

```bash
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
- **`WORKTREE_PATH` is under `.worktrees/` or `worktrees/` AND you created this worktree in this session** — you own it; remove it. The path is only a heuristic: a host environment can also provision worktrees under `.worktrees/` (it is the sibling worktree convention's default location), so a path match alone is NOT proof of ownership. If you did not create this worktree this session, or provenance is uncertain, you MUST NOT remove it — fall through to the host-owned case below. When you do own it, you MUST `cd` to the main checkout first, because `git worktree remove` fails when the current directory is inside the worktree being removed:

  ```bash
  MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
  cd "$MAIN_ROOT"
  git worktree remove "$WORKTREE_PATH"
  git worktree prune   # self-healing: clear any stale worktree registrations
  ```

- **Otherwise (including any uncertain-provenance worktree)** — the host environment owns this workspace. You MUST NOT remove it; removing a host-owned workspace corrupts host state. If the host provides a workspace-exit mechanism, use it; otherwise leave the workspace in place and report that the host owns it.

## Quick Reference

| Option | Merge | Push | Keep worktree | Delete branch |
|---|---|---|---|---|
| Merge locally | yes | — | — | yes (`-d`) |
| Open PR | — | yes | yes | — |
| Keep as-is | — | — | yes | — |
| Discard | — | — | — | yes (`-D`, after typed confirm) |

## Red Flags — STOP

You MUST stop and correct course if you are about to:

- Present options before the test suite is green — unless the project has no suite AND the user has explicitly acknowledged that (the Phase 1 exception); a missing test command MUST NOT be silently treated as "no tests".
- Merge, or open a PR, without verifying tests on the result.
- Pick an integration path for the user instead of presenting the menu.
- Delete a branch or discard work without the typed `discard` confirmation.
- Force-push without the user's explicit request.
- Remove a worktree before confirming the merge succeeded.
- Remove a worktree you did not create this session, or whose provenance is uncertain — a `.worktrees/` / `worktrees/` path alone does not prove you own it.
- Run `git worktree remove` from inside the worktree being removed.
- Delete a branch before removing the worktree that references it.

## Rationalizations — rejected

| Excuse | Reality |
|--------|---------|
| "Tests probably pass, I just ran them earlier" | Run them now and read the output. "Earlier" is not this session. |
| "It's a single-maintainer repo, just merge it" | You MUST NOT assume the policy. Present the menu; let the user choose. |
| "The user clearly wants a PR" | Present the options and let them say so. Inference is not consent. |
| "I'll clean up the worktree now to be tidy" | Only Merge and Discard clean up. PR and Keep MUST preserve it. |
| "`yes` is good enough to discard" | Destructive deletion requires the exact typed word `discard`. |
| "The merge looks fine, skip the re-test" | A clean merge can still break the suite. Re-run tests on the merged result. |
| "I'll delete the branch first, then the worktree" | `git branch -d` fails while a worktree holds the branch. Worktree first. |
| "This worktree is in the way, I'll just remove it" | If you did not create it, the host owns it. Removing it corrupts host state. |

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

## The Bottom Line

Verify the work is green, lay out the options precisely, do exactly what the user chooses, and clean up only what you made. No assumed policy, no unconfirmed deletion, no orphaned or corrupted workspace.
