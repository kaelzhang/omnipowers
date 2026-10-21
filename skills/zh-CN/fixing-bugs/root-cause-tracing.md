# 追踪根因

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 核心原则

你 MUST 沿调用链反向追踪到最初的触发点，并在那里修复。你 MUST NOT 只在错误出现的位置修复。

源头已修复，正在考虑加固它经过的各层 → 读 `@defense-in-depth.md` 并照做。

## 执行纪律

```
找到直接原因
      │
      ▼
还能向上追踪一层吗？ ──否──▶ 已到源头 → 在这里修复
      │ 是
      ▼
沿错误值反向追踪
      │
      ▼
这是最初产生这个值的位置吗？ ──否──▶ 继续追踪
      │ 是
      ▼
在源头修复，再加固它经过的每一层（纵深校验）
```

你 MUST NOT 在第一个能编辑的栈帧处停止追踪。
