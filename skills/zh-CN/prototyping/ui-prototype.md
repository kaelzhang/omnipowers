# UI 原型

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 形式 — 变体矩阵

变体矩阵 — 同一路由上的 UI 变体，在浏览器中通过 `?variant=` 查询参数和悬浮切换器切换。

结构不同的变体 — 布局、信息层级和主要操作入口均不同的变体，不含更换配色、微调文案、调整卡片网格间距。

- 问题关心逻辑或状态而非外观 → 返回 SKILL，读 @logic-prototype.md 并照做。
- 构建变体矩阵时 → 你 SHOULD 构建 3 个变体。
- 构建变体矩阵时 → 你 MUST NOT 超过 5 个变体。
- 对于变体矩阵 → 各变体 MUST 具有不同的结构。
- 两份草稿趋于同一结构时 → 你 MUST 在明确的结构约束下重做一份。
- 对于每个变体 → 它 MUST 使用宿主项目现有的组件库和样式系统。
- 对于每个变体 → 它 MUST 导出名称清晰的组件（`VariantA`、`VariantB`、…）。

## 嵌入真实页面

- 嵌入变体时 → 你 MUST 默认将变体嵌入现有真实页面，保留真实页头、侧栏、数据和信息密度。
- 没有合适的宿主页面时 → 你 MAY 创建空白新路由，仅限此条件。
- 创建空白新路由时 → 你 MUST 在设计问题旁记录没有宿主页面的原因。
- 对于空白新路由 → 它 MUST 遵循项目现有的路由约定。
- 对于空白新路由 → 它 MUST 使用一眼就能认出是原型的名称，路径中包含 `prototype`。

## 接线模板

```
// pseudo-code — adapt to the host framework's router and params API
variant = searchParams.get("variant") ?? "A"
render:
    variant == "A" -> <VariantA {...data} />
    variant == "B" -> <VariantB {...data} />
    variant == "C" -> <VariantC {...data} />
    <PrototypeSwitcher variants={["A", "B", "C"]} current={variant} />
```

## 接线规则

- 对于变体 → 它们 MAY 共享页面已有的小型叶子组件。
- 对于变体 → 它们 MUST NOT 共享布局外壳。
- 对于变体 → 它们 MUST NOT 触发真实写操作。

## 悬浮切换器

悬浮切换器 — 固定在视口底部中央的胶囊形控件，通过高对比度和阴影与页面区分。

- 切换变体时 → 切换操作 MUST 通过框架路由更新 `?variant=` 参数。
- input、textarea 或 contenteditable 元素获得焦点期间 → 切换器 MUST NOT 拦截左右方向键。

## 生产闸门

对于生产构建 → 变体和切换器 MUST 无法访问，通过宿主框架中等同于“非生产构建”的构建时开发检查控制。

## 交接

对于在原型约束下编写的代码 → 它 MUST NOT 原样进入生产环境。
