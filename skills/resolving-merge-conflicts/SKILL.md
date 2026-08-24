---
name: resolving-merge-conflicts
description: Use when resolving conflicts in an in-progress git merge, rebase, or cherry-pick — conflict markers in files, "both modified" status, "fix conflicts and then run git rebase --continue", a merge or rebase that stopped partway — you MUST trace both sides of every hunk to their source commits and resolve by intent, never by text
---

# Resolving Merge Conflicts

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- This skill governs every conflicted git operation: merge, rebase, and cherry-pick.
- The discipline applies **per hunk**, not per file.

## The Iron Law

```
RESOLVE BY INTENT, NOT BY TEXT — NEVER INVENT BEHAVIOR IN A CONFLICT HUNK
```

## Step 1 — Survey the Operation

Before touching any hunk you MUST establish:

- **What operation is in progress and its direction.** `git status` names the operation and the conflicted files; for a rebase, `git rebase --show-current-patch` shows the commit being replayed.
- **The merge's stated goal** — why this merge/rebase is happening (the user's request, the branch's purpose). You MUST know it before resolving anything.
- **Side orientation.** In a merge, "ours" is the current branch and "theirs" is the branch being merged in. In a **rebase this reverses**: "ours" is the branch you are rebasing *onto*, "theirs" is your own commit being replayed. You MUST confirm which side is which first.

## Step 2 — Per-Hunk Intent Archaeology

For **every** conflict hunk you MUST trace both sides to their source and answer, in one sentence per side, "what was this side trying to do?" — *before* writing the resolution.

Tools for the dig:

```bash
git log --merge --oneline -- <file>   # commits from both sides that touched this file
git show :1:<file>                    # common ancestor (base) version
git show :2:<file>                    # "ours" version
git show :3:<file>                    # "theirs" version
git log -p <base>..<side> -- <file>   # each side's full change history with diffs
git blame <side> -- <file>            # which commit introduced each conflicting line
git show <commit>                     # the introducing commit: message + full diff
```

You MUST read the commit message and diff of the commit that introduced each side's change.

You need a side's content → take it from `git show`, never from recollection.

## The Resolution Contract

Every hunk's resolution MUST satisfy all three clauses:

1. **Compatible intents → preserve BOTH.** Both sides' goals can coexist → the resolution MUST express both.
2. **Genuinely incompatible → follow the merge's stated goal, and record the sacrifice.** The intents truly cannot coexist → resolve in favor of the side that serves the goal from Step 1, and you MUST record the sacrificed intent in the merge/rebase commit message (what was given up, from which commit, and why).
3. **You MUST NOT invent behavior that neither side had.** The resolution vocabulary is exactly: side A's behavior, side B's behavior, or a combination of the two. The merge reveals something worth changing → finish the merge faithfully and make that change in its own commit.

## Forbidden Shortcuts

- You MUST NOT blind-resolve: no `git checkout --ours <file>` / `--theirs <file>`, no `-X ours` / `-X theirs`, no editor "accept all current/incoming".
- You MUST NOT concatenate both sides to "keep everything".
- You MUST NOT pick a side by proxy signals — newer timestamp, bigger diff, "main is probably right", your own branch by default.

## When the Merge Itself Looks Wrong

You MUST NOT `--abort` because the conflicts are numerous, tedious, or hard.

You MAY abort ONLY when **both** hold:

1. The archaeology reveals the operation itself may be mistaken — wrong merge base, a half-landed refactor on one side, a branch that was already merged, the wrong target branch — not merely that resolution is laborious; **and**
2. The user explicitly decides to abort after you present the situation via the confirming-with-the-user skill: the evidence you found, the options (including continuing anyway), each option's impact, and your recommendation.

Both conditions are not met → the operation stays in progress and you keep resolving.

## After the Last Hunk — Verify

A conflict-free compile is NOT correctness; semantic conflicts can live in files that never showed a marker.

- You MUST discover the host project's own checks and run them in order — typecheck/build → tests → format/lint — and you MUST fix what the merge broke before finishing.
- Breakage that appears at the merge is the merge's responsibility; you MUST NOT wave it off as pre-existing. You suspect a broken check was already failing → verify that against the parent branches; green before the merge → the merge broke it and this merge fixes it.
- The verification-before-completion skill governs any "merge is done / tests pass" claim: run the checks and read their output before asserting success.

## Finish the Operation

- You MUST stage every resolved file and commit. For a merge, put the clause-2 sacrifice records in the merge commit message. Conclude with the operation's own continuation command (`git merge --continue`, `git cherry-pick --continue`) where one exists; that commit takes the whole index. Before you run it you MUST check `git status` and leave unstaged — or stash — anything that is not part of the operation, including another agent's work in the same tree. A host convention that restricts how commits are staged still applies to everything except this one unavoidable whole-index commit.
- For a rebase, `git rebase --continue` — and you MUST repeat this entire discipline for every subsequent commit that conflicts, until **all** commits are replayed.

**Completion checklist** — you MUST be able to check every box:

- [ ] No conflict markers remain (`git grep -n "^<<<<<<<"` over the worktree comes back empty)
- [ ] Every hunk: both intents identified *before* it was resolved
- [ ] Every sacrificed intent is recorded in the commit message
- [ ] The project's checks ran and passed; you read the output
- [ ] No merge state remains: `git rev-parse -q --verify MERGE_HEAD` fails, and neither `.git/rebase-merge` nor `.git/rebase-apply` exists
- [ ] For a rebase: all commits replayed; the operation fully concluded

## Red Flags — STOP

If any of these is happening, stop and return to the discipline:

- You are about to run `--abort` because this is hard
- You are typing `checkout --ours`, `checkout --theirs`, or reaching for "accept all"
- You resolved a hunk without being able to state what each side was trying to do
- You skipped the history on a hunk because it looked trivial
- You re-added a side's part from memory instead of from `git show`
- The resolution contains a line that appears on neither side and in neither combination
- You kept both sides by pasting them one after the other
- You chose a side because it was newer, bigger, or "probably main"
- You are declaring the merge done while markers, `MERGE_HEAD`, or a rebase directory remain
- You are claiming success without having run the project's checks
- You are dismissing a failing check as pre-existing without checking the parent branches

## Final Rule

```
Merge resolved → every hunk explained (both intents), the contract satisfied,
                 checks green, the operation committed / continued to the end
Otherwise      → not resolved; keep digging
```
