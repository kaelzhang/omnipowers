# 技能地图 — 技能集如何协作

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

技能地图 — 技能范围的索引，以每个技能自己的 `SKILL.md` 为准。

## 主流程 — 构建工作

```
stress-testing-a-plan ─(build intent)→ brainstorming → writing-plans
        → executing-plans / subagent-driven-development
        → finishing-a-development-branch
```

- **brainstorming** — 构建前围绕目标、交付标准和技术方案的闸门，以及按最佳实践、高效地安排怎么做和先后顺序；不包含没有构建意图的计划追问（`stress-testing-a-plan`）。
- **writing-plans** — 将已确定目标转为实现计划；不包含执行。
- **executing-plans** — agent 持续执行书面计划，逐步验证；宿主有 subagent 时，不包含以独立任务为主的计划（`subagent-driven-development`）。
- **subagent-driven-development** — 执行计划，每个任务分配一对新的实现者和评审者；不包含紧密耦合的计划（`executing-plans`）或临时并行工作（`keeping-work-in-flight`）。
- **finishing-a-development-branch** — 工作完成并验证后的集成和清理：不问用户地合并进目标分支（集成分支或主干），或在宿主 PR 流程下开 PR，然后移除每个已合并的 worktree；合并冲突归 `resolving-merge-conflicts`。
- **using-git-worktrees** — 工作开始前的隔离，包含检测现有隔离、优先使用宿主原生机制、验证基线和返回目标分支；不包含集成（`finishing-a-development-branch`）。

## 入口 — 出现问题

- **fixing-bugs** — 复现 bug、崩溃、不稳定测试、回归、构建问题或性能问题，识别根因、修正问题，并排查根因相同的位置；按需加载深入调查的内容。
- **resolving-merge-conflicts** — 在带冲突标记的合并或 rebase 过程中，逐个 hunk 重建意图，不虚构行为。

## 设计时的工具

- **designing-deep-modules** — 模块和接口设计标准：深度、删除测试和双适配器规则；用于设计选择，不构成独立工作流。
- **prototyping** — 用一次性产物回答要运行代码才能解决的设计问题，结论由用户给出；不包含功能初稿。
- **researching** — 使用一手来源、逐条声明引用和发现项文件来调查问题；不包含设计本身。
- **domain-modeling** — 术语表（`CONTEXT.md`）和经过闸门筛选的 ADR 中的项目语言，范围限于术语漂移和决策记录；仅读取术语表不属于此技能。

## 贯穿全程 — 通用纪律

- **confirming-with-the-user** — 向用户呈现单个决策，包含选项、影响、建议和文字表述；负责跨技能界定哪些事由用户决定、哪些问题绝不提问。
- **verification-before-completion** — 每次完成声明前的证据要求，包含“完成 / 已修复 / 通过”声明。
- **honoring-user-requirements** — 长期台账和工作台账：每次会话开始、上下文压缩和开始新工作时先读再行动；按原意记录指令，每次返回和作出声明前用证据验证，确认后严格执行；异议由 `confirming-with-the-user` 约束。
- **keeping-work-in-flight** — 统计运行中的工作，为每个空闲的职责范围派发一次受追踪的调用，并在每次 agent 返回和轮次结束前读取；负责并行派发的独立性闸门和跨轮次延续。
- **continuous-work-mode** — 用户明确激活的结束前命令闸门，在轮次结束前检查队列，不重复请求继续；将 `keeping-work-in-flight` 机制化。
- **committing-work** — 将一次独立提交组织成连贯变更，使用明确路径、能证明变更的最小检查和独立可读的消息；不包含集成（`finishing-a-development-branch`）和代码判断（`code-auditing`）。
- **code-auditing** — 代码评审和审计，在阶段 1 分流：已完成工作推进前的检查点评审（评审从 merge-base 开始的差异范围，并对照要求检查），或对照宿主持续积累的检查清单审计标准符合性；按严重程度记录并处理发现项。

## 跨会话

- **writing-handoffs** — 用户明确请求的交接文档，供没有会话上下文的 agent 恢复工作。

## 独立技能

- **stress-testing-a-plan** — 用户明确请求的计划追问，不产出产物；构建意图归 `brainstorming`。
- **writing-skills** — 先测试，再创建或编辑技能。
- **writing-documentation** — 持久项目文档，每组文档只有一个入口，按任务信号路由到明确文件，并在同次变更中更新；不包含技能（`writing-skills`）、交接（`writing-handoffs`）、术语表或决策记录（`domain-modeling`）。
