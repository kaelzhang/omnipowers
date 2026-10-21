[English](README.md) | 简体中文

# omnipowers

一套提升 AI 编码代理编程效率的技能集。

## 技能

| 技能 | 使用时机 |
| --- | --- |
| [using-omnipowers](skills/zh-CN/using-omnipowers/SKILL.md) | 开始任何任务或对话时——了解 omnipowers 技能的运作方式；回复前检查并调用适用的技能 |
| [fixing-bugs](skills/zh-CN/fixing-bugs/SKILL.md) | 遇到任何 bug、崩溃、测试失败、回归或意外行为时——修改生产代码前，你 MUST 先复现为红，并指出根因 |
| [honoring-user-requirements](skills/zh-CN/honoring-user-requirements/SKILL.md) | 用户提出每一项要求时——你 MUST 当场按原意记录，在每个检查点用证据验证，确认后准确执行 |
| [verification-before-completion](skills/zh-CN/verification-before-completion/SKILL.md) | 准备声明工作已完成、问题已修复或检查已通过时——你 MUST 先运行验证并阅读输出，再作出成功声明 |
| [code-auditing](skills/zh-CN/code-auditing/SKILL.md) | 工作即将推进到合并、PR、发布或交接时，或用户要求检查点评审、标准审计等任何评审时；每个发现项都要有证据，继续前修复 Critical/Important 问题。普通提交不触发评审 |
| [brainstorming](skills/zh-CN/brainstorming/SKILL.md) | 开始构建前——用一行写明目标和交付标准；尚未明确时，先与用户确定，并说清阻塞项、严重风险或分歧。如何构建、何时构建由代理按最佳实践决定 |
| [writing-plans](skills/zh-CN/writing-plans/SKILL.md) | 将规格转为多步骤任务时——编码前，你 MUST 写出完整、自包含、步骤细小且没有占位符的计划 |
| [executing-plans](skills/zh-CN/executing-plans/SKILL.md) | 执行书面计划时——你 MUST 先审慎评审，再按顺序执行每一步，并在每个检查点验证 |
| [subagent-driven-development](skills/zh-CN/subagent-driven-development/SKILL.md) | 执行主要由独立任务组成的计划时——一次处理一个任务，每项任务通过规格和质量评审后再开始下一项，最后对整个分支做全面评审 |
| [keeping-work-in-flight](skills/zh-CN/keeping-work-in-flight/SKILL.md) | 每次代理返回和每轮结束时——统计运行中的工作，阅读前为每个空闲范围派发一次受追踪的调用，不留下完成后无法唤醒你的工作 |
| [using-git-worktrees](skills/zh-CN/using-git-worktrees/SKILL.md) | 功能开发需要隔离时——你 MUST 使用宿主的原生 worktree 工具，或以 `git worktree` 作为后备方案，确保工作区隔离 |
| [finishing-a-development-branch](skills/zh-CN/finishing-a-development-branch/SKILL.md) | 工作已完成并通过验证时——验证测试，列出合并、PR、保留、丢弃的结构化选项，执行用户的选择，只清理自己创建的内容 |
| [writing-skills](skills/zh-CN/writing-skills/SKILL.md) | 创建或编辑技能时——你 MUST 先写测试，在没有技能时观察代理失败，再开发技能；遵循 `AGENTS.md` |
| [confirming-with-the-user](skills/zh-CN/confirming-with-the-user/SKILL.md) | 遇到由用户决定或签字确认的事项时，如设计、评审提议或发现项、取舍——用一种语言、一次一个决策，以直白的选项说明影响并给出推荐 |
| [stress-testing-a-plan](skills/zh-CN/stress-testing-a-plan/SKILL.md) | 用户要求盘问计划、挑漏洞（“poke holes”“grill me”）时——按依赖顺序提问，每个问题附推荐答案；不生成产物；进入构建意图后交给 brainstorming |
| [domain-modeling](skills/zh-CN/domain-modeling/SKILL.md) | 建立项目术语时——根目录的 `CONTEXT.md` 术语表列出弃用的同义词，ADR 通过三项检验后建立；决定一经确定立即记录 |
| [designing-deep-modules](skills/zh-CN/designing-deep-modules/SKILL.md) | 设计模块或接口时——以深度为目标：用删除测试去掉透传层，用双适配器规则去掉推测性的抽象 |
| [prototyping](skills/zh-CN/prototyping/SKILL.md) | 设计问题只有运行代码才能回答时——制作由用户操作的临时产物；结论来自用户的观察，并写回规格 |
| [researching](skills/zh-CN/researching/SKILL.md) | 通过调查回答问题时——每项声明都追溯到负责该事实的一手来源，以带引用的发现文件交付 |
| [resolving-merge-conflicts](skills/zh-CN/resolving-merge-conflicts/SKILL.md) | 正在合并或 rebase 且存在冲突时——逐个 hunk 追溯意图；不在冲突 hunk 中发明行为，不用 `--abort` 逃避 |
| [writing-handoffs](skills/zh-CN/writing-handoffs/SKILL.md) | 用户要求交接会话时——压缩成一份引用证据、提供指针而非复制内容的文档，让没有上下文的代理能接手 |
| [committing-work](skills/zh-CN/committing-work/SKILL.md) | 组织每次提交时——每次只提交一个连贯的逻辑变更，逐路径暂存，用最小且充分的检查证明，提交消息独立可读且不署名任何工具 |
| [writing-documentation](skills/zh-CN/writing-documentation/SKILL.md) | 创建或重组长期维护的文档时——每组文档只有一个入口，按读者任务指向确切文件，并随变更同步更新 |

## 安装

### 快速安装（无需克隆）

使用 [skills.sh](https://skills.sh) 安装器直接从 GitHub 安装；它会自动发现仓库中的所有技能，并安装到你选择的代理中（Claude Code、Codex、Cursor 等）：

```bash
npx skills add https://github.com/kaelzhang/omnipowers/tree/main/skills/zh-CN
```

URL 决定语言：`skills/zh-CN` 安装简体中文技能，`skills/en` 安装英文技能。

常用变体：

```bash
npx skills add https://github.com/kaelzhang/omnipowers/tree/main/skills/zh-CN -g                       # 用户级安装
npx skills add https://github.com/kaelzhang/omnipowers/tree/main/skills/zh-CN -a claude-code -a codex  # 选择代理
npx skills add https://github.com/kaelzhang/omnipowers/tree/main/skills/zh-CN --skill brainstorming    # 选择技能
npx skills update                                            # 后续更新
```

### 从克隆安装（开发）

开发技能时，克隆本仓库并通过**符号链接**安装，编辑后会自动生效，不用重新安装：

```bash
make dev            # 分析 Claude/Codex 状态，再安装到两者
make dev LOCALE=zh-CN # 安装中文版本
make dev FORCE=1    # 已安装时也重新链接
make status         # 查看安装状态
make uninstall      # 移除符号链接
```

不受版本控制的 `.install.conf` 用 key=value 行保存 `targets=claude codex` 和 `locale=en`。
选择优先级依次为 CLI / make 变量（`TARGETS`、`LOCALE`）、环境变量（`OMNIPOWERS_TARGETS`、`OMNIPOWERS_LOCALE`）、`.install.conf`、默认值（两个宿主、英文）。
`make status LOCALE=zh-CN` 预览中文版本的状态；`make dev` 将本仓库已有的链接切换到选定的语言版本。

技能发现路径：

| 工具 | 路径 |
| --- | --- |
| Claude Code | `~/.claude/skills/<name>/` |
| Codex | `~/.agents/skills/<name>/` |

技能通过符号链接安装，因此编辑 `SKILL.md` 后**不用重新安装**：Claude Code 在会话中实时热重载；Codex 自动检测变更（未显示变更时重启 Codex）。
只有新增技能或切换语言版本时，才需重新运行 `make dev`。

## 技能把文件放在哪里

技能会生成设计、计划、审计报告、调试 harness 等文件。
每个文件都归入一个**角色**，由你的项目决定这个角色对应的位置：

| role | 保存的内容 |
|---|---|
| `design-docs` | 已批准的设计、决策记录、值得保留的研究 |
| `work-state` | 计划、进度、阻塞项、下一步、交接 |
| `records` | 审计报告及其他一次性报告 |
| `scratch` | 调试 harness、捕获的差异、恢复缓存 |
| `standards` | 项目自己的评审清单 / 编码标准 |

在代理已经读取的文件（`AGENTS.md` 或 `CLAUDE.md`）中声明一次映射。
每一行都可选：

```markdown
## Omnipowers

| role | location |
|---|---|
| design-docs | docs/design/ |
| work-state  | docs/planning/ |
| standards   | CONTRIBUTING.md |

- write-authority: <谁能在哪里写入；其他情况如何取得授权>
- vcs: <提交、暂存及提交消息约定>
- isolation: <分支或 worktree；留在主干上的路径>
- continuation: <超出一轮的工作如何延续>
```

**没有声明，技能仍能工作。**
它们会采用合理的默认位置：长期保留的文档放在 `docs/`，进行中的工作状态和临时文件放在项目根目录的 `.omnipowers/` 中；首次写入每类文件前，会与你确认位置。

`.omnipowers/` 是**工作台，不是档案库**：只存放进行中的工作状态和临时内容；工作落地时，`finishing-a-development-branch` 会清空它，把长期保留的内容迁入设计文档，并删除其余内容。
如果不想让这个目录进入版本控制，把它加入 gitignore。

## 开发技能

本仓库提供测试和改进技能的工具。
这些工具只操作本仓库中的技能，**不属于**宿主项目安装的内容。

```bash
make test                                  # 检查每个技能的内容（免费）
make optimize BACKEND=claude               # 优化所有技能 -> 暂存提议
make optimize SKILL=a,b,c BACKEND=codex    # 仅优化这些技能
make optimize SKILL=a BACKEND=claude DRY=1 # 仅报告，不暂存
make optimize-status SKILL=a               # 查看暂存提议
make optimize-adopt  SKILL=a               # 采用提议（保留备份）
make optimize-list                         # 查看技能及 eval/config/暂存状态
```

`make optimize` 只操作 `skills/en/`。

`make optimize` 使用外部依赖 [SkillOpt-Sleep](https://github.com/microsoft/SkillOpt)；将 `SKILLOPT_HOME` 设为本地克隆路径。
它会为每个技能回放任务、提出有界的修改，用留出集检验，再把提议**暂存**到 `.skillopt-sleep/`（已加入 gitignore）。
运行 `optimize-adopt` 前，它不会编辑技能。
后端为**必填项**（`claude` 或 `codex`，两者都会调用真实模型）。
任务来自可选的 `<eval-root>/<skill>/tasks.json`（设置 `OMNIPOWERS_EVAL_ROOT`）；没有评估集时，SkillOpt 会从代理会话记录中自动发现任务。
可选的 `<eval-root>/<skill>/config.json` 设置每个技能的参数（模型、闸门、编辑预算）。

## 致谢

omnipowers 受到 Jesse Vincent 的 [Superpowers](https://github.com/obra/superpowers) 启发，也吸收了 Matt Pocock 的 [mattpocock/skills](https://github.com/mattpocock/skills) 中的想法。

## 许可证

MIT——见 [LICENSE](LICENSE)。
