---
name: finishing-a-development-branch
description: 分支或 worktree 的工作完成并验证、分支即将结束时使用——合回主干（"回主干"、"合并到主干"）、交付、清理 worktree/分支——你 MUST 先验证，再不开 PR、不问用户地合并进主干；只有宿主声明了 PR 流程时例外
---

# 完成开发分支

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 铁律

```
每个分支结束时都已验证并合并进主干，不问用户
```

- 结束分支或 worktree 时 → 你 MUST NOT 问用户怎么集成、要不要合并、要不要清理。
- 结束分支或 worktree 时 → 你 MUST NOT 让它保持未合并，也不丢弃它的工作。
- 宿主没有声明 PR 流程时 → 你 MUST NOT 开 PR。

主干 — 宿主声明的集成分支；没有声明时，取远端的默认分支（`git symbolic-ref --short refs/remotes/origin/HEAD`）；再没有时，取 `main` 和 `master` 中存在的那个。

宿主 PR 流程 — 宿主的 `vcs` 或 `isolation` 声明要求改动经 pull request 进入主干。

## 流程

结束分支或 worktree 时 → 你 MUST 按顺序完成以下步骤：

1. 验证。
2. 清空工作台。
3. 合并进主干，或按宿主 PR 流程处理。
4. 推送。
5. 只清理自己创建的内容。
6. 报告。

### 1. 验证

- 合并前 → 项目的完整性闸门（测试、类型检查、lint、构建）MUST 已按 `verification-before-completion` 在当前这棵代码树上通过。
- 项目没有测试集时 → 你 MUST 运行能证明改动成立的最小检查，并且 MUST 在报告里写明是哪项检查。
- 检查失败时 → 你 MUST 修好工作并重跑检查。
- 检查失败时 → 你 MUST NOT 合并。

### 2. 清空工作台

合并前 → 你 MUST 清点本次工作在宿主的进行中状态和临时状态中留下的全部内容（计划、进度台账、捕获的 diff、调试 harness、交接），按宿主存放位置处理，回退位置为 `.omnipowers/`：

- 决策、设计结论或规则会在本分支结束后继续存在 → 这些内容 MUST 在合并前迁入宿主持久保存的设计文档。
- 提升为持久产物已完成 → 本次工作的进行中产物 MUST 删除。

### 3. 合并进主干

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- 合并时 → 你 MUST 在主干检出目录里执行合并，绝不在即将移除的 worktree 里执行。
- 主干检出目录当前不在主干分支上时 → 你 MUST NOT 切换它的分支。
- 主干检出目录里有不是你做的未提交改动时 → 你 MUST NOT 对它们 stash、reset 或覆盖。
- 工作位于 detached HEAD 上时 → 你 MUST 先在这个提交上创建分支，再合并。
- 宿主声明了合并方式（合并提交、rebase、快进、squash）时 → 你 MUST 使用这种方式。
- 宿主没有声明合并方式时 → 你 SHOULD 沿用主干现有历史采用的方式。
- 合并出现冲突时 → 你 MUST 按 `resolving-merge-conflicts` 解决。
- 合并出现冲突时 → 你 MUST NOT 执行 `git merge --abort` 后报告失败。
- 合并完成后 → 完整性闸门 MUST 在合并后的代码树上通过，之后你才能删除任何东西。
- 合并后的检查失败时 → 你 MUST 先在主干上修好，再删除任何东西。

### 宿主 PR 流程

- 宿主声明了 PR 流程时 → 你 MUST 推送分支并开 PR，而不在本地合并。
- 宿主声明了 PR 流程时 → 你 MUST NOT 在开 PR 前询问用户。
- 没有 PR 工具时 → 你 MUST 报告已推送的分支和它的远端。
- PR 已开但尚未合并时 → 你 MUST NOT 移除它的 worktree 或分支。
- PR 已开但尚未合并时 → 你 MUST NOT 把工作报告为已合并。

### 4. 推送

- 合并后的检查通过且主干跟踪远端时 → 你 MUST 按 `committing-work` 的推送规则推送主干。
- 推送被宿主没有声明的保护规则拒绝时 → 你 MUST 按 `confirming-with-the-user` 把它作为阻塞项报告。

### 5. 只清理自己创建的内容

合并已推送，或主干不跟踪远端时 → 你 MUST 在主干检出目录里删除已合并的分支：

```bash
git branch -d <feature-branch>
```

- 有 worktree 引用这个分支时 → 你 MUST 先移除那个 worktree，再删除分支。
- 移除 worktree 时 → 你 MUST 只移除本技能或你自己的工作流创建的 worktree。
- 工作区由宿主环境提供 → 你 MUST NOT 移除。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

普通仓库——`GIT_DIR == GIT_COMMON`；没有 worktree。

- `WORKTREE_PATH` 位于 `.worktrees/` 或 `worktrees/` 下，且你在本会话中创建了这个 worktree → 你 MUST 在移除前用 `cd` 切换到主检出目录：

  ```bash
  MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
  cd "$MAIN_ROOT"
  git worktree remove "$WORKTREE_PATH"
  git worktree prune   # clear any stale worktree registrations
  ```

- `WORKTREE_PATH` 不在 `.worktrees/` 或 `worktrees/` 下、不是你在本会话中创建的，或来源不明 → 你 MUST NOT 移除。

**宿主拥有的工作区**——不是你在本会话中创建的 worktree，或来源不明的 worktree。宿主的工作区退出机制负责结束；没有这种机制时，原地保留并报告为宿主拥有的工作区。

### 6. 报告

工作已合并并清理完毕时 → 你 MUST 按以下格式报告：

```
已将 <feature-branch> 合并进 <mainline>，合并提交 <commit>；已推送到 <remote>（或：没有远端）。
验证：在合并后的代码树上运行了 <check>。
提升：<内容 → 位置>；删除：<工作台内容>。
移除：<branch>、<worktree path>（或：宿主拥有的工作区原地保留）。
```

## 危险信号——发现自己这样想时停下

发现自己出现表中任一想法 → 你 MUST 停下并纠正方向：

| 想法 | 替代做法 |
|---|---|
| “我该问问是合并、开 PR 还是保留分支。” | 合并进主干；宿主声明的 PR 流程是唯一的另一条路。 |
| “测试大概通过——我之前运行过。” | 已在当前这棵代码树上运行过的结果仍有效；尚未在这棵代码树上运行过 → 现在运行并阅读输出。 |
| “没有测试命令，所以没什么可查的。” | 运行能证明改动成立的最小检查，并在报告里写明。 |
| “主干检出目录里有别人的改动，我先 stash 掉。” | 不动它们，只合并你自己的工作。 |
| “分支先留着，以防万一。” | 合并它；没合并的分支不算完成的工作。 |
| “合并完了——现在就移除 worktree。” | 先让合并后的检查通过。 |
| “我在 worktree 里面，`git worktree remove` 会处理好。” | 先 `cd` 到主检出目录。 |
| “这个 worktree 碍事，直接移除。” | 不是你在本会话中创建的 → 不动它。 |

## 完成检查清单

声称工作完成前 → 你 MUST 能勾选每个适用项：

- [ ] 完整性闸门在分支的代码树上通过，并在合并后的代码树上再次通过。
- [ ] 已清空工作台：持久结论已提升，进行中产物已删除。
- [ ] 工作已合并进主干，或在宿主声明的 PR 流程下开了 PR。
- [ ] 没有就集成或清理问过用户任何问题。
- [ ] 主干跟踪远端时，已推送主干。
- [ ] 只移除了自己创建的分支和 worktree，先移除 worktree 再删分支，并在主检出目录里执行。
- [ ] 报告写明了合并提交、所做的检查、提升和删除的内容，以及移除的内容。
