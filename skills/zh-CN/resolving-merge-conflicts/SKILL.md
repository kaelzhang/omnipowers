---
name: resolving-merge-conflicts
description: 在处理进行中的 git merge、rebase 或 cherry-pick 冲突时使用——文件中有冲突标记、状态为 "both modified"、提示 "fix conflicts and then run git rebase --continue"、合并或 rebase 中途停止——你 MUST 将每个 hunk 的两边追溯到来源提交，按意图解决，绝不只看文本
---

# 解决合并冲突

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 范围

有冲突的操作——出现冲突的 git merge、rebase 或 cherry-pick。
约束单位——每个冲突 hunk，而非每个文件。
合并的既定目标——用户对合并或 rebase 的要求，或分支用途。
合并两边的含义——“ours” 是当前分支；“theirs” 是合入的分支。
rebase 两边的含义——“ours” 是 rebase 的目标分支；“theirs” 是正在重放的提交。
解决方案的表述——A 边的行为、B 边的行为，或两边的组合。

## 铁律

```
按意图解决，绝不只看文本——绝不在冲突 hunk 中凭空添加行为
```

## 步骤 1——摸清操作

动任何 hunk 前 → 你 MUST 确定：

- 正在执行的操作和方向。
- 合并的既定目标。
- 两边的含义。

解决任何冲突前 → 你 MUST 知道合并的既定目标。
解决一个 hunk 前 → 你 MUST 确认两边各自代表什么。

## 步骤 2——逐个 hunk 追溯意图

写下每个冲突 hunk 的解决方案前 → 你 MUST 追溯两边的来源，并各用一句话回答“这一边想做什么？”。

### 历史查询命令

```bash
git log --merge --oneline -- <file>   # commits from both sides that touched this file
git show :1:<file>                    # common ancestor (base) version
git show :2:<file>                    # "ours" version
git show :3:<file>                    # "theirs" version
git log -p <base>..<side> -- <file>   # each side's full change history with diffs
git blame <side> -- <file>            # which commit introduced each conflicting line
git show <commit>                     # the introducing commit: message + full diff
```

对每一边的变更 → 你 MUST 阅读引入变更的提交信息和 diff。

## 解决冲突的契约

对每个 hunk → 解决方案 MUST 满足全部三条：

1. 两边的目标能共存 → 在解决方案中保留双方意图。
2. 两边的意图无法共存 → 选择服务于合并既定目标的一边。
3. 合并暴露出值得修改的地方 → 忠实完成合并，再用单独的提交做这项修改。

两边的目标能共存 → 解决方案 MUST 体现双方意图。
两边的意图无法共存 → 你 MUST 在合并/rebase 提交信息中记录舍弃的意图：舍弃了什么、来自哪个提交，以及原因。
对每个 hunk 的解决方案 → 你 MUST NOT 凭空添加两边都没有的行为。

## 不可采用的捷径

- 解决冲突时 → 你 MUST NOT 用 `git checkout --ours <file>` / `--theirs <file>`、`-X ours` / `-X theirs` 或编辑器的“全部接受当前/传入变更”盲目解决。
- 解决冲突时 → 你 MUST NOT 把两边拼接起来以“保留全部”。
- 选择一边时 → 你 MUST NOT 用间接信号作判断：时间戳更新、diff 更大、“main 大概是对的”，或默认选择自己的分支。

## 合并操作本身看起来有误时

冲突多、繁琐或难解 → 你 MUST NOT 以这些理由执行 `--abort`。

中止条件——以下两个状态同时成立：

1. 追溯发现操作本身可能有误：合并基点错误、一边的重构只落地了一半、分支已经合并，或目标分支错误，而非仅仅解决起来费力。
2. 你通过 confirming-with-the-user 技能呈现证据、选项（含继续执行）、各选项的影响和建议后，用户明确决定中止。

中止条件成立 → 你 MAY 仅在这些条件下中止。

## 最后一个 hunk 解决后——验证

- 解决最后一个 hunk 后 → 你 MUST 找到宿主项目自己的检查，并依次运行：类型检查/构建 → 测试 → 格式检查/lint。
- 完成前 → 你 MUST 修复合并造成的破坏。
- 合并时出现故障 → 你 MUST NOT 将故障视为已有问题而忽略。

## 完成操作

- 解决冲突后 → 你 MUST 暂存每个已解决的文件并提交。
- 运行操作的继续命令前 → 你 MUST 检查 `git status`，将操作范围外的内容留在未暂存状态或 stash，包括同一工作目录中另一位 agent 的工作。
- rebase 期间 → 你 MUST 对后续每个出现冲突的提交重复完整流程，直到全部提交重放完毕。

### 完成检查清单

声明完成前 → 你 MUST 能勾选每一项：

- [ ] 没有残留冲突标记（在 worktree 中运行 `git grep -n "^<<<<<<<"` 返回空结果）
- [ ] 每个 hunk：在解决前已识别双方意图
- [ ] 每个舍弃的意图都已记录在提交信息中
- [ ] 项目检查已运行并通过；已阅读输出
- [ ] 没有残留合并状态：`git rev-parse -q --verify MERGE_HEAD` 失败，且 `.git/rebase-merge` 和 `.git/rebase-apply` 都不存在
- [ ] 对 rebase：所有提交已重放；操作已彻底结束

## 最终规则

```
合并已解决 → 每个 hunk 都有解释（双方意图），契约得到满足，
             检查全绿，操作已提交 / 继续执行到结束
否则       → 尚未解决；继续追溯
```
