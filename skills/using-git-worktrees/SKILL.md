---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from the current workspace, or before executing an implementation plan — you MUST ensure an isolated workspace exists via the host's native worktree tool or a git worktree fallback
---

# Using Git Worktrees

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, OPTIONAL — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Feature work in the current checkout risks the user's working branch. You MUST ensure the work happens in an isolated workspace before you begin.

**Core principle:** Detect existing isolation first. Then prefer the host's native worktree mechanism. Then fall back to git worktree. You MUST NOT create a redundant or nested worktree, and you MUST NOT fight a harness that already provides isolation.

## The Iron Law

```
DETECT ISOLATION FIRST — CREATE ONLY WHAT IS MISSING — VERIFY A CLEAN BASELINE
```

You MUST run Step 0 before creating anything. You MUST NOT skip straight to git worktree add. You MUST NOT claim the workspace is ready until tests establish a clean baseline (Step 3).

## When to Use

You MUST apply this skill when you begin feature work that needs isolation, or before you execute an implementation plan that will modify files.

## Step 0 — Detect Existing Isolation (REQUIRED first)

Before creating anything, you MUST determine whether you are already in an isolated workspace.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard (REQUIRED).** GIT_DIR != GIT_COMMON is also true inside a git submodule. Before concluding "already in a worktree," you MUST verify you are not in a submodule:

```bash
# If this returns a path, you are in a submodule, not a worktree — treat as a normal repo.
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If GIT_DIR != GIT_COMMON and NOT in a submodule:** you are already in a linked worktree. You MUST skip to Step 2 and you MUST NOT create another worktree. You MUST report: on a branch — "Already in isolated workspace at PATH on branch NAME"; detached HEAD — "Already in isolated workspace at PATH (detached HEAD, externally managed); branch creation needed at finish time."

**If GIT_DIR == GIT_COMMON (or in a submodule):** you are in a normal repo checkout. Go to the consent gate.

### Consent gate (REQUIRED before creating a worktree)

If the user has already declared a worktree preference (instructions, task, or this conversation), you MUST honor it without asking. Otherwise you MUST ask for consent and you MUST NOT create a worktree until the user agrees:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

If the user declines, you MUST work in place and skip to Step 2. You MUST NOT create a worktree against a declined or absent consent.

## Step 1 — Create the Isolated Workspace

You have two mechanisms. You MUST try them in this order: native first, git fallback second.

### 1a. Native worktree mechanism (preferred)

If the host provides a native way to create a worktree, you MUST use it and skip to Step 2. A native mechanism may appear as a dedicated tool (a name such as EnterWorktree or WorktreeCreate), a /worktree command, or a --worktree flag.

A native mechanism handles directory placement, branch creation, and cleanup, and keeps that state visible to the harness. Running git worktree add when a native mechanism exists creates phantom state the harness cannot manage; you MUST NOT do it. This is the single most common mistake — if a native mechanism is available, you MUST use it instead of git.

You MAY proceed to Step 1b ONLY when no native worktree mechanism is available in the host.

### 1b. Git worktree fallback

You MUST use this path only when Step 1a does not apply. You MUST create the worktree with git worktree, following the rules below.

#### Directory selection

You MUST resolve the directory by this priority; an explicit user preference always wins over filesystem state:

1. **Declared preference.** If the user specified a worktree directory, you MUST use it without asking.
2. **Existing project-local directory.** Otherwise detect one with `ls -d .worktrees 2>/dev/null` (preferred, hidden) or `ls -d worktrees 2>/dev/null`. If one exists, you MUST use it; if both, you MUST use `.worktrees`.
3. **Default.** With no other guidance, you MUST default to `.worktrees/` at the project root.

#### Safety verification (project-local directories only)

You MUST confirm the chosen project-local directory is git-ignored before creating a worktree inside it; otherwise its contents get tracked and can be committed by accident.

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

If it is NOT ignored, you MUST add it to `.gitignore` and commit that change before creating the worktree. You MUST NOT create a project-local worktree in an un-ignored directory.

#### Create the worktree

```bash
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback.** If git worktree add fails with a permission or sandbox-denial error, you MUST tell the user the sandbox blocked worktree creation and that you are working in the current directory instead. You MUST then run setup (Step 2) and baseline tests (Step 3) in place. You MUST NOT silently abandon isolation without telling the user.

## Step 2 — Project Setup

You MUST auto-detect the project type and run the matching dependency setup. If no recognized manifest is present, you MUST skip dependency installation rather than guess.

```bash
if [ -f package.json ];     then npm install; fi
if [ -f Cargo.toml ];       then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ];   then poetry install; fi
if [ -f go.mod ];           then go mod download; fi
```

You MUST use the project's actual toolchain when it differs from these patterns (a lockfile-pinned package manager, a Makefile target, a virtual-environment activation). The goal is a working dependency set, not a fixed command list.

## Step 3 — Verify a Clean Baseline (REQUIRED)

You MUST run the project's test suite to confirm the workspace starts clean, using the project-appropriate command (npm test, cargo test, pytest, or go test ./...). A clean baseline lets you attribute any later failure to your own change.

**If tests fail:** you MUST report the failures and ask the user whether to proceed or investigate first. You MUST NOT start implementation on an unexplained failing baseline without that explicit decision.

**If tests pass:** you MUST report ready, stating the worktree's full path, the passing test count with zero failures, and the feature you are about to implement.

## Quick Reference

| Situation | Required action |
|-----------|-----------------|
| Already in a linked worktree | Skip creation; go to Step 2 |
| In a submodule | Treat as a normal repo (Step 0 guard) |
| Normal checkout, no declared preference | Ask for consent before creating |
| Native worktree mechanism available | Use it (Step 1a) |
| No native mechanism | Git worktree fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists, no preference | Default to `.worktrees/` |
| Directory not ignored | Add to `.gitignore` + commit, then create |
| Permission or sandbox error | Tell the user; work in place |
| Tests fail during baseline | Report failures; ask before proceeding |
| No recognized manifest | Skip dependency install |

## Red Flags — STOP

If you catch yourself about to do any of these, you MUST stop:

- Creating a worktree when Step 0 already detected isolation, or nesting one inside an existing worktree.
- Using git worktree add when a native mechanism is available. This is the number-one mistake — if you have it, you MUST use it.
- Jumping to Step 1b without first checking for a native mechanism (Step 1a).
- Choosing a directory out of priority order (declared preference, then existing project-local directory, then default).
- Creating a project-local worktree without verifying it is ignored.
- Creating a worktree without consent in a normal checkout.
- Skipping the baseline test verification, or proceeding past a failing baseline without asking.

## The Bottom Line

Detect first. Prefer the native mechanism. Fall back to git only when there is none. Keep the worktree directory ignored, install dependencies, and prove a clean test baseline before writing feature code.</skill_md>
