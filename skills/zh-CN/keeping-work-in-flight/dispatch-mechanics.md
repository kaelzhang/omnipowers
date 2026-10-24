# 派发机制

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 四种形式

受追踪的后台形式 — 宿主列为活跃工作的后台形式，退出时触发唤醒。

从前台调用脱离的形式 — 在前台调用中使用 `(cmd &)` 或 `nohup cmd & disown`，不触发唤醒。

会话脱离形式 — 形如 `setsid cmd &`，脱离到独立会话，几秒内报告完成但进程仍在运行，不触发唤醒。

超时的前台调用 — 已超过时限、仍保留调用标识的前台调用。

- 前台调用超时时 → 你 MUST NOT 假定它已完成。
- 形式属于会话脱离时 → 你 MUST NOT 使用它。
- 启动 subagent、委派的命令行运行或任何需要结果的工作时 → 你 MUST NOT 使用从前台调用脱离的形式。

## 委派的命令行运行

- 委派运行继承调用方的 stdin 时 → 你 MUST 明确关闭它。
- 委派的命令行运行产出报告时 → 报告 MUST 写入运行指定的文件，而非标准输出。

## 结束进程

- 结束进程时 → 你 MUST 只针对单个进程，且你 MUST 随后验证只有这个进程结束。
- 进程不是自己启动的时 → 你 MUST NOT 在查明依赖关系前结束它。

## 等待

- 即将启动工作时 → 工作 MUST 以受追踪的形式启动。
- 宿主原本能就这项工作通知你时 → 你 MUST NOT 轮询它。

```bash
for i in $(seq 1 9); do
  ps ax -o command= | awk '$1 ~ /cargo$/ {f=1} END {exit !f}' || break
  sleep 10
done
```

进程计数包含搜索进程时 → 你 MUST NOT 根据这个计数行动。
