# Concluding a Merge, Rebase, Cherry-Pick, or Revert

> Normative keywords — MUST, MUST NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

- Git itself refuses a pathspec for the concluding commit of an in-progress merge, rebase, cherry-pick, or revert (`fatal: cannot do a partial commit during a merge`) → you MAY omit the pathspec ONLY under that condition.

Before making that whole-index commit → you MUST:

1. Run `git status --short` and identify every entry that is not part of the operation.
2. Stash or unstage each of those entries.
3. When the operation has its own continuation command → use it (`git merge --continue`, `git rebase --continue`, `git cherry-pick --continue`).
