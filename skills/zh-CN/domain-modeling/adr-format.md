# ADR 格式

ADR 格式加载条件 — 决策已通过全部三道闸门（难以逆转、缺少背景就难以理解、作过实际权衡），且正在编写 ADR。

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 模板

```md
# {概括决策的短标题}

{YYYY-MM-DD}

{一段话：背景、决策和理由，包含选择的代价或排除的选项。}
```

模板外的章节、标题或字段没有实质内容 → 你 MUST NOT 添加。

## 可选章节

- 添加**替代方案**章节时 → 它 MAY 仅在未选方案值得记住，即日后有可能被再次提出时添加。
- 添加**后果**章节时 → 它 MAY 仅在某个不明显的后续影响需要留档时添加。
- 决策确实重新进入讨论时 → 文档 MAY 添加**状态**字段（`accepted | superseded by ADR-NNNN`）。
