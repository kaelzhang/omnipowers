# Concluding a Merge, Rebase, Cherry-Pick, or Revert

> Normative keywords — MUST, MUST NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this only while one of those operations is in progress. Everywhere else the pathspec rule in `SKILL.md` holds without exception.

**The one exception.** You MAY omit the pathspec ONLY when Git itself refuses one — the concluding commit of an in-progress merge, rebase, cherry-pick, or revert (`fatal: cannot do a partial commit during a merge`). That commit takes the **whole index**, so before making it you MUST:

1. run `git status --short` and identify every entry that is not part of the operation;
2. stash or unstage each of them;
3. use the operation's own continuation command where one exists (`git merge --continue`, `git rebase --continue`, `git cherry-pick --continue`).
