---
name: committing-work
description: Use once per session, the first time you are about to stage or commit anything — "commit this", "git commit", "save my work", "commit and push", "提交", "推送", or ending a round with a dirty tree; it then governs every commit — you MUST form each commit deliberately and end the round committed and pushed.
---

# Committing Work

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Law

```
EVERY COMMIT IS ONE COHERENT CHANGE, CONTAINING ONLY PATHS YOU NAMED
```

## Scope

Commit formation — deciding each commit's contents, staging, coherence check, and message, ending when the commit exists.

Post-commit operations — merging into the mainline, opening a PR under a host PR workflow, and cleaning up a worktree, governed by `finishing-a-development-branch`.

Defect and checkpoint reviews — reviews governed by `code-auditing`.

Conflict resolution — conflict markers, "both modified", or a stopped rebase, governed by `resolving-merge-conflicts` until the concluding commit.

Completion claims — claims that work is done, fixed, or passing, governed by `verification-before-completion`.

Workspace isolation — creating an isolated workspace, governed by `using-git-worktrees`.

- Making a completion claim → you MUST NOT treat this skill's coherence check as having discharged that claim.

## The host owns the commands; this skill owns the discipline

Illustrative commands — git commands shown in this skill, whose form yields to the host's declared staging mechanics, message shape, and tracking convention.

- The host declares a convention → you MUST NOT read it as relaxing the Iron Law.

### Red flag — unresolved convention

| Thought | Command |
|---|---|
| You have not yet resolved this project's convention | read `@host-convention.md` and apply it before your first commit here. |

## 1. Decide the commit unit

- Forming a commit → it MUST represent one coherent logical change.
- Code, tests, docs, configuration, schema, and fixtures complete the same change → they MAY travel in one commit.
- Forming a commit → tests and documentation MUST NOT be split from the implementation they describe.
- Pure renames, formatting-only passes, generated-artifact refreshes, dependency-lock refreshes, and large mechanical refactors can be verified independently → they MUST be committed separately from behavior changes.
- Forming a mechanical commit → it MUST NOT hide a behavior change inside it.
- Forming a commit → you MUST NOT include unrelated changes or pre-existing dirty work, including your earlier scratch edits, work another process or session left in the tree, or a drive-by fix.

### Red flag — multiple commit units

| Thought | Command |
|---|---|
| The round touched more than one independently reviewable unit | read `@splitting-a-round.md` and split the commits by unit or phase before committing. |

## 2. Stage explicitly by path

- Staging files → files MUST be staged by explicit path.
- Staging or committing → these MUST NOT be used:
  - `git add -A` / `git add --all` / `git add .` / `git add :/`
  - `git add -u` / `git add --update`
  - `git commit -a` / `--all` / `-am` / `-aF` / `-a --amend`
- A directory is wholly owned by this commit's logical change → `git add <directory>` MAY be used ONLY under that condition.
- Staging files → hunk-level staging (`git add -p` / `--patch`) MUST NOT be used.

## 3. Inspect before you commit

Before every commit → you MUST:

1. Run `git status --short` and account for every entry as part of this commit or deliberately left out.
2. Read the full diff of what you are about to commit (`git diff --cached -- <paths>`).

- A diff contains credentials, tokens, private keys, or other secrets → you MUST NOT commit it.
- Forming a commit → you SHOULD NOT commit debug prints, commented-out experiments, or machine-specific absolute paths.
- Forming a commit → build outputs, generated artifacts, dependency directories, logs, caches, coverage output, local environment files, and editor/OS metadata MUST NOT be committed.
- You introduce something that produces such artifacts → its ignore rule MUST land in the same commit or earlier.
- A code file in this commit, first added to the repository on or after 2026-01-01, exceeds 1000 lines → you MUST split it by responsibility before committing.
- A documentation file (Markdown, docs) in this commit exceeds 2000 lines → you MUST split it by topic before committing.
- A host limit is higher than the applicable limit above → it MUST NOT be applied.
- A file is a data file (JSON, YAML, CSV, TOML data), configuration file, lockfile, generated code or artifact, vendored third-party code, test fixture, snapshot or golden file, database migration, or static lookup table → it MAY exceed both limits.
- A file belongs to one of those exempt types → you SHOULD NOT split it for length.

First-added date — the current date for a file added by this commit; for an existing file, the date of its first commit from `git log --diff-filter=A -- <file>`.

Applicable file-length limit — the host's declared limit for the file type when lower than this skill's limit; otherwise this skill's limit.

## 4. Prove the commit coheres

Smallest sufficient check — a check scaled to the changed contents and host tooling: whitespace/conflict-marker check (`git diff --check`) for prose or docs only; relevant tests plus host-required type, lint, or build checks for code; a parser or application check for configuration or schema.

Verification gate — running the check and reading its output, governed by `verification-before-completion`, including its rule on when a result stands.

- Before each commit → you MUST run the smallest check that proves its contents hold together.
- Before each commit → you MUST read the check's output.
- The check fails → you MUST either fix it or narrow the commit until what remains passes.
- A commit's own contents do not hold together → it MUST NOT be made.

## 5. Commit with an explicit pathspec

- Running `git commit` → it MUST name the paths on the command line:

```bash
git commit -m "<subject>" -- path/to/file path/to/other
```

- Outside the mid-operation exception → plain `git commit` with no pathspec MUST NOT be used.
- Between reading the diff and committing → you MUST NOT edit the named paths.
- An amend changes file content → it MUST carry a pathspec like any other commit.

Message-only amend — an amend naming no paths, subject to History integrity.

Mid-operation exception — a concluding commit of an in-progress merge, rebase, cherry-pick, or revert for which Git refuses a pathspec (`fatal: cannot do a partial commit during a merge`), recording the whole index.

### Red flag — concluding an operation

| Thought | Command |
|---|---|
| Concluding one of those operations | read `@mid-operation-commit.md` and follow its checklist before committing. |

## 6. Write the message

Obvious commit — a commit whose diff alone answers why, without requiring deliberation about whether it is obvious.

- Writing the subject → it MUST name what the commit changes, not merely where.
- Writing the message → it MUST stand alone.
- Writing the message → it MUST NOT depend on chat history, a conversation, a ticket only you can see, or your own session memory.
- A commit is non-obvious → it MUST include a body covering the problem or gap in current behavior, the solution chosen, and the verification performed.
- A material design choice was made → the body SHOULD also name the alternative rejected and why.
- A commit contains breaking changes → they MUST be marked by the host's marker if it has one, otherwise `!` after the type/scope in the subject or a `BREAKING CHANGE:` footer saying what breaks and what to do instead.
- Writing commit messages → they MUST NOT credit a model, assistant, agent, CLI, harness, or runtime configuration, including `Co-Authored-By:` naming a model or tool, `Generated-by:`, or any variant.
- Writing a commit message → you MUST NOT add yourself, your model name, your tool name, or your configuration.
- Your harness appends such a trailer by default → you MUST remove it before committing.
- Such a trailer is already written and the commit is not yet published → you MUST amend it away.

Human attribution — trailers crediting a human co-author, reviewer, or reporter, governed by the host's convention.

## 7. End the round committed and pushed

Unmet quality bar — coverage below the host's target, a benchmark not yet met, a follow-up case not handled, or a known blocker, distinct from a failed coherence check.

- A round changes files and neither the user nor the host's declared convention says otherwise → it MUST end with those changes committed and pushed before your final response.
- You do not commit → you MUST state exactly what is left uncommitted and why.
- Nothing changed → you MUST say that explicitly.
- A quality bar is unmet → it MUST NOT be used as a reason to withhold the round's commits.

**Gap record** — for an unmet quality bar: the commit body states plainly what is not yet met; a comment at the code site where the gap lives, when it has a site; an entry in the host's `work-state` document, located per `using-omnipowers`, fallback `.omnipowers/`.
- Work is blocked → you MUST NOT present it as finished.
The round's commits exist → you MUST push the current branch, MUST NOT ask whether to push or offer it as an option, and MUST NOT push a branch other than the one you worked on:

1. Push the current branch to its configured upstream; when none exists, set one to the default remote under the same branch name (`git push -u origin <branch>`).
2. Report what landed: the branch, the remote, and the commits.

- The host declares a `vcs` convention covering when or where work is published → that convention governs over this push rule.
- The round's commits exist and there is no remote → you MUST say the round ended committed rather than reporting it as pushed.
- The push is rejected after the remote moved ahead → you MUST integrate and retry.
- The push is rejected after the remote moved ahead → you MUST NOT reach for `--force` (see History integrity).

## History integrity

- Commits may already be held by others → you MUST NOT rewrite them through amend, rebase, squash, or force-push over history published to a shared branch.
- The user has not explicitly instructed a force-push → you MUST NOT force-push, including on a branch you believe is yours alone.
- Local commits are unpublished → they MAY be amended or reorganized freely.

## Red Flags — STOP

| Thought | Command |
|---|---|
| Cannot name the paths | decide the change before staging. |
| About to type `git add -A`, `git add .`, `git add -u`, or `git commit -a` | stop. |
| About to run `git commit` with no pathspec outside the named exception | stop. |
| Reaching for `git add -p` to separate two changes inside one file | complete and commit one at a time. |
| `git status` shows entries you cannot account for | stop before committing. |
| You have not read the diff, or edited the paths after reading it | re-stage and re-read before committing. |
| The message needs "and" to describe two unrelated things | stop. |
| A rename/format/generated-file diff contains a behavior change | stop. |
| "It's just a small change" | stop before committing without a check. |
| About to amend or force-push something already published | stop. |
| Ending the round with unpushed commits, or asking whether to push them | stop. |
| A model, agent, or tool attribution trailer is in the message | stop. |
| The round is ending with coherent changes uncommitted | stop. |

## Rationalizations

### Red flag — shortcut reasoning

| Thought | Command |
|---|---|
| You notice yourself reasoning toward a shortcut at commit time | read `@rationalizing.md` and check the thought against it before acting. |

## Before You Commit — checklist

Before committing → you MUST be able to check every box:

- [ ] This commit is one coherent logical change, statable in one sentence
- [ ] Tests, docs, and config that complete this change are in it; nothing unrelated is
- [ ] Mechanical changes are in their own commit, not folded into behavior
- [ ] Every path was staged explicitly; no bulk-stage command, no hunk staging
- [ ] `git status --short` read, and every entry accounted for
- [ ] The diff read in full; no secrets; nothing edited since reading it
- [ ] No code file added since 2026-01-01 exceeds 1000 lines, and no documentation file exceeds 2000 — or the host's lower limit
- [ ] The smallest check that proves coherence was run, and its output read
- [ ] The commit names its paths via pathspec (or is the one exception, with its checklist done)
- [ ] The subject names what changed; a body covers gap, solution, and verification where the change is non-obvious
- [ ] Breaking changes are marked
- [ ] No model, agent, or tool attribution trailer
- [ ] At the end of the round, the branch is pushed — and what landed was reported
- [ ] Nothing already published is being rewritten
