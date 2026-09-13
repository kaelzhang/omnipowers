# Resolving the Host's Commit Convention

> Normative keywords — MUST, MUST NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this once per project, the first time you commit in it. The resolved convention governs every commit after.

Every git command shown here is illustrative. Resolve the concrete staging mechanics, the message form, and which files are tracked at all in this order, stopping at the first that applies:

1. what the user states in this session;
2. the `vcs` row of the host's `Omnipowers` declaration, located per `using-omnipowers`;
3. what the host already does: its contributor guide, commit template, commit-lint configuration, or the consistent shape of its recent history;
4. the fallback stated in this skill.

- A declared convention overrides this skill's defaults. It governs *form* only; it does not relax the Iron Law.
- A convention that says nothing about attribution → does not authorize the trailers prohibited in step 6.
- Step 3 yields no message convention → fallback subject is `type(scope): imperative summary`, imperative, naming what changed, no trailing period.
- Need the full fallback — the closed list of allowed types, how to pick or omit a scope, the body's required content, the breaking-change markers → read `@message-convention.md` and apply it.

## Install the attribution gate

The prohibition on tool attribution in step 6 is enforced by a command, not by memory. Before your first commit in a project you MUST install `@block-attribution.sh` as a pre-command hook on the host's shell tool, unless the host's `vcs` row says the gate is unwanted. It refuses only a `git commit` or `gh pr` command whose message credits a tool, model, or vendor; everything else passes, and anything it cannot parse passes. Name the file you changed when you report the round.

The host is Claude Code → copy the script into the project's `.claude/hooks/` and register it in the project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command", "command": "bash .claude/hooks/block-attribution.sh" } ] }
    ]
  }
}
```

The gate is already installed at the user level → you MUST NOT install a second copy. The host has no pre-command hook → the rule in step 6 stands alone; you MUST say so in the round's report.
