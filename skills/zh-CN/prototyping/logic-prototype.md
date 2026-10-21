# 逻辑原型

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 形式

- 问题关心的是*外观* → 返回 SKILL，读 @ui-prototype.md 并照做。
- 构建原型时 → 你 MUST NOT 引入新的包管理器、运行时或样式库。

## 纯核心与一次性外壳

逻辑原型 — 恰好两层：纯核心与一次性外壳。

纯核心 — 待探索的状态模型或逻辑，通过小接口供外壳调用。

一次性外壳 — 读取按键、调用核心、渲染帧的终端驱动，负责全部 I/O，外壳内容不流入核心。

- 构建逻辑原型时 → 你 MUST NOT 混淆纯核心与一次性外壳。
- 对于纯核心 → 它 MUST 保持纯粹，不包含 I/O、终端控制码、提示语，或用于控制流程的日志。
- 核心已验证且正在构建正式实现时 → 核心 MAY 移入正式实现。
- 对于一次性外壳 → 它 MUST NOT 随任何产物交付。

## 终端整帧方案

- 对于终端 UI → 整帧 MUST 能在一屏内显示。
- 核心是状态机时 → 按键图例 MUST 只显示当前状态合法的操作，或直观标明非法操作。

## 终端循环模板

ESC — 转义字节：`\x1b` / `\033` / `chr(27)`。

```
CLEAR = ESC "[2J" ESC "[H"        # wipe screen, cursor to home
BOLD  = ESC "[1m"    DIM = ESC "[2m"    RESET = ESC "[0m"

state = core.initial()
loop:
    print CLEAR                                  # replace the frame, don't append
    print BOLD "STATE" RESET
    for field in state:  print "  " name ": " value
    print BOLD "[a]" RESET DIM " add " RESET BOLD "[t]" RESET DIM " tick " RESET BOLD "[q]" RESET DIM " quit" RESET
    key = read_one_keystroke()
    if key == "q": break
    state = core.dispatch(state, key)            # the shell forwards; the core decides
```
