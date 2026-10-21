# 按条件等待

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 核心原则

测试休眠任意时长（`sleep 50ms`、`wait(2s)`）→ 你 MUST 等待**真正关心的条件**，而非等待一段时长。

## 模式

```
# ❌ guessing at timing — a race condition
sleep(50)
assert getResult() is ready

# ✅ waiting for the condition — deterministic
waitFor(() => getResult() is ready, timeout = 5s)
assert getResult() is ready
```

`waitFor` — 有超时上限的轮询，反复检查条件，直到条件成立或超时：

```
function waitFor(condition, description, timeout = 5s, interval = 10ms):
    deadline = now() + timeout
    loop:
        if condition() is truthy: return its value
        if now() > deadline: fail("timed out waiting for " + description)
        sleep(interval)
```

## 规则

- 你 MUST 设置超时，并提供明确、点名条件的失败消息 — 条件始终不成立时，等待操作 MUST 明确报错，而非永久挂起。
- 你 MUST 在循环*内部*重新检查条件（每次轮询都读取最新状态）；你 MUST NOT 在循环前缓存状态。
- 你 SHOULD 按适中的间隔（约 10ms）轮询，而非尽可能快地轮询。

## 唯一例外 — 测试时序本身

被测行为就是时序（debounce、throttle、要触发 N 次的 interval）→ 你 MUST：(1) 先等待触发*条件*，(2) 按已知间隔确定时长，而非猜测，(3) 用注释说明时长的依据。
