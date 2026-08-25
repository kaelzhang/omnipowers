# Resolving the Host's Commit Convention

> Normative keywords — MUST, MUST NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this once per project, the first time you commit in it. The resolved convention governs every commit after.

Every git command shown here is illustrative. Resolve the concrete staging mechanics, the message form, and which files are tracked at all in this order, stopping at the first that applies:

1. what the user states in this session;
2. the host's `Omnipowers` declaration — a section by that name in its `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — its `vcs` row;
3. what the host already does: its contributor guide, commit template, commit-lint configuration, or the consistent shape of its recent history;
4. the fallback stated in this skill.

- A declared convention overrides this skill's defaults. It governs *form* only; it does not relax the Iron Law.
- A convention that says nothing about attribution → does not authorize the trailers prohibited in step 6.
- Step 3 yields no message convention → fallback subject is `type(scope): imperative summary`, imperative, naming what changed, no trailing period.
- Need the full fallback — the closed list of allowed types, how to pick or omit a scope, the body's required content, the breaking-change markers → read `@message-convention.md` and apply it.
