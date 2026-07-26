---
name: resolving-merge-conflicts
description: Use when resolving conflicts in an in-progress git merge, rebase, or cherry-pick — conflict markers in files, "both modified" status, "fix conflicts and then run git rebase --continue", a merge or rebase that stopped partway — you MUST trace both sides of every hunk to their source commits and resolve by intent, never by text
---

# Resolving Merge Conflicts

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A correctly resolved merge carries forward what **both** parent branches were trying to do — or, where that is truly impossible, deliberately follows the merge's stated goal and records what it gave up. The conflict markers are a symptom. The real object of resolution is the two intents behind them.

**Core principle:** A conflict hunk shows you two texts, but it is asking you about two intents. You cannot answer from the text alone.

This skill governs every conflicted git operation: merge, rebase, and cherry-pick. The discipline applies **per hunk**, not per file.

## The Iron Law

```
RESOLVE BY INTENT, NOT BY TEXT — NEVER INVENT BEHAVIOR IN A CONFLICT HUNK
```

The merge commit is the one commit that no branch's tests have ever seen. Behavior invented inside a conflict hunk ships with no review, no test, and no commit message explaining it — it is the most dangerous place in the repository to be creative.

## Step 1 — Survey the Operation

Before touching any hunk you MUST establish:

- **What operation is in progress and its direction.** `git status` names the operation and the conflicted files; for a rebase, `git rebase --show-current-patch` shows the commit being replayed.
- **The merge's stated goal** — why this merge/rebase is happening (the user's request, the branch's purpose). Incompatible intents are settled against this goal, so you MUST know it before resolving anything.
- **Side orientation.** In a merge, "ours" is the current branch and "theirs" is the branch being merged in. In a **rebase this reverses**: "ours" is the branch you are rebasing *onto*, "theirs" is your own commit being replayed. You MUST confirm which side is which first — getting it backwards makes every subsequent judgment favor the wrong branch.

## Step 2 — Per-Hunk Intent Archaeology

For **every** conflict hunk you MUST trace both sides to their source and answer, in one sentence per side, "what was this side trying to do?" — *before* writing the resolution. A hunk you cannot explain both sides of is a hunk you are not yet allowed to resolve; keep digging.

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

You MUST read the commit message and diff of the commit that introduced each side's change — the message states the intent; the diff shows its full extent (a hunk is often one fragment of a larger rename, refactor, or fix, and resolving the fragment against its siblings breaks the whole).

Consequence of skipping the archaeology: you resolve a symptom you do not understand, and the losing side's bug fix or feature silently vanishes from history while every tool reports success.

## The Resolution Contract

Every hunk's resolution MUST satisfy all three clauses:

1. **Compatible intents → preserve BOTH.** When both sides' goals can coexist (one renamed a parameter, the other added validation), the resolution MUST express both. Dropping one side silently reverts a change that already landed and was already depended on.
2. **Genuinely incompatible → follow the merge's stated goal, and record the sacrifice.** When the intents truly cannot coexist, resolve in favor of the side that serves the goal from Step 1, and you MUST record the sacrificed intent in the merge/rebase commit message (what was given up, from which commit, and why). An unrecorded sacrifice is deleted work with no trace — the next person re-derives it from nothing.
3. **You MUST NOT invent behavior that neither side had.** The resolution vocabulary is exactly: side A's behavior, side B's behavior, or a combination of the two. "While I'm here" improvements, new guards, new logic — none of it belongs in a conflict hunk. If the merge reveals something worth changing, finish the merge faithfully and make that change in its own commit where it can be reviewed.

## Forbidden Shortcuts

- You MUST NOT blind-resolve: no `git checkout --ours <file>` / `--theirs <file>`, no `-X ours` / `-X theirs`, no editor "accept all current/incoming". These discard one branch's work wholesale without ever reading it.
- You MUST NOT concatenate both sides to "keep everything". Two texts pasted together duplicates statements, registers handlers twice, runs migrations twice. Combining *intents* is design work; stacking *texts* is not.
- You MUST NOT pick a side by proxy signals — newer timestamp, bigger diff, "main is probably right", your own branch by default. None of these measure intent; they measure churn and habit.

## When the Merge Itself Looks Wrong

You MUST NOT `--abort` because the conflicts are numerous, tedious, or hard. Difficulty is not evidence that the merge is wrong — it is evidence that the branches diverged, which is exactly what merges are for. Aborting to dodge the work abandons an operation the user asked for and leaves the divergence for someone else.

You MAY abort ONLY when **both** hold:

1. The archaeology reveals the operation itself may be mistaken — wrong merge base, a half-landed refactor on one side, a branch that was already merged, the wrong target branch — not merely that resolution is laborious; **and**
2. The user explicitly decides to abort after you present the situation via the confirming-with-the-user skill: the evidence you found, the options (including continuing anyway), each option's impact, and your recommendation.

Until both conditions are met, the operation stays in progress and you keep resolving.

## After the Last Hunk — Verify

A conflict-free compile is NOT correctness. Two branches that were each green on their own can merge textually clean and semantically broken — one side renamed a function while the other added a call to the old name; one changed a default the other now silently relies on. Git only detects *textual* overlap; the semantic conflicts are yours to find, and they can live in files that never showed a marker.

You MUST discover the host project's own checks and run them in order — typecheck/build → tests → format/lint — and you MUST fix what the merge broke before finishing. Breakage that appears at the merge is the merge's responsibility; you MUST NOT wave it off as pre-existing. The verification-before-completion skill governs any "merge is done / tests pass" claim: run the checks and read their output before asserting success.

## Finish the Operation

A resolved-but-uncommitted merge is not done — the repository is still in a special state and the next command anyone runs may destroy the work.

- You MUST stage every resolved file and commit. For a merge, put the clause-2 sacrifice records in the merge commit message.
- For a rebase, `git rebase --continue` — and you MUST repeat this entire discipline for every subsequent commit that conflicts, until **all** commits are replayed. Stopping midway strands the branch half-rebased.

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
- The resolution contains a line that appears on neither side and in neither combination
- You kept both sides by pasting them one after the other
- You chose a side because it was newer, bigger, or "probably main"
- You are declaring the merge done while markers, `MERGE_HEAD`, or a rebase directory remain
- You are claiming success without having run the project's checks

## Rationalizations — Rejected

| Excuse | Reality |
|--------|---------|
| "Too many conflicts — `--abort` and let someone else handle it" | Abort is not an escape from difficulty. The one permitted abort path requires evidence the merge itself is wrong *and* the user's explicit decision. |
| "Keep both sides so nothing is lost" | Concatenated text is not combined intent — it double-executes, double-registers, double-declares. Merge the goals, not the strings. |
| "Theirs is newer, take it" | Recency is not correctness. The older side's change landed for a reason that is still in force until you prove otherwise. |
| "Their diff is bigger, that must be the real change" | Size measures churn, not intent. A one-line fix loses to a hundred-line rename by this rule — and the bug comes back. |
| "It compiles cleanly, the merge is fine" | The merge commit is the one commit no branch ever tested. Semantic conflicts compile; run the checks. |
| "This hunk is trivial, skip the history" | Trivial-looking hunks hide renames and moved logic. One `git show` costs seconds; a mis-resolved "trivial" hunk costs a production incident. |
| "I'll take ours and re-add their part from memory" | Reconstruction from memory is invention. Take their part from `git show`, not from recollection. |
| "The tests that broke were probably already failing" | Verify that claim against the parent branches. If they were green before the merge, the merge broke them and the merge fixes them. |

## Final Rule

```
Merge resolved → every hunk explained (both intents), the contract satisfied,
                 checks green, the operation committed / continued to the end
Otherwise      → not resolved; keep digging
```
