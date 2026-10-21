---
name: domain-modeling
description: 构建或精炼项目的领域模型时使用，包括为概念命名、维护术语表 / ubiquitous language（CONTEXT.md）、记录 ADR，或术语发生漂移、重载、与代码矛盾时；你 MUST 将每个含糊术语收敛为一个规范定义，并在确定时立即记录
---

# 领域建模

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 四个动作

设计或讨论领域时 → 你 MUST 在每个触发条件出现时执行对应动作。

1. 术语的用法与术语表定义冲突 → 你 MUST 立即指出。
2. 词语含糊或承载多个含义 → 你 MUST 提出一个精确的规范术语，并列明它替代的词语。
3. 有人提出定义或关系 → 你 MUST 构造具体场景来探查边界。
4. 有人就领域如何运作作出声明时 → 你 MUST 检查代码是否一致，并指出所有矛盾。

## 确定时立即记录

- 术语已确定 → 你 MUST **立即**更新术语表。
- 更新术语表时 → 你 MUST NOT 拖到会话结束时批量处理。
- 编写或更新术语表时 → 读 `@context-format.md` 并照做。
- 决策通过下方 ADR 闸门 → 读 `@adr-format.md` 并照做。

## ADR — 三道闸门

- **难以逆转** — 日后更改决策有实际成本。
- **缺少背景就难以理解** — 未来读者会问为何这样做。
- **作过实际权衡** — 存在真实替代方案，并因明确理由选定一个。

决策未满足全部三道闸门 → 你 MUST NOT 创建 ADR。

## 产物位置

- 术语表和 ADR 的产物角色 — `design-docs`，位置按 `using-omnipowers` 解析；回退位置 — 术语表放在**宿主项目根目录**，命名为 `CONTEXT.md`，ADR 放在 `docs/adr/`。
- 放置术语表或 ADR 时 → 它 MUST NOT 位于 `.omnipowers/` 或任何仅供 agent 使用的目录下。

## 按需创建

- 创建产物时 → 你 MUST NOT 提前搭建尚未用到的产物，不创建空的 `CONTEXT.md` 或空的 `docs/adr/`。
- 产物不存在 → 你 MUST NOT 反复提醒。
