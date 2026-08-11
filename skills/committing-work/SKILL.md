---
name: committing-work
description: Use when about to stage or commit anything — "commit this", "git commit", "save my work", "commit and push", splitting edits into commits, or ending a round with a dirty tree — you MUST make each commit one coherent logical change staged path by path (never `git add -A`/`.`/`-u`, never `git commit -a`, never hunk staging), read the diff you are committing, run the smallest check that proves it coheres, write a standalone message with no tool attribution trailer, and push the branch when the round ends rather than asking whether to
---

# Committing Work

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

A commit is a unit of review, revert, bisect, and understanding — not a save point. Whatever a commit contains, a reviewer must read together, a maintainer must revert together, and a bisect must trust together.

**Core principle:** a commit's contents are chosen deliberately, path by path. Anything that lands in a commit because it merely happened to be in the working tree is a defect, not a convenience.

## The Iron Law

```
EVERY COMMIT IS ONE COHERENT CHANGE, CONTAINING ONLY PATHS YOU NAMED
```

Two clauses, one idea: you decide what the change *is*, then you name exactly the paths that constitute it. If you cannot name the paths, you have not decided what the change is.

## Scope — and what this skill is not

This skill governs forming **each individual commit**: what goes in it, how it is staged, what proves it, and what its message says. It ends when the commit exists.

It is NOT:

- **finishing a branch** — merging, pushing, opening a PR, keeping or discarding the branch, cleaning up a worktree. That is `finishing-a-development-branch`. "Commit and push" splits: this skill makes the commit, that one handles everything after it.
- **reviewing the change for defects** — a checkpoint review of finished work is `code-auditing`. This skill checks that a commit *coheres*, not that the code is good.
- **resolving conflicts** — conflict markers, "both modified", a stopped rebase. That is `resolving-merge-conflicts`. This skill resumes at the concluding commit of that operation.
- **claiming the work is correct** — `verification-before-completion` governs any claim that work is done, fixed, or passing. The check required here proves this commit's contents hold together and MUST NOT be treated as having discharged that claim.
- **creating an isolated workspace** — that is `using-git-worktrees`.

## The host owns the commands; this skill owns the discipline

Every git command shown here is illustrative. The host project's version-control convention governs the concrete staging mechanics, the message form, and which files are tracked at all. Resolve it in this order, stopping at the first that applies:

1. what the user states in this session;
2. the host's `Omnipowers` declaration — a section by that name in its `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — its `vcs` row;
3. what the host already does: its contributor guide, commit template, commit-lint configuration, or the consistent shape of its recent history;
4. the fallback stated in this skill.

A declared convention overrides this skill's defaults. When step 3 yields no message convention either, read @message-convention.md and apply it as the fallback.

What the host governs is *form*. It does not relax the Iron Law, and a convention that merely says nothing about attribution does not authorize the trailers prohibited below.

## 1. Decide the commit unit

Each commit MUST represent one coherent logical change. A commit that does not is one no reviewer can read in one sitting and no maintainer can revert without collateral damage.

**Travelling together.** A logical change MAY span code, tests, docs, configuration, schema, and fixtures when they complete the *same* change. Tests and documentation MUST NOT be split from the implementation they describe: a file-extension difference is not a logical boundary, and splitting them leaves a commit in history that does not build, does not pass, or documents behavior that does not exist yet.

**Splitting a round.** When a round of work touches units that can be reviewed and verified independently — separate services, packages, modules, layers, or migration phases — you MUST split the commits by unit or phase, because one commit spanning them can be neither reverted nor bisected without dragging unrelated work with it. Separate unless review or verification genuinely cannot proceed independently:

- one component vs. another that does not depend on it;
- a shared contract or interface change vs. each consumer's adoption of it;
- schema migration scaffolding vs. the behavior that uses it;
- regenerated artifacts vs. the handwritten source that generates them;
- housekeeping (ignore rules, formatting, file moves) vs. product behavior.

Where several valid splits exist, pick the one that simplifies review, rollback, and recovery — that choice is judgment, the requirement to split is not.

**Mechanical vs. behavioral.** Pure renames, formatting-only passes, generated-artifact refreshes, dependency-lock refreshes, and large mechanical refactors MUST be committed separately from behavior changes, unless they cannot be verified independently. A mechanical commit MUST NOT hide a behavior change inside it — a four-thousand-line rename diff is where a real change goes to become invisible, and reviewers approve it unread.

**No unrelated bundling.** You MUST NOT include unrelated changes or pre-existing dirty work in a commit — not your own earlier scratch edits, not work another process or session left in the tree, not a drive-by fix you noticed. Leave them alone and say so in your final response. A commit that carries someone else's half-finished work publishes it without their consent and cannot be reverted without reverting theirs.

## 2. Stage explicitly by path

Files MUST be staged by explicit path. These commands MUST NOT be used, because they select by working-tree state rather than by your decision, and will sweep in unrelated edits, another process's uncommitted work, or files you have never read:

- `git add -A` / `git add --all` / `git add .` / `git add :/`
- `git add -u` / `git add --update`
- `git commit -a` / `--all` / `-am` / `-aF` / `-a --amend`

`git add <directory>` MAY be used ONLY when that directory is wholly owned by this commit's logical change. Otherwise, name the files.

**Hunk-level staging (`git add -p` / `--patch`) MUST NOT be used.** Reaching for it is a diagnosis, not a technique: it means one file now holds two logical changes, and you are trying to repair at commit time what should have been sequenced at edit time. It also produces a commit whose content never existed as a working tree — the half you left behind was never built, never run, never tested alongside the half you shipped, and a bisect will land on it. When a file holds two changes, complete and commit one at a time.

## 3. Inspect before you commit

Before every commit you MUST:

1. Run `git status --short` and account for **every** entry — each one is either part of this commit or deliberately left out. An entry you cannot explain is a stop signal, not noise; committing past it is how foreign work gets published under your name.
2. Read the full diff of what you are about to commit (`git diff --cached -- <paths>`).

You MUST NOT commit a diff containing credentials, tokens, private keys, or other secrets — once pushed, a secret is compromised regardless of any later commit that removes it, and the only real remedy is rotation. You SHOULD NOT commit debug prints, commented-out experiments, or machine-specific absolute paths; each of them either misleads the next reader or breaks in every other checkout.

**New files.** Before adding an untracked file, decide whether it belongs in history at all. Build outputs, generated artifacts, dependency directories, logs, caches, coverage output, local environment files, and editor/OS metadata MUST NOT be committed — they bloat the repository, conflict on every rebuild, and local environment files routinely carry secrets. When you introduce something that produces them, its ignore rule MUST land in the same commit or earlier, or every later `git status` is noise and the artifacts get swept in. Which paths the host ignores is the host's convention: extend its existing ignore file rather than inventing a parallel one.

## 4. Prove the commit coheres

Before each commit you MUST run the smallest check that proves this commit's contents hold together, and you MUST read its output. Committing an unverified tree plants a landmine that every future bisect and every future revert steps on.

Smallest means smallest *sufficient*, scaled to what changed — which check that is depends on the host's tooling and the touched area:

- prose or docs only — a whitespace/conflict-marker check (e.g. `git diff --check`) and a read of the result;
- code — the relevant tests, plus whatever type, lint, or build check the host requires for that area;
- configuration or schema — whatever parses or applies it.

If the check fails, you MUST either fix it or narrow the commit until what remains passes; a commit whose own contents do not hold together MUST NOT be made. This is distinct from an unmet *quality bar* — see step 7, which requires you to commit anyway and record the gap.

## 5. Commit with an explicit pathspec

`git commit` MUST name the paths on the command line:

```bash
git commit -m "<subject>" -- path/to/file path/to/other
```

Plain `git commit` with no pathspec MUST NOT be used: it commits the entire index, including paths staged by another process or left over from unrelated dirty work, and silently violates the Iron Law. A pathspec-limited commit takes only the listed paths and leaves every other index entry untouched, so concurrent work in the same tree stays out of your commit.

A pathspec commit records the **working-tree** content of the named paths, not what you staged. You MUST NOT edit those paths between reading the diff and committing; if you do, re-stage and re-read before committing, otherwise you ship content you never reviewed.

An amend that changes only the message names no paths because it commits no file content. An amend that changes file content MUST carry a pathspec like any other commit, and both remain subject to History integrity below.

**The one exception.** You MAY omit the pathspec ONLY when Git itself refuses one — the concluding commit of an in-progress merge, rebase, cherry-pick, or revert (`fatal: cannot do a partial commit during a merge`). That commit takes the **whole index**, so before making it you MUST:

1. run `git status --short` and identify every entry that is not part of the operation;
2. stash or unstage each of them;
3. use the operation's own continuation command where one exists (`git merge --continue`, `git rebase --continue`, `git cherry-pick --continue`).

Skipping this checklist commits whatever else was in the tree into someone else's merge, where nobody will ever look for it.

## 6. Write the message

Follow the convention resolved above. Whatever its form, these hold, because the reader is a maintainer years from now holding the repository and nothing else:

- The subject MUST name **what the commit changes**, not merely where. A subject that names only the area ("update parser") forces every future reader to open the diff to learn anything.
- The message MUST stand alone. It MUST NOT depend on chat history, a conversation, a ticket only you can see, or your own session memory — none of that reaches the reader.
- **Non-obvious commits MUST include a body** covering three things: the problem or gap in current behavior, the solution chosen, and the verification performed. Where a material design choice was made, the body SHOULD also name the alternative rejected and why — that is the single fact future maintenance most often lacks. A commit is "obvious" only when the diff alone answers *why*; if you have to think about whether it is obvious, it is not.
- **Breaking changes MUST be marked** so downstream consumers can find them mechanically — by the host's marker if it has one, otherwise `!` after the type/scope in the subject or a `BREAKING CHANGE:` footer saying what breaks and what to do instead. An unmarked breaking change reaches consumers as an outage.

**Tool attribution is prohibited.** Commit messages MUST NOT credit a model, assistant, agent, CLI, harness, or runtime configuration — `Co-Authored-By:` naming a model or tool, `Generated-by:`, or any variant. You MUST NOT add yourself, your model name, your tool name, or your configuration to a commit message, and where your harness appends such a trailer by default you MUST remove it before committing. It misattributes authorship of the change and turns history into an attribution log for tooling that will outlive none of it; author and committer metadata already record provenance. Where such a trailer has already been written and the commit is **not yet published**, you MUST amend it away. Trailers crediting *people* — a human co-author, reviewer, or reporter — are the host's convention to require or forbid, and are unaffected by this rule.

## 7. End the round committed and pushed

A round of work that changes files MUST end with those changes committed **and pushed** before your final response, unless the user or the host's declared convention says otherwise. Keep working until the round is coherent, verified, and committed. Coherent work left uncommitted is work the next session inherits as an unexplained dirty tree — and routinely loses. If you do not commit, you MUST state exactly what is left uncommitted and why; if nothing changed, you MUST say that explicitly rather than leave it ambiguous.

**Commit-readiness is coherence, not completion.** An unmet quality bar — coverage below the host's target, a benchmark not yet met, a follow-up case not handled, a known blocker — MUST NOT be used as a reason to withhold the round's commits. Withholding turns the round into all-or-nothing and puts real work one crash away from gone. Instead, commit the coherent checkpoint and record the gap where it will be looked for:

1. in the commit body, stating plainly what is not yet met;
2. at the code site, as a comment where the gap lives, when the gap has a site;
3. in the host's `work-state` — the location its `Omnipowers` declaration names, otherwise wherever it already keeps plans and progress, otherwise `.omnipowers/` — so the next session sees it without reading history. When you resolve that location by the host's existing habit or by the fallback rather than from the user or a declaration, confirm it with the user before the first such write in that project.

Committing a checkpoint is never a claim that the work is complete. If a blocker remains, commit first, then report the blocker and ask for direction — you MUST NOT present blocked work as finished.

**Push is part of ending the round, not a separate decision.** Once the round's commits exist you MUST push the current branch to its remote, and you MUST NOT ask whether to push or offer it as an option. A commit that lives only in one working copy is one disk failure from gone and invisible to everyone else. Concretely:

- Push the **current branch** to its configured upstream. If it has none, set one to the default remote under the same branch name (`git push -u origin <branch>`). You MUST NOT push a branch other than the one you worked on.
- Where the host declares a `vcs` convention covering when or where work is published, that convention governs over this rule.
- If there is no remote at all, the round ends committed, and you MUST say so rather than reporting it as pushed.
- If the push is rejected (the remote moved ahead), you MUST integrate and retry rather than leaving the round half-published — and you MUST NOT reach for `--force` to resolve it (see History integrity).
- Report what landed: the branch, the remote, and the commits. A round reported as done with commits sitting unpushed is a false completion claim.

Pushing publishes: it makes the commits visible to everyone with access to that remote, and on a public repository that is everyone. That is the intended effect of this rule, and it is why the message and staging discipline above is not optional — what you push is what the world reads.

## History integrity

You MUST NOT rewrite commits that others may already have — no amend, rebase, squash, or force-push over history that has been published to a shared branch. Published history is shared state: rewriting it breaks every clone that has it and costs collaborators work that was never yours to risk. Correct it with a new commit instead.

You MUST NOT force-push without the user's explicit instruction, even on a branch you believe is yours alone. Unpublished local commits MAY be amended or reorganized freely.

## Red Flags — STOP

Any of these means you are about to violate the Iron Law:

- about to type `git add -A`, `git add .`, `git add -u`, or `git commit -a`
- about to run `git commit` with no pathspec outside the one named exception
- reaching for `git add -p` to separate two changes inside one file
- `git status` shows entries you cannot account for, and you commit anyway
- you have not read the diff you are about to commit — or you edited those files after reading it
- the commit message needs "and" to describe two unrelated things
- a rename/format/generated-file diff with a behavior change tucked inside it
- committing without running any check because "it's just a small change"
- about to amend or force-push something already published
- ending the round with commits sitting unpushed, or asking the user whether to push them
- a model, agent, or tool attribution trailer in the message you are about to write
- the round is ending and coherent changes are still uncommitted

## Rationalizations — rejected

| Excuse | Reality |
|---|---|
| "`git add .` is faster, the tree is clean" | You established it was clean by not looking. Bulk staging is how another process's work gets published under your name. |
| "It's all one feature, one commit is fine" | If two parts can be reviewed or reverted independently, they are two commits. Bundling makes both unrevertable. |
| "I'll add the tests in a follow-up commit" | Then this commit's entry in history does not pass. Tests travel with the implementation. |
| "The rename is trivial, I'll fold it in" | Trivial diffs are large diffs, and large diffs are where real changes go unreviewed. Split it. |
| "`git add -p` lets me keep it clean" | It produces a commit that never existed as a working state. Sequence the edits instead. |
| "Plain `git commit` — nothing else is staged" | You are asserting that about a tree you did not inspect and processes you do not control. Name the paths. |
| "The quality bar isn't met, I shouldn't commit yet" | Commit the coherent checkpoint and record the gap. Withholding risks the whole round. |
| "I'll leave it uncommitted so the user can look first" | An uncommitted tree is neither reviewable nor durable. Commit, then point at the commit. |
| "The message is obvious from the diff" | The diff shows what. The body exists for why, and why is the part that is lost. |
| "My harness adds the trailer automatically" | Then remove it before committing. Automatic is not authorized. |
| "It's already pushed but nobody has pulled" | You cannot know that. Fix forward with a new commit. |
| "Tests passed earlier in the session" | Run the smallest check now, against what you are actually committing. |

## Before You Commit — checklist

You MUST be able to check every box:

- [ ] This commit is one coherent logical change, statable in one sentence
- [ ] Tests, docs, and config that complete this change are in it; nothing unrelated is
- [ ] Mechanical changes are in their own commit, not folded into behavior
- [ ] Every path was staged explicitly; no bulk-stage command, no hunk staging
- [ ] `git status --short` read, and every entry accounted for
- [ ] The diff read in full; no secrets; nothing edited since reading it
- [ ] The smallest check that proves coherence was run, and its output read
- [ ] The commit names its paths via pathspec (or is the one exception, with its checklist done)
- [ ] The subject names what changed; a body covers gap, solution, and verification where the change is non-obvious
- [ ] Breaking changes are marked
- [ ] No model, agent, or tool attribution trailer
- [ ] At the end of the round, the branch is pushed — and what landed was reported
- [ ] Nothing already published is being rewritten

## The Bottom Line

```
Decide the change → name the paths → read the diff → prove it coheres → commit by pathspec → push
Anything that arrives in a commit because it was lying around is a defect
A round that ends with commits still only on your disk is a round that did not end
```
