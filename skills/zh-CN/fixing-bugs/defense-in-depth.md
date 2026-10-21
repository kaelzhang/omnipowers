# 纵深校验

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

你 SHOULD 在数据经过的每一层做校验。

bug 已随版本交付过一次 → 你 MUST NOT 把一处校验视为足够。

追踪无效值的来源和它经过的每个位置时 → 读 `@root-cause-tracing.md` 并照做。
