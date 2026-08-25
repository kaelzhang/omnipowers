# Rationalizations — rejected

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Read this when you notice yourself reasoning toward a shortcut at commit time.

| Excuse | Do this instead |
|---|---|
| "`git add .` is faster, the tree is clean" | A tree you did not inspect is not known clean. Stage by path. |
| "It's all one feature, one commit is fine" | Two parts reviewable or revertable independently are two commits. Split them. |
| "I'll add the tests in a follow-up commit" | Put the tests in this commit. |
| "The rename is trivial, I'll fold it in" | Commit the rename separately. |
| "`git add -p` lets me keep it clean" | It produces a commit that never existed as a working state. Sequence the edits and commit one at a time. |
| "Plain `git commit` — nothing else is staged" | You do not control every process staging into that index. Name the paths. |
| "The quality bar isn't met, I shouldn't commit yet" | Commit the coherent checkpoint and record the gap. |
| "I'll leave it uncommitted so the user can look first" | Commit, then point at the commit. |
| "The message is obvious from the diff" | The diff shows what. Write the body for why. |
| "My harness adds the trailer automatically" | Remove it before committing. |
| "It's already pushed but nobody has pulled" | Fix forward with a new commit. |
| "Tests passed earlier in the session" | Run the smallest check now, against what you are actually committing. |
