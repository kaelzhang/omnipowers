---
name: using-git-worktrees
description: 开始功能工作或执行计划，且工作要与当前分支或 checkout 隔离，或用户要求设置 git worktree 或独立工作区时使用——你 MUST 通过宿主原生 worktree 工具或 git worktree 回退方案确保隔离工作区存在
---

# 使用 Git Worktree

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 概览

- 开始工作前 → 你 MUST 确保在隔离工作区内开展工作。
- 创建 worktree 时 → 你 MUST NOT 创建多余或嵌套的 worktree。
- harness 已提供隔离时 → 你 MUST NOT 与 harness 对抗。

## 铁律

```
先检测隔离 — 只创建缺少的部分 — 确认基线干净
```

- 创建任何内容前 → 你 MUST 运行步骤 0。
- 你 MUST NOT 直接跳到 git worktree add。
- 测试建立干净基线（步骤 3）前 → 你 MUST NOT 声称工作区已就绪。

## 何时使用

开始需要隔离的功能工作，或即将执行会修改文件的实现计划时 → 你 MUST 应用本技能。

## 宿主的隔离规则（步骤 0 前 REQUIRED）

宿主隔离声明 — 宿主的 `isolation` 行，位置按 `using-omnipowers` 确定。

- 步骤 0 前 → 你 MUST 阅读宿主隔离声明，并在声明存在时遵守。
- 宿主指定隔离单位（worktree、分支，或仅通过明确提交路径隔离的共享 checkout）时 → 你 MUST 使用这个单位。
- 宿主指定隔离单位时 → 你 MUST NOT 换用其他单位。
- 宿主声明仅留在主干的路径时 → 这些路径 MUST 留在主干。
- 声明隔离时 → 宿主 MAY 指定仅留在主干的路径。
- 宿主指定仅留在主干的路径时 → 这些路径 MUST NOT 复制到隔离工作区。
- 宿主声明仅留在主干的路径时 → 你 MUST 在主干 checkout 中读写这些路径，不在 worktree 中读写。

## 返回主干（MANDATORY）

返回主干流程 — `finishing-a-development-branch`；未安装这个技能时，使用宿主自身的分支完成流程。

- 工作完成并验证后 → 你 MUST 将工作带回主干，按宿主要求合并，或推送并发起评审。
- 工作仅存在于隔离工作区时 → 你 MUST NOT 报告完成。
- 向另一个 agent、另一个会话或用户交接前 → 你 MUST 先返回主干。
- 任何交接前 → 你 MUST NOT 将返回主干的责任推给接收方。

## 步骤 0 — 检测现有隔离（REQUIRED：首先执行）

创建任何内容前 → 你 MUST 判断当前是否已处于隔离工作区。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

关联 worktree — 满足 `GIT_DIR != GIT_COMMON` 的工作区。

普通 checkout — 满足 `GIT_DIR == GIT_COMMON` 的工作区，包括两个变量都解析到 `.git/modules/<name>` 的普通子模块。

- `GIT_DIR != GIT_COMMON` → 你 MUST 跳到步骤 2。
- `GIT_DIR != GIT_COMMON` → 你 MUST NOT 再创建 worktree。
- `GIT_DIR != GIT_COMMON` → 你 MUST 使用匹配的模板报告：

- 位于分支上 — “已在隔离工作区 PATH，分支为 NAME”；
- 游离 HEAD — “已在隔离工作区 PATH（游离 HEAD，由外部管理）；完成时要创建分支。”

### 同意闸门（创建 worktree 前 REQUIRED）

- 宿主已声明 `isolation` 单位时 → 你 MUST 直接使用，不再询问。
- 用户已声明 worktree 偏好（指令、任务或本次对话中）时 → 你 MUST 直接遵循，不再询问。
- 宿主未声明 `isolation` 单位，且用户未声明 worktree 偏好时 → 你 MUST 使用以下模板征求同意：

> “要我设置隔离 worktree 吗？这样能保护当前分支免受改动影响。”

- 宿主未声明 `isolation` 单位，用户未声明 worktree 偏好，且用户尚未同意时 → 你 MUST NOT 创建 worktree。
- 用户拒绝时 → 你 MUST 在原地工作，并跳到步骤 2。
- 用户拒绝或尚未同意时 → 你 MUST NOT 创建 worktree。

## 步骤 1 — 创建隔离工作区

创建隔离工作区时 → 你 MUST 按此顺序尝试机制：先原生机制，再 git 回退方案。

### 1a. 原生 worktree 机制（优先）

原生 worktree 机制 — 宿主提供的 worktree 创建工具、命令或标志。

- 宿主提供创建 worktree 的原生方式时 → 你 MUST 使用它，并跳到步骤 2。
- 原生机制存在时 → 你 MUST NOT 运行 git worktree add。
- 宿主没有原生 worktree 机制时 → 你 MAY 仅在此条件下进入步骤 1b。

### 1b. Git worktree 回退方案

- 选择 git worktree 回退方案时 → 你 MUST 仅在步骤 1a 不适用时使用这条路径。
- 使用 git worktree 回退方案时 → 你 MUST 用 git worktree 创建 worktree，并遵循下列规则。

#### 目录选择

选择 worktree 目录时 → 你 MUST 按此优先级确定目录，并将结果赋给 `LOCATION`：

1. **已声明偏好。**用户指定了 worktree 目录时 → 你 MUST 直接使用，不再询问。
2. **项目内现有目录。**用户未指定 worktree 目录时 → 你 MUST 用 `ls -d .worktrees 2>/dev/null` 或 `ls -d worktrees 2>/dev/null` 检测现有目录。
   用户未指定 worktree 目录，且 `.worktrees` 或 `worktrees` 恰有一个存在时 → 你 MUST 使用存在的目录。
   用户未指定 worktree 目录，且两者都存在时 → 你 MUST 使用 `.worktrees`。
3. **默认目录。**用户未指定 worktree 目录，且 `.worktrees` 和 `worktrees` 都不存在时 → 你 MUST 默认使用项目根目录下的 `.worktrees/`。

#### 安全验证（仅限项目内目录）

- 在选定的项目内目录中创建 worktree 前 → 你 MUST 确认 Git 已忽略这个目录。
- 检查 Git 是否忽略选定的项目内目录时 → 你 MUST 只检查选定目录（`$LOCATION`），而非固定对两个候选名称做 OR 检查。

```bash
git check-ignore -q "$LOCATION" 2>/dev/null
```

- Git 未忽略选定的项目内目录时 → 你 MUST 将目录加入 `.gitignore`，并在创建 worktree 前提交这项改动。
- Git 未忽略项目内目录时 → 你 MUST NOT 在里面创建 worktree。

#### 创建 worktree

`LOCATION` — 上面选定的目录。

`BRANCH_NAME` — 根据要隔离的功能或计划派生的名称。

- 运行代码块前 → 你 MUST 为两个变量赋值。
- 为变量赋值时 → 你 MUST 使用具体值，而非原样复制代码块。

```bash
LOCATION=.worktrees                # the directory chosen by the priority list above
BRANCH_NAME=feature/<derived-name> # derived from the feature or plan
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

- git worktree add 因权限或沙箱拒绝而失败时 → 你 MUST 告诉用户沙箱阻止了 worktree 创建，接下来将在当前目录工作。
- 报告权限或沙箱拒绝错误后 → 你 MUST 在原地运行环境设置（步骤 2）和基线测试（步骤 3）。
- 因权限或沙箱拒绝错误放弃隔离时 → 你 MUST NOT 在未告知用户的情况下这样做。

## 步骤 2 — 项目设置

- 执行步骤 2 时 → 你 MUST 自动检测项目类型，并运行匹配的依赖设置。
- 没有识别到清单文件时 → 你 MUST 跳过依赖安装，而非猜测。

```bash
if [ -f package.json ];     then npm install; fi
if [ -f Cargo.toml ];       then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ];   then poetry install; fi
if [ -f go.mod ];           then go mod download; fi
```

项目实际工具链与这些模式不同（锁文件固定的包管理器、Makefile 目标、虚拟环境激活）时 → 你 MUST 使用实际工具链。

## 步骤 3 — 验证干净基线（REQUIRED）

- 开始实现前 → 工作区 MUST 从干净基线开始；基线以本会话或项目 CI 在完全相同提交上的测试套件通过记录为依据；没有这种记录时，运行项目测试套件建立基线。
- 测试套件已在本会话或项目 CI 的完全相同提交上通过时 → 你 MUST 引用这份基线。
- 项目声明了自己的测试命令（Makefile 目标、锁文件固定的运行器、配置好的脚本）时 → 你 MUST 使用声明的命令，替代 `npm test`、`cargo test`、`pytest` 或 `go test ./...`。

- **测试失败** → 你 MUST 报告失败，并询问用户是继续还是先调查。
- 基线失败且原因不明，用户尚未明确决定继续还是调查时 → 你 MUST NOT 开始实现。
- **测试通过** → 你 MUST 报告就绪，说明 worktree 完整路径、通过测试数且失败数为零，以及即将实现的功能。

## 危险信号 — 停下

即将执行下列任一操作时 → 你 MUST 停下：

- 步骤 0 已检测到隔离后仍创建 worktree，或在现有 worktree 中嵌套 worktree。
- 原生机制可用时仍使用 git worktree add。
- 尚未检查原生机制（步骤 1a）就跳到步骤 1b。
- 未按优先级选择目录（已声明偏好、项目内现有目录、默认目录）。
- 未验证 Git 已忽略目录就创建项目内 worktree。
- 在普通 checkout 中未经同意创建 worktree。
- 跳过基线测试验证，或未经询问就在基线失败后继续。
