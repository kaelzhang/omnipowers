# 安装轮次结束闸门

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 安装内容

- 用户已开启模式时 → 你 MUST NOT 再次请求安装闸门的授权。
- 确认模式已启用时 → 你 MUST 点明修改的文件。

## 轮次结束契约

对每种宿主机制，安装结果 MUST 满足以下四项：

- 在 agent 即将结束轮次时运行，而非结束后运行；
- 非零退出状态表示拒绝，并能阻止轮次结束；
- 闸门输出的文本能送达 agent，而非只写入日志；
- 无法清除的发现项不会永久阻塞。

- 闸门变体无条件阻塞时 → 你 MUST NOT 安装它。

## Claude Code

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/checkpoint.sh --gate" }
        ]
      }
    ]
  }
}
```

- 宿主提供任务完成或 subagent 停止事件时 → 你 SHOULD 在对应事件上注册相同命令。

## 没有 hook 机制的宿主

- 不存在轮次结束 hook 时 → 你 MUST NOT 声称模式已由机制保障。

## 移除闸门

闸门移除 — 删除 hook 注册项、已安装的 `checkpoint.sh`，以及工作台中的 `.omnipowers/continuous-mode`、`.omnipowers/continuous-mode.owner` 和 `.omnipowers/continuous-gate.last`。

模式结束 — 模式对应目标已交付，与单轮结束不同。

- 模式结束时 → 你 MUST 在删除哨兵文件的同一步移除闸门。
- 移除闸门时 → 你 MUST NOT 请求授权。
- 安装闸门所对应的工作已结束时 → 闸门 MUST NOT 继续保留。
