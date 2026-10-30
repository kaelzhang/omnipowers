---
name: using-git-worktrees
description: Use when starting feature work or executing a plan that must stay isolated from the current branch/checkout, or when asked to set up a git worktree or separate workspace — you MUST ensure an isolated workspace exists via the host's native worktree tool or a git worktree fallback
---

# Using Git Worktrees

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- Before beginning work → you MUST ensure the work happens in an isolated workspace.
- When creating a worktree → you MUST NOT create a redundant or nested worktree.
- When a harness already provides isolation → you MUST NOT fight that harness.

## The Iron Law

```
DETECT ISOLATION FIRST — CREATE ONLY WHAT IS MISSING — VERIFY A CLEAN BASELINE
```

- Before creating anything → you MUST run Step 0.
- You MUST NOT skip straight to git worktree add.
- Until tests establish a clean baseline (Step 3) → you MUST NOT claim the workspace is ready.

## When to Use

You begin feature work that needs isolation, or you are about to execute an implementation plan that will modify files → you MUST apply this skill.

## The Host's Isolation Rules (REQUIRED before Step 0)

Host isolation declaration — the host's `isolation` row, located per `using-omnipowers`.

- Before Step 0 → you MUST read the host isolation declaration and honor it when present.
- The host names its isolation unit (a worktree, a branch, or a shared checkout isolated only by explicit commit paths) → you MUST use that unit.
- The host names its isolation unit → you MUST NOT substitute another.
- The host declares mainline-only paths → those paths MUST stay on the mainline.
- When declaring isolation → a host MAY name mainline-only paths.
- The host names mainline-only paths → those paths MUST NOT be copied into an isolated workspace.
- The host declares mainline-only paths → you MUST read and write them in the mainline checkout, never in the worktree.

## Returning to the Target Branch (MANDATORY)

Branch-return process — `finishing-a-development-branch`, which defines the target branch and removes the worktree, or the host's own branch-completion process when that skill is not installed.

- The work is complete and verified → you MUST return it to its target branch through the branch-return process — merged, or pushed and opened for review as the host requires.
- The work sits only in an isolated workspace → you MUST NOT report it as done.
- Before any handoff to another agent, another session, or the user → you MUST return to the target branch first.
- Before any handoff → you MUST NOT defer that return to the recipient.

## Step 0 — Detect Existing Isolation (REQUIRED first)

Before creating anything → you MUST determine whether you are already in an isolated workspace.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

Linked worktree — a workspace where `GIT_DIR != GIT_COMMON`.

Normal checkout — a workspace where `GIT_DIR == GIT_COMMON`, including a plain submodule whose variables both resolve to `.git/modules/<name>`.

- `GIT_DIR != GIT_COMMON` → you MUST skip to Step 2.
- `GIT_DIR != GIT_COMMON` → you MUST NOT create another worktree.
- `GIT_DIR != GIT_COMMON` → you MUST report using the matching template:

- on a branch — "Already in isolated workspace at PATH on branch NAME";
- detached HEAD — "Already in isolated workspace at PATH (detached HEAD, externally managed); branch creation needed at finish time."

### Isolation decision (REQUIRED before creating a worktree)

- The host declared an `isolation` unit → you MUST use it without asking.
- The user declared a worktree preference (instructions, task, or this conversation) → you MUST honor it without asking.
- The host declared no `isolation` unit and the user declared no worktree preference → you MUST create the isolated workspace through Step 1.
- Deciding whether to create a worktree → you MUST NOT ask the user.

## Step 1 — Create the Isolated Workspace

When creating an isolated workspace → you MUST try the mechanisms in this order: native first, git fallback second.

### 1a. Native worktree mechanism (preferred)

Native worktree mechanism — a host-provided tool, command, or flag for worktree creation.

- The host provides a native way to create a worktree → you MUST use it and skip to Step 2.
- A native mechanism exists → you MUST NOT run git worktree add.
- No native worktree mechanism is available in the host → you MAY proceed to Step 1b ONLY under that condition.

### 1b. Git worktree fallback

- When selecting the git worktree fallback → you MUST use this path only when Step 1a does not apply.
- When using the git worktree fallback → you MUST create the worktree with git worktree, following the rules below.

#### Directory selection

When selecting the worktree directory → you MUST resolve it by this priority and bind the result to `LOCATION`:

1. **Declared preference.** The host's `isolation` declaration or the user names a worktree directory → you MUST use it without asking.
2. **Existing project-local directory.** Neither names a worktree directory → you MUST detect an existing directory with `ls -d .worktrees 2>/dev/null` or `ls -d worktrees 2>/dev/null`. Neither names a worktree directory, and exactly one of `.worktrees` or `worktrees` exists → you MUST use it. Neither names a worktree directory, and both exist → you MUST use `.worktrees`.
3. **Default.** Neither names a worktree directory, and neither `.worktrees` nor `worktrees` exists → you MUST default to `.worktrees/` at the project root.

#### Safety verification (project-local directories only)

- Before creating a worktree inside the chosen project-local directory → you MUST confirm that directory is git-ignored.
- When checking whether the chosen project-local directory is git-ignored → you MUST run the check against the single directory you selected (`$LOCATION`), not a fixed OR over both candidate names.

```bash
git check-ignore -q "$LOCATION" 2>/dev/null
```

- The chosen project-local directory is not git-ignored → you MUST add it to `.gitignore` and commit that change before creating the worktree.
- The project-local directory is not git-ignored → you MUST NOT create a worktree inside it.

#### Create the worktree

`LOCATION` — the directory chosen above.

`BRANCH_NAME` — a name derived from the feature or plan being isolated.

- Before running the block → you MUST bind both variables.
- When binding the variables → you MUST assign concrete values, not copy the block verbatim.

```bash
LOCATION=.worktrees                # the directory chosen by the priority list above
BRANCH_NAME=feature/<derived-name> # derived from the feature or plan
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

- git worktree add fails with a permission or sandbox-denial error → you MUST tell the user the sandbox blocked worktree creation and that you are working in the current directory instead.
- After reporting that permission or sandbox-denial error → you MUST run setup (Step 2) and baseline tests (Step 3) in place.
- When abandoning isolation after a permission or sandbox-denial error → you MUST NOT do so without telling the user.

## Step 2 — Project Setup

- At Step 2 → you MUST auto-detect the project type and run the matching dependency setup.
- No recognized manifest is present → you MUST skip dependency installation rather than guess.

```bash
if [ -f package.json ];     then npm install; fi
if [ -f Cargo.toml ];       then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ];   then poetry install; fi
if [ -f go.mod ];           then go mod download; fi
```

The project's actual toolchain differs from these patterns (a lockfile-pinned package manager, a Makefile target, a virtual-environment activation) → you MUST use that toolchain.

## Step 3 — Verify a Clean Baseline (REQUIRED)

- Before implementation → the workspace MUST start from a clean baseline established by a suite pass on this exact commit in this session or the project's CI, or by running the project's test suite when no such pass exists.
- The suite already passed on this exact commit in this session or the project's CI → you MUST cite that baseline.
- The project declares its own test command (a Makefile target, a lockfile-pinned runner, a configured script) → you MUST use that instead of `npm test`, `cargo test`, `pytest`, or `go test ./...`.

- **Tests fail** → you MUST record the failing tests and their output as the pre-existing baseline in the ready report.
- **Tests fail** → you MUST NOT ask the user whether to proceed or investigate.
- A baseline failure exists → you MUST NOT attribute it to your change in later verification.
- **Tests pass** → you MUST report ready, stating the worktree's full path, the passing test count with zero failures, and the feature you are about to implement.

## Red Flags — STOP

When about to take any action listed below → you MUST stop:

- Creating a worktree when Step 0 already detected isolation, or nesting one inside an existing worktree.
- Using git worktree add when a native mechanism is available.
- Jumping to Step 1b without first checking for a native mechanism (Step 1a).
- Choosing a directory out of priority order (declared preference, then existing project-local directory, then default).
- Creating a project-local worktree without verifying it is ignored.
- Asking the user whether to create a worktree.
- Skipping the baseline test verification, or proceeding past a failing baseline without recording it.
