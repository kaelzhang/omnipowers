---
name: finishing-a-development-branch
description: 功能分支的工作完成并验证、准备收尾时使用——合回主干（"回主干"、"合并到主干"）、开 PR、交付、保留或丢弃（含清理 worktree/分支）——你 MUST 验证测试通过，再按宿主声明或用户指定的方式集成；只有两者都未指定时，才呈现选项让用户选择
---

# 完成开发分支

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 概览

- 确定集成路径（合并、PR、保留、丢弃）时 → 你 MUST NOT 代替用户决定。
- 受闸门约束的操作——改动基准分支或销毁工作的步骤；发布功能分支属于正常进行中的工作。

## 铁律

```
测试未全绿就不集成，用户未明确选择就不执行破坏性操作
```

- 本会话中测试集尚未通过，或用户尚未选择操作 → 你 MUST NOT 合并、删除分支或移除 worktree。
- 呈现菜单时 → 你 MUST NOT 将菜单缩为一个假定答案。

## 流程

完成开发分支时 → 你 MUST 按顺序执行以下阶段。

测试尚未通过或尚未识别工作区 → 你 MUST NOT 确定选项。

### 阶段 1——验证测试（REQUIRED 闸门）

- 确定选项前 → 项目自己的测试命令 MUST 已在本会话对当前这棵代码树运行通过，遵循 `verification-before-completion` 规则。
- 测试集失败 → 你 MUST 停下。
- 测试集失败 → 你 MUST NOT 进入阶段 2。
- 测试集失败 → 你 MUST 报告：

```
测试失败（<N> 项失败）。这些问题 MUST 在集成前修复：

<失败项>

测试集全绿前，集成处于阻塞状态。
```

- 测试集通过 → 你 MAY 仅在此状态下进入阶段 2。
- 项目没有测试集 → 你 MUST 明确告知用户，并在继续前得到用户确认。
- 缺少测试命令 → 你 MUST NOT 默默将这视为“没有测试”。

### 阶段 1b——清空工作台（REQUIRED）

阶段 1b 范围——**合并**、**PR** 和**丢弃**选项。

选中了**保留** → 你 MUST 保持工作台原样。

集成前 → 你 MUST 清点本次工作在宿主的进行中状态和临时状态中留下的全部内容（计划、进度台账、捕获的 diff、调试 harness、交接），按宿主存放位置处理，回退位置为 `.omnipowers/`：

- 决策、设计结论或规则会在本分支结束后继续存在 → 这些内容 MUST 在集成前迁入宿主持久保存的设计文档。
- 提升为持久产物已完成 → 本次工作的进行中产物 MUST 删除。
- 报告完成时 → 你 MUST 说明提升了什么、存到哪里，以及删除了什么。

### 阶段 2——识别工作区

选择菜单前 → 你 MUST 确定工作区形态。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
HEAD_REF=$(git symbolic-ref -q --short HEAD || echo "DETACHED")
```

识别工作区形态后 → 你 MUST 使用匹配的行：

| 状态 | 菜单 | 清理 |
|---|---|---|
| `GIT_DIR == GIT_COMMON`（普通仓库，命名分支） | 完整四选项菜单 | 没有 worktree——只清理分支 |
| `GIT_DIR != GIT_COMMON`（worktree），命名分支 | 完整四选项菜单 | 按来源清理（阶段 6） |
| `GIT_DIR != GIT_COMMON`（worktree），分离 HEAD | 分离 HEAD → 你 MUST NOT 提供本地合并；精简三选项菜单 | 分离 HEAD → 你 MUST NOT 移除此工作区 |

### 阶段 3——确定基准分支

提供合并或 PR 选项前 → 你 MUST 确定工作将集成到的基准分支名称。

确定基准时 → 基准 MUST 是分支名，而非提交 SHA。

```bash
# Resolve the base branch NAME (prefers main, then master):
BASE=$(git rev-parse --verify --quiet main >/dev/null && echo main \
  || (git rev-parse --verify --quiet master >/dev/null && echo master))
```

`BASE` 返回空值、基准不明确，或项目使用别的集成分支 → 你 MUST 与用户确认基准，不作猜测。

### 阶段 4——确定选项

- 宿主的 `Omnipowers` 声明（`isolation` 或 `vcs` 行）或用户在本会话中指定了已完成工作如何回到主干 → 你 MUST 在阶段 5 执行指定选项。
- 宿主的 `Omnipowers` 声明（`isolation` 或 `vcs` 行）或用户在本会话中指定了已完成工作如何回到主干 → 你 MUST NOT 呈现菜单。
- 宿主声明和用户都未指定集成选项 → 你 MUST 按 `confirming-with-the-user` 技能要求，用简短的编号菜单呈现选项和建议，并等待用户选择。
- 宿主声明和用户都未指定集成选项 → 你 MUST NOT 在用户选择前执行选项，且 MUST NOT 假定宿主未声明的策略。

#### 完整菜单——普通仓库或命名分支 worktree

```
实现已完成，测试通过。你想如何集成这项工作？

1. 在本地合入 <base-branch>
2. 推送分支并创建 Pull Request
3. 保持分支原样（我稍后处理）
4. 丢弃这项工作

选择哪一项？
```

#### 精简菜单——分离 HEAD（外部管理的工作区）

```
实现已完成，测试通过。当前处于分离 HEAD（外部管理的工作区）。

1. 推送为新分支并创建 Pull Request
2. 保持原样（我稍后处理）
3. 丢弃这项工作

选择哪一项？
```

### 阶段 5——执行选定选项

阶段 4 已确定选项（由声明、指示或选择确定） → 你 MUST 只按以下步骤执行选定选项。

历史完整性——`committing-work` 技能中约束强制推送和改写已发布提交的规则。

#### 选项：本地合并

选中了**合并** → 你 MUST 验证合并成功，并对合并结果重新运行测试后再删除任何内容。

选中了**合并** → 你 MUST 从主检出目录运行 worktree 命令和删除分支，绝不在即将移除的 worktree 内执行。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git checkout <base-branch>
# Pull only if the base tracks a remote:
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 && git pull
git merge <feature-branch>
```

- 合并后代码树的测试失败 → 你 MUST NOT 删除分支或 worktree。
- 合并出现冲突 → 你 MUST 通过 `resolving-merge-conflicts` 技能解决（逐个 hunk，按意图解决）。
- 合并出现冲突 → 你 MUST NOT 执行 `git merge --abort` 后报告失败。
- worktree 引用了分支 → 你 MUST NOT 在移除 worktree 前删除分支。

```bash
git branch -d <feature-branch>
```

#### 选项：推送并创建 PR

```bash
git push -u origin <feature-branch>
```

- 没有可用的 PR 工具 → 你 MUST 报告已推送的分支和远端。
- 选中了 **PR** → 你 MUST NOT 清理 worktree。

#### 选项：保持原样

- 选中了**保留** → 你 MUST NOT 合并或移除任何内容。
- 选中了**保留** → 你 MUST 报告状态：

```
保留分支 <name>。worktree 保留在 <path>（若有）。
```

- 选中了**保留** → 你 MUST NOT 将保留的工作描述为完成或已交付。
- 交接时回主干的规则——`using-git-worktrees` 中在将工作交给另一位 agent 或另一个会话前返回主干的规则。

#### 选项：丢弃（REQUIRED 确认闸门）

丢弃工作前 → 你 MUST 获得用户键入的确认：

```
这会永久删除：
- 分支 <name>
- 这些提交：<commit-list>
- 位于 <path> 的 worktree（若有）

输入 'discard' 确认。
```

- 丢弃工作前 → 你 MUST 等待精确单词 `discard`。
- 回复不是精确单词 `discard`，或没有回复 → 你 MUST NOT 继续。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

git branch -D <feature-branch>
```

### 阶段 6——只清理自己创建的内容

阶段 6 范围——仅**合并**和**丢弃**选项。

选中了 **PR** 或**保留** → 你 MUST 始终保留 worktree。

移除 worktree 时 → 你 MUST 只移除本技能（或你自己的工作流）创建的 worktree。

工作区由宿主环境提供 → 你 MUST NOT 移除。

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

## 危险信号——发现自己这样想时停下

发现自己出现表中任一想法 → 你 MUST 停下并纠正方向：

| 想法 | 替代做法 |
|---|---|
| “测试大概通过——我之前运行过。” / “合并看着没问题，跳过重测。” | 已在当前这棵代码树上运行过的结果仍有效；尚未在这棵代码树上运行过 → 现在运行并阅读输出。 |
| “没有测试命令，说明没有测试。” | 先说明缺少测试集的发现项，并取得用户确认。 |
| “仓库只有一位维护者，直接合并。” / “用户明显想要 PR。” | 没有声明或指示 → 呈现菜单并等待。 |
| “回复 `yes` 就足以丢弃。” | 等待键入的精确单词 `discard`。 |
| “我会强制推送来整理一下。” | 历史完整性由 `committing-work` 约束。 |
| “为了整洁，我现在清理 worktree。” | 只在合并和丢弃时清理；PR 和保留都保留 worktree。 |
| “合并结束了——现在移除 worktree。” | 先确认合并成功且测试通过。 |
| “我在 worktree 内，`git worktree remove` 会处理好。” | 先用 `cd` 切换到主检出目录。 |
| “这个 worktree 碍事，直接移除。” | 不是你在本会话中创建的 → 保留。 |
| “先删分支，再删 worktree。” | 先移除 worktree。 |

## 完成检查清单

称工作完成前 → 你 MUST 能勾选每个适用项：

- [ ] 在本会话运行测试集并通过（或用户已确认没有测试的状态）。
- [ ] 识别工作区形态并选择匹配菜单。
- [ ] 确认基准分支。
- [ ] 选项来自宿主声明或用户表述；否则已呈现准确菜单并等待用户选择。
- [ ] 只执行选定选项。
- [ ] 合并：验证合并，并在任何删除前对结果重新运行测试。
- [ ] 丢弃：取得键入的 `discard` 确认。
- [ ] 仅在合并/丢弃时清理 worktree，且仅清理自己创建的 worktree。
- [ ] 任何 worktree 移除前都已用 `cd` 切换到主检出目录，之后运行了 `git worktree prune`。
- [ ] 保持宿主拥有的工作区原样。
