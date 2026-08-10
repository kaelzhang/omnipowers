# Fallback Commit Message Convention

> Normative keywords — MUST, MUST NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this **only** when the host project has no message convention of its own — no user instruction, no declared `vcs` convention, no contributor guide or commit-lint configuration, and no consistent shape in its existing history. If the host has any of those, it governs and this file does not apply.

This is the widely-used conventional-commit form. It is the fallback because it is machine-parseable, broadly tool-supported, and immediately recognizable in a project that has not decided otherwise — not because it is the only defensible convention.

## Subject

```text
type(scope): imperative summary
```

- The summary MUST be imperative ("add", "fix", "remove" — not "added", "adds", "fixing"), because every other subject in this form is, and a mixed log cannot be scanned.
- It MUST describe what the commit changes, specifically enough that a reader does not need the diff to know the subject matter.
- It MUST NOT end with a period.
- It SHOULD fit in roughly 72 characters so it renders unclipped in logs and review tools.

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

If two types both fit, the commit is probably two commits. Split it.

## Scope

The scope identifies the part of the project that changed — a module, package, service, app, subsystem, or documentation area.

The scope MUST NOT name an agent, model, assistant, tool, or runtime environment: the scope answers "where in the product", never "what produced this", and a tool-named scope makes the log unusable for finding changes by area.

If several scopes apply and the commit genuinely cannot be split further, use the narrowest shared parent. If no meaningful scope exists (a repository-wide change), omit it: `chore: raise the minimum supported toolchain version`.

Examples:

```text
docs(readme): document the retry backoff defaults
fix(checkout): reject a quantity change after payment authorization
refactor(auth): split credential verification out of the session store
perf(index): avoid re-sorting the whole index on every append
ci(release): fail the workflow when the version bump is missing
```

## Body

Separate the body from the subject with one blank line. Wrap at roughly 72 characters.

A body is REQUIRED whenever the diff does not answer *why*. It MUST cover:

1. **The gap** — the problem, or the way current behavior falls short.
2. **The solution** — what this commit does about it.
3. **The verification** — what was run, and what it showed.

Where a material design choice was made, the body SHOULD also name the alternative rejected and why. That is the fact future maintenance most often needs and least often has.

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

The footer form is preferred when the change needs migration instructions — say what breaks and what to do instead.

## Prohibited in every message

No model, assistant, agent, CLI, harness, or tool attribution trailer, in any form or spelling. Author and committer metadata already record provenance.
