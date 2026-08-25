# Fallback Commit Message Convention

> Normative keywords — MUST, MUST NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this **only** when the host project has no message convention of its own — no user instruction, no declared `vcs` convention, no contributor guide or commit-lint configuration, and no consistent shape in its existing history. The host has any of those → it governs, and this file does not apply.

This is the conventional-commit form.

## Subject

```text
type(scope): imperative summary
```

- The summary MUST be imperative ("add", "fix", "remove" — not "added", "adds", "fixing").
- It MUST describe what the commit changes, specifically enough that a reader does not need the diff to know the subject matter.
- It MUST NOT end with a period.
- It SHOULD fit in roughly 72 characters.

## Types

Use exactly one:

| type | use for |
|---|---|
| `feat` | a new user-facing or API-facing capability |
| `fix` | a bug fix |
| `docs` | documentation only |
| `test` | tests only |
| `refactor` | behavior-preserving restructuring |
| `perf` | a performance improvement |
| `style` | formatting-only source change, no semantics |
| `build` | build system, packaging, dependencies, generated build metadata |
| `ci` | continuous-integration configuration |
| `chore` | repository maintenance not covered above |
| `revert` | reverting an earlier commit |

Two types both fit → the commit is probably two commits; split it.

## Scope

The scope identifies the part of the project that changed — a module, package, service, app, subsystem, or documentation area.

- The scope MUST NOT name an agent, model, assistant, tool, or runtime environment.
- Several scopes apply and the commit genuinely cannot be split further → use the narrowest shared parent.
- No meaningful scope exists (a repository-wide change) → omit it: `chore: raise the minimum supported toolchain version`.

## Body

Separate the body from the subject with one blank line. Wrap at roughly 72 characters.

A body is REQUIRED whenever the diff does not answer *why*. It MUST cover:

1. **The gap** — the problem, or the way current behavior falls short.
2. **The solution** — what this commit does about it.
3. **The verification** — what was run, and what it showed.

Where a material design choice was made, the body SHOULD also name the alternative rejected and why.

The body MUST stand alone: no reference to a conversation, a session, a private note, or anything a reader holding only the repository cannot see.

## Breaking changes

Mark them one of two ways:

```text
feat(config)!: require an explicit timeout unit
```

```text
feat(config): require an explicit timeout unit

BREAKING CHANGE: bare numeric timeouts are rejected at startup instead
of being read as seconds. Add an explicit unit suffix (`30s`, `500ms`)
to every timeout value.
```

The change needs migration instructions → the footer form is preferred; say what breaks and what to do instead.

## Prohibited in every message

No model, assistant, agent, CLI, harness, or tool attribution trailer, in any form or spelling.
