---
name: resolving-merge-conflicts
description: Use when resolving conflicts in an in-progress git merge, rebase, or cherry-pick — conflict markers in files, "both modified" status, "fix conflicts and then run git rebase --continue", a merge or rebase that stopped partway — you MUST trace both sides of every hunk to their source commits and resolve by intent, never by text
---

# Resolving Merge Conflicts

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Scope

Conflicted operation — a git merge, rebase, or cherry-pick with conflicts.
Discipline unit — each conflict hunk, rather than each file.
Merge's stated goal — the user's request or branch purpose for the merge or rebase.
Merge side orientation — "ours" is the current branch; "theirs" is the branch being merged in.
Rebase side orientation — "ours" is the branch being rebased onto; "theirs" is the commit being replayed.
Resolution vocabulary — side A's behavior, side B's behavior, or a combination of the two.

## The Iron Law

```
RESOLVE BY INTENT, NOT BY TEXT — NEVER INVENT BEHAVIOR IN A CONFLICT HUNK
```

## Step 1 — Survey the Operation

Before touching any hunk → you MUST establish:

- The operation in progress and its direction.
- The merge's stated goal.
- Side orientation.

Before resolving anything → you MUST know the merge's stated goal.
Before resolving a hunk → you MUST confirm which side is which.

## Step 2 — Per-Hunk Intent Archaeology

For every conflict hunk, before writing its resolution → you MUST trace both sides to their source and answer, in one sentence per side, "what was this side trying to do?"

### History Commands

```bash
git log --merge --oneline -- <file>   # commits from both sides that touched this file
git show :1:<file>                    # common ancestor (base) version
git show :2:<file>                    # "ours" version
git show :3:<file>                    # "theirs" version
git log -p <base>..<side> -- <file>   # each side's full change history with diffs
git blame <side> -- <file>            # which commit introduced each conflicting line
git show <commit>                     # the introducing commit: message + full diff
```

For each side's change → you MUST read the introducing commit's message and diff.

## The Resolution Contract

For every hunk → its resolution MUST satisfy all three clauses:

1. Both sides' goals can coexist → preserve both intents in the resolution.
2. The intents cannot coexist → resolve in favor of the side that serves the merge's stated goal.
3. The merge reveals something worth changing → finish the merge faithfully and make that change in its own commit.

Both sides' goals can coexist → the resolution MUST express both.
The intents cannot coexist → you MUST record the sacrificed intent in the merge/rebase commit message: what was given up, from which commit, and why.
For every hunk's resolution → you MUST NOT invent behavior that neither side had.

## Forbidden Shortcuts

- When resolving a conflict → you MUST NOT blind-resolve with `git checkout --ours <file>` / `--theirs <file>`, `-X ours` / `-X theirs`, or editor "accept all current/incoming".
- When resolving a conflict → you MUST NOT concatenate both sides to "keep everything".
- When choosing a side → you MUST NOT use proxy signals: newer timestamp, bigger diff, "main is probably right", or your own branch by default.

## When the Merge Itself Looks Wrong

The conflicts are numerous, tedious, or hard → you MUST NOT `--abort` on those grounds.

Abort eligibility — both of the following states:

1. The archaeology reveals the operation itself may be mistaken: wrong merge base, a half-landed refactor on one side, a branch that was already merged, or the wrong target branch, rather than laborious resolution alone.
2. The user explicitly decides to abort after you present the evidence, options (including continuing anyway), each option's impact, and your recommendation via the confirming-with-the-user skill.

When abort eligibility holds → you MAY abort ONLY under those conditions.

## After the Last Hunk — Verify

- After resolving the last hunk → you MUST discover the host project's own checks and run them in order: typecheck/build → tests → format/lint.
- Before finishing → you MUST fix what the merge broke.
- Breakage appears at the merge → you MUST NOT dismiss it as pre-existing.

## Finish the Operation

- After resolving the conflicts → you MUST stage every resolved file and commit.
- Before running the operation's continuation command → you MUST check `git status` and leave unstaged — or stash — anything outside the operation, including another agent's work in the same tree.
- During a rebase → you MUST repeat this entire discipline for every subsequent commit that conflicts, until all commits are replayed.

### Completion Checklist

Before claiming completion → you MUST be able to check every box:

- [ ] No conflict markers remain (`git grep -n "^<<<<<<<"` over the worktree comes back empty)
- [ ] Every hunk: both intents identified *before* it was resolved
- [ ] Every sacrificed intent is recorded in the commit message
- [ ] The project's checks ran and passed; you read the output
- [ ] No merge state remains: `git rev-parse -q --verify MERGE_HEAD` fails, and neither `.git/rebase-merge` nor `.git/rebase-apply` exists
- [ ] For a rebase: all commits replayed; the operation fully concluded

## Final Rule

```
Merge resolved → every hunk explained (both intents), the contract satisfied,
                 checks green, the operation committed / continued to the end
Otherwise      → not resolved; keep digging
```
