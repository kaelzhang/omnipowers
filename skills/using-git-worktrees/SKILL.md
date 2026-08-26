---
name: using-git-worktrees
description: Use when starting feature work or executing a plan that must stay isolated from the current branch/checkout, or when asked to set up a git worktree or separate workspace — you MUST ensure an isolated workspace exists via the host's native worktree tool or a git worktree fallback
---

# Using Git Worktrees

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

- You MUST ensure the work happens in an isolated workspace before you begin.
- You MUST NOT create a redundant or nested worktree.
- You MUST NOT fight a harness that already provides isolation.

## The Iron Law

```
DETECT ISOLATION FIRST — CREATE ONLY WHAT IS MISSING — VERIFY A CLEAN BASELINE
```

- You MUST run Step 0 before creating anything.
- You MUST NOT skip straight to git worktree add.
- You MUST NOT claim the workspace is ready until tests establish a clean baseline (Step 3).

## When to Use

You begin feature work that needs isolation, or you are about to execute an implementation plan that will modify files → you MUST apply this skill.

## The Host's Isolation Rules (REQUIRED before Step 0)

You MUST read the host project's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — and honor its `isolation` row where it has one:

- **The declared unit governs.** The host names its isolation unit (a worktree, a branch, or a shared checkout isolated only by explicit commit paths) → you MUST use that unit and MUST NOT substitute another.
- **Declared mainline-only paths MUST stay on the mainline.** A host MAY name paths that MUST NOT be copied into an isolated workspace. Such paths are declared → you MUST read and write them in the mainline checkout, never in the worktree.
- **Nothing declared → this skill's own rules apply**, and you proceed to Step 0.

## Returning to the Mainline (MANDATORY)

- The work is complete and verified → you MUST return it to the mainline — merged, or pushed and opened for review as the host requires. You MUST NOT report work as done while it sits only in an isolated workspace. The `finishing-a-development-branch` skill governs how; it is not installed → follow the host's own branch-completion process.
- Before any handoff — to another agent, another session, or the user — you MUST return to the mainline first, and you MUST NOT defer that return to the recipient.

## Step 0 — Detect Existing Isolation (REQUIRED first)

Before creating anything, you MUST determine whether you are already in an isolated workspace.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

A linked worktree is the only context where `GIT_DIR != GIT_COMMON`. A plain submodule keeps `GIT_DIR == GIT_COMMON` (both resolve to `.git/modules/<name>`) and takes the normal-checkout branch below.

**GIT_DIR != GIT_COMMON** — you are already in a linked worktree. You MUST skip to Step 2 and you MUST NOT create another worktree. You MUST report:

- on a branch — "Already in isolated workspace at PATH on branch NAME";
- detached HEAD — "Already in isolated workspace at PATH (detached HEAD, externally managed); branch creation needed at finish time."

**GIT_DIR == GIT_COMMON** — you are in a normal repo checkout (this includes a plain submodule) → go to the consent gate.

### Consent gate (REQUIRED before creating a worktree)

- The host declared an `isolation` unit → you MUST use it without asking. That declaration is the answer to this gate.
- The user declared a worktree preference (instructions, task, or this conversation) → you MUST honor it without asking.
- Neither → you MUST ask for consent, and you MUST NOT create a worktree until the user agrees:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

- The user declines → you MUST work in place and skip to Step 2.
- You MUST NOT create a worktree against a declined or absent consent.

## Step 1 — Create the Isolated Workspace

You have two mechanisms. You MUST try them in this order: native first, git fallback second.

### 1a. Native worktree mechanism (preferred)

- The host provides a native way to create a worktree → you MUST use it and skip to Step 2. A native mechanism may appear as a dedicated tool (a name such as EnterWorktree or WorktreeCreate), a /worktree command, or a --worktree flag.
- A native mechanism exists → you MUST NOT run git worktree add.
- You MAY proceed to Step 1b ONLY when no native worktree mechanism is available in the host.

### 1b. Git worktree fallback

You MUST use this path only when Step 1a does not apply. You MUST create the worktree with git worktree, following the rules below.

#### Directory selection

You MUST resolve the directory by this priority and bind the result to `LOCATION`; an explicit user preference always wins over filesystem state:

1. **Declared preference.** The user specified a worktree directory → you MUST use it without asking.
2. **Existing project-local directory.** Otherwise detect one with `ls -d .worktrees 2>/dev/null` or `ls -d worktrees 2>/dev/null`. One exists → you MUST use it; both exist → you MUST use `.worktrees`.
3. **Default.** No other guidance → you MUST default to `.worktrees/` at the project root.

#### Safety verification (project-local directories only)

You MUST confirm the chosen project-local directory is git-ignored before creating a worktree inside it. You MUST run the check against the single directory you selected (`$LOCATION`), not a fixed OR over both candidate names.

```bash
git check-ignore -q "$LOCATION" 2>/dev/null
```

- NOT ignored → you MUST add it to `.gitignore` and commit that change before creating the worktree.
- You MUST NOT create a project-local worktree in an un-ignored directory.

#### Create the worktree

You MUST bind both variables before running the block: `LOCATION` is the directory chosen above and `BRANCH_NAME` is derived from the feature or plan you are isolating. You MUST assign concrete values, not copy the block verbatim.

```bash
LOCATION=.worktrees                # the directory chosen by the priority list above
BRANCH_NAME=feature/<derived-name> # derived from the feature or plan
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback.** git worktree add fails with a permission or sandbox-denial error → you MUST tell the user the sandbox blocked worktree creation and that you are working in the current directory instead. You MUST then run setup (Step 2) and baseline tests (Step 3) in place. You MUST NOT silently abandon isolation without telling the user.

## Step 2 — Project Setup

You MUST auto-detect the project type and run the matching dependency setup. No recognized manifest is present → you MUST skip dependency installation rather than guess.

```bash
if [ -f package.json ];     then npm install; fi
if [ -f Cargo.toml ];       then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ];   then poetry install; fi
if [ -f go.mod ];           then go mod download; fi
```

You MUST use the project's actual toolchain when it differs from these patterns (a lockfile-pinned package manager, a Makefile target, a virtual-environment activation).

## Step 3 — Verify a Clean Baseline (REQUIRED)

You MUST run the project's test suite to confirm the workspace starts clean. The commands `npm test`, `cargo test`, `pytest`, and `go test ./...` are illustrative only; the project declares its own test command (a Makefile target, a lockfile-pinned runner, a configured script) → you MUST use that instead.

- **Tests fail** → you MUST report the failures and ask the user whether to proceed or investigate first. You MUST NOT start implementation on an unexplained failing baseline without that explicit decision.
- **Tests pass** → you MUST report ready, stating the worktree's full path, the passing test count with zero failures, and the feature you are about to implement.

## Red Flags — STOP

If you catch yourself about to do any of these, you MUST stop:

- Creating a worktree when Step 0 already detected isolation, or nesting one inside an existing worktree.
- Using git worktree add when a native mechanism is available.
- Jumping to Step 1b without first checking for a native mechanism (Step 1a).
- Choosing a directory out of priority order (declared preference, then existing project-local directory, then default).
- Creating a project-local worktree without verifying it is ignored.
- Creating a worktree without consent in a normal checkout.
- Skipping the baseline test verification, or proceeding past a failing baseline without asking.
