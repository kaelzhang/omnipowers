---
name: committing-work
description: Use when about to stage or commit anything — "commit this", "git commit", "save my work", "commit and push", splitting edits into commits, or ending a round with a dirty tree — you MUST form each commit deliberately and end the round committed and pushed.
---

# Committing Work

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
EVERY COMMIT IS ONE COHERENT CHANGE, CONTAINING ONLY PATHS YOU NAMED
```

- Cannot name the paths → you have not decided what the change is; decide it before staging.

## Scope

This skill governs forming **each individual commit**: what goes in it, how it is staged, what proves it, what its message says. It ends when the commit exists.

- Merging, pushing, opening a PR, keeping or discarding the branch, cleaning up a worktree → `finishing-a-development-branch`. "Commit and push" splits: this skill makes the commit, that one handles everything after it.
- Reviewing the change for defects, a checkpoint review of finished work → `code-auditing`. This skill checks that a commit coheres, not that the code is good.
- Conflict markers, "both modified", a stopped rebase → `resolving-merge-conflicts`; this skill resumes at the concluding commit of that operation.
- Any claim that work is done, fixed, or passing → `verification-before-completion`. The check required here MUST NOT be treated as having discharged that claim.
- Creating an isolated workspace → `using-git-worktrees`.

## The host owns the commands; this skill owns the discipline

Every git command shown here is illustrative. A convention the host declares governs *form* — staging mechanics, message shape, what is tracked — and MUST NOT be read as relaxing the Iron Law.

You have not yet resolved this project's convention → read `@host-convention.md` and apply it before your first commit here.


## 1. Decide the commit unit

- Each commit MUST represent one coherent logical change.
- Code, tests, docs, configuration, schema, and fixtures that complete the *same* change MAY travel in one commit.
- Tests and documentation MUST NOT be split from the implementation they describe.
- The round touched more than one independently reviewable unit → read `@splitting-a-round.md` and split the commits by unit or phase before committing.

- Pure renames, formatting-only passes, generated-artifact refreshes, dependency-lock refreshes, and large mechanical refactors MUST be committed separately from behavior changes, unless they cannot be verified independently.
- A mechanical commit MUST NOT hide a behavior change inside it.
- You MUST NOT include unrelated changes or pre-existing dirty work — your own earlier scratch edits, work another process or session left in the tree, a drive-by fix you noticed. Leave them alone and say so in your final response.

## 2. Stage explicitly by path

- Files MUST be staged by explicit path.
- These MUST NOT be used:
  - `git add -A` / `git add --all` / `git add .` / `git add :/`
  - `git add -u` / `git add --update`
  - `git commit -a` / `--all` / `-am` / `-aF` / `-a --amend`
- `git add <directory>` MAY be used ONLY when that directory is wholly owned by this commit's logical change. Otherwise name the files.
- Hunk-level staging (`git add -p` / `--patch`) MUST NOT be used. A file holds two logical changes → complete and commit one at a time.

## 3. Inspect before you commit

Before every commit you MUST:

1. Run `git status --short` and account for **every** entry — each one is either part of this commit or deliberately left out. An entry you cannot explain → stop; do not commit past it.
2. Read the full diff of what you are about to commit (`git diff --cached -- <paths>`).

- You MUST NOT commit a diff containing credentials, tokens, private keys, or other secrets.
- You SHOULD NOT commit debug prints, commented-out experiments, or machine-specific absolute paths.
- Before adding an untracked file, decide whether it belongs in history at all. Build outputs, generated artifacts, dependency directories, logs, caches, coverage output, local environment files, and editor/OS metadata MUST NOT be committed.
- You introduce something that produces such artifacts → its ignore rule MUST land in the same commit or earlier.
- Which paths the host ignores is the host's convention: extend its existing ignore file rather than inventing a parallel one.

## 4. Prove the commit coheres

Before each commit you MUST run the smallest check that proves this commit's contents hold together, and you MUST read its output. Running it and reading it is the `verification-before-completion` gate; one run satisfies both when you commit and claim in the same step. Smallest means smallest *sufficient*, scaled to what changed and to the host's tooling:

- prose or docs only — a whitespace/conflict-marker check (e.g. `git diff --check`) and a read of the result;
- code — the relevant tests, plus whatever type, lint, or build check the host requires for that area;
- configuration or schema — whatever parses or applies it.

- The check fails → you MUST either fix it or narrow the commit until what remains passes. A commit whose own contents do not hold together MUST NOT be made.
- An unmet *quality bar* is not a failed check → step 7 governs it.

## 5. Commit with an explicit pathspec

`git commit` MUST name the paths on the command line:

```bash
git commit -m "<subject>" -- path/to/file path/to/other
```

- Plain `git commit` with no pathspec MUST NOT be used — it takes the entire index, including paths staged by another process or left over from unrelated dirty work.
- A pathspec commit records the **working-tree** content of the named paths, not what you staged. You MUST NOT edit those paths between reading the diff and committing; you did → re-stage and re-read before committing.
- An amend that changes only the message names no paths. An amend that changes file content MUST carry a pathspec like any other commit. Both remain subject to History integrity below.
- **The one exception.** Git refuses a pathspec while a merge, rebase, cherry-pick, or revert is in progress (`fatal: cannot do a partial commit during a merge`). Concluding one of those → read `@mid-operation-commit.md` and follow its checklist before committing; that commit takes the whole index.

## 6. Write the message

Follow the convention resolved above. Whatever its form:

- The subject MUST name **what the commit changes**, not merely where.
- The message MUST stand alone. It MUST NOT depend on chat history, a conversation, a ticket only you can see, or your own session memory.
- **Non-obvious commits MUST include a body** covering three things: the problem or gap in current behavior, the solution chosen, and the verification performed. A material design choice was made → the body SHOULD also name the alternative rejected and why. A commit is "obvious" only when the diff alone answers *why*; you have to think about whether it is obvious → it is not.
- **Breaking changes MUST be marked** — by the host's marker if it has one, otherwise `!` after the type/scope in the subject or a `BREAKING CHANGE:` footer saying what breaks and what to do instead.

**Tool attribution is prohibited.**

- Commit messages MUST NOT credit a model, assistant, agent, CLI, harness, or runtime configuration — `Co-Authored-By:` naming a model or tool, `Generated-by:`, or any variant.
- You MUST NOT add yourself, your model name, your tool name, or your configuration to a commit message.
- Your harness appends such a trailer by default → you MUST remove it before committing.
- Such a trailer is already written and the commit is **not yet published** → you MUST amend it away.
- Trailers crediting *people* — a human co-author, reviewer, or reporter — are the host's convention to require or forbid, and are unaffected by this rule.

## 7. End the round committed and pushed

- A round of work that changes files MUST end with those changes committed **and pushed** before your final response, unless the user or the host's declared convention says otherwise. Keep working until the round is coherent, verified, and committed.
- You do not commit → you MUST state exactly what is left uncommitted and why. Nothing changed → you MUST say that explicitly rather than leave it ambiguous.
- An unmet quality bar — coverage below the host's target, a benchmark not yet met, a follow-up case not handled, a known blocker — MUST NOT be used as a reason to withhold the round's commits. Commit the coherent checkpoint and record the gap:
  1. in the commit body, stating plainly what is not yet met;
  2. at the code site, as a comment where the gap lives, when the gap has a site;
  3. in the host's `work-state` — the location its `Omnipowers` declaration names, otherwise wherever it already keeps plans and progress, otherwise `.omnipowers/`. Resolved by the host's existing habit or by the fallback rather than from the user or a declaration → confirm it with the user before the first such write in that project.
- Committing a checkpoint is never a claim that the work is complete. A blocker remains → commit first, then report the blocker and ask for direction. You MUST NOT present blocked work as finished.
- Once the round's commits exist you MUST push the current branch to its remote, and you MUST NOT ask whether to push or offer it as an option:
  - Push the **current branch** to its configured upstream. It has none → set one to the default remote under the same branch name (`git push -u origin <branch>`). You MUST NOT push a branch other than the one you worked on.
  - The host declares a `vcs` convention covering when or where work is published → that convention governs over this rule.
  - There is no remote at all → the round ends committed, and you MUST say so rather than reporting it as pushed.
  - The push is rejected (the remote moved ahead) → you MUST integrate and retry, and you MUST NOT reach for `--force` (see History integrity).
  - Report what landed: the branch, the remote, and the commits.

## History integrity

- You MUST NOT rewrite commits that others may already have — no amend, rebase, squash, or force-push over history published to a shared branch. Correct it with a new commit instead.
- You MUST NOT force-push without the user's explicit instruction, even on a branch you believe is yours alone.
- Unpublished local commits MAY be amended or reorganized freely.

## Red Flags — STOP

Any of these → stop; you are about to violate the Iron Law.

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

## Rationalizations

You notice yourself reasoning toward a shortcut at commit time → read `@rationalizing.md` and check the thought against it before acting.

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
