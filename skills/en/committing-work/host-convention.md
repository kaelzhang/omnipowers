# Resolving the Host's Commit Convention

> Normative keywords — MUST, MUST NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Resolved convention — the project's staging mechanics, message form, and tracked-file policy, resolved at its first commit and governing subsequent commits, using the first applicable source in this order:

1. The user's statement in this session.
2. The `vcs` row of the host's `Omnipowers` declaration, located per `using-omnipowers`.
3. The host's contributor guide, commit template, commit-lint configuration, or consistent recent history.
4. This skill's fallback.

Convention authority — form only, overriding skill defaults without relaxing the Iron Law or authorizing attribution trailers through silence.

Fallback subject — `type(scope): imperative summary`, imperative, naming what changed, with no trailing period, when the host has no message convention.

Illustrative commands — git commands shown in this skill, subject to the resolved convention.

## Red flag — fallback details needed

| Thought | Command |
|---|---|
| Need the full fallback — the closed list of allowed types, how to pick or omit a scope, the body's required content, the breaking-change markers | read `@message-convention.md` and apply it. |
