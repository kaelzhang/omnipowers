# 结束合并、rebase、cherry-pick 或 revert

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

- Git 本身拒绝为正在进行的 merge、rebase、cherry-pick 或 revert 的结束提交接受 pathspec（`fatal: cannot do a partial commit during a merge`）→ 你 MAY 仅在此条件下省略 pathspec。

创建记录整个索引的提交前 → 你 MUST：

1. 运行 `git status --short`，识别每个不属于本次操作的条目。
2. 将这些条目逐一 stash 或取消暂存。
3. 操作有专用继续命令时 → 使用对应命令（`git merge --continue`、`git rebase --continue`、`git cherry-pick --continue`）。
