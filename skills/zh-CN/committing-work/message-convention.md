# 提交说明回退约定

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

回退适用条件 — 宿主项目没有提交说明约定，用户指示、已声明的 `vcs` 约定、贡献指南、commit-lint 配置和现有历史中的一致格式均未提供此类约定。

## 标题

```text
type(scope): imperative summary
```

- 编写回退摘要时 → 摘要 MUST 使用祈使句（"add"、"fix"、"remove"，而非 "added"、"adds"、"fixing"）。
- 编写回退摘要时 → 摘要 MUST 具体描述提交改变的内容，让读者不用查看 diff 就能知道主题。
- 编写回退摘要时 → 摘要 MUST NOT 以句号结尾。
- 编写回退摘要时 → 摘要 SHOULD 控制在约 72 个字符内。

## 类型

| 类型 | 用途 |
|---|---|
| `feat` | 新增面向用户或 API 的能力 |
| `fix` | 修复 bug |
| `docs` | 仅文档 |
| `test` | 仅测试 |
| `refactor` | 保持行为的结构调整 |
| `perf` | 性能改进 |
| `style` | 仅调整源码格式，不改变语义 |
| `build` | 构建系统、打包、依赖、生成的构建元数据 |
| `ci` | 持续集成配置 |
| `chore` | 上述类型未覆盖的仓库维护 |
| `revert` | 撤销先前提交 |

## 范围

范围 — 发生改动的模块、包、服务、应用、子系统或文档区域。

- 编写回退 scope 时 → scope MUST NOT 使用 agent、模型、助手、工具或运行环境的名称。

## 正文

diff 无法回答为何改动 → 正文是 REQUIRED 的。

编写回退正文时 → 正文 MUST 涵盖：

1. **缺口** — 问题，或当前行为的不足。
2. **方案** — 本次提交如何处理。
3. **验证** — 运行了什么，结果说明了什么。

作出了重要设计选择 → 正文 SHOULD 同时写明放弃的方案及原因。

编写回退正文时 → 正文 MUST 独立成文：不引用对话、会话、私人笔记或仅持有仓库的读者无法查看的内容。

## 破坏性改动

```text
feat(config)!: require an explicit timeout unit
```

```text
feat(config): require an explicit timeout unit

BREAKING CHANGE: 启动时拒绝无单位的数值超时配置，不再按秒读取。为每个超时值添加显式单位后缀（`30s`、`500ms`）。
```
