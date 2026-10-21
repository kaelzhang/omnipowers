# 回归测试难写时

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

复现测试难以编写 → 你 MUST 仍然写出测试。

没有正确的接缝（测试只能耦合内部实现）→ 你 MUST 记录缺失的接缝，并在修复落地后向用户提出。

没有正确的接缝（测试只能耦合内部实现）→ 你 MUST NOT 跳过测试或通过内部实现测试。
