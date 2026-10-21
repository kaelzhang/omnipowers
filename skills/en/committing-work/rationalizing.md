# Rationalizations — rejected

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

| Excuse | Do this instead |
|---|---|
| "`git add .` is faster, the tree is clean" | Stage by path. |
| "It's all one feature, one commit is fine" | Split parts that are independently reviewable or revertable. |
| "I'll add the tests in a follow-up commit" | Put the tests in this commit. |
| "The rename is trivial, I'll fold it in" | Commit the rename separately. |
| "`git add -p` lets me keep it clean" | Sequence the edits and commit one at a time. |
| "Plain `git commit` — nothing else is staged" | Name the paths. |
| "The quality bar isn't met, I shouldn't commit yet" | Commit the coherent checkpoint and record the gap. |
| "I'll leave it uncommitted so the user can look first" | Commit, then point at the commit. |
| "The message is obvious from the diff" | Write the body for why. |
| "My harness adds the trailer automatically" | Remove it before committing. |
| "It's already pushed but nobody has pulled" | Fix forward with a new commit. |
| "Tests passed earlier in the session" | Run the smallest check now, against what you are actually committing. |
