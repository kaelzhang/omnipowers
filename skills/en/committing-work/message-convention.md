# Fallback Commit Message Convention

> Normative keywords — MUST, MUST NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Fallback applicability — a host project with no message convention from user instructions, a declared `vcs` convention, a contributor guide, commit-lint configuration, or a consistent shape in existing history.

## Subject

```text
type(scope): imperative summary
```

- Writing the fallback summary → it MUST be imperative ("add", "fix", "remove" — not "added", "adds", "fixing").
- Writing the fallback summary → it MUST describe what the commit changes, specifically enough that a reader does not need the diff to know the subject matter.
- Writing the fallback summary → it MUST NOT end with a period.
- Writing the fallback summary → it SHOULD fit in roughly 72 characters.

## Types

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

## Scope

Scope — the changed module, package, service, app, subsystem, or documentation area.

- Writing the fallback scope → it MUST NOT name an agent, model, assistant, tool, or runtime environment.

## Body

The diff does not answer why → a body is REQUIRED.

Writing the fallback body → it MUST cover:

1. **The gap** — the problem, or the way current behavior falls short.
2. **The solution** — what this commit does about it.
3. **The verification** — what was run, and what it showed.

A material design choice was made → the body SHOULD also name the alternative rejected and why.

Writing the fallback body → it MUST stand alone: no reference to a conversation, a session, a private note, or anything a reader holding only the repository cannot see.

## Breaking changes

```text
feat(config)!: require an explicit timeout unit
```

```text
feat(config): require an explicit timeout unit

BREAKING CHANGE: bare numeric timeouts are rejected at startup instead
of being read as seconds. Add an explicit unit suffix (`30s`, `500ms`)
to every timeout value.
```
