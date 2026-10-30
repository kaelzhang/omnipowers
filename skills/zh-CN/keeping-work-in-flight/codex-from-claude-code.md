# 从 Claude Code 派发 Codex

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

<!-- 覆盖记录（Kael，2026-10-24）：本文件和 dispatch-mechanics.md 中关于脱离形式的规则按用户的明确指令加入，覆盖了 writing-skills 要求先有一次失败的无技能基线的规定；Codex 基线对照组没有复现脱离式启动。 -->

范围 — Claude Code agent 把 Codex CLI（`codex exec`）作为 subagent 启动；其他宿主或其他委派对象都不在本文件范围内。

Codex 轮次 — 一个 `codex exec` 进程和它做的工作。

## 启动

- 启动一个 Codex 轮次时 → 你 MUST 发出一个 `run_in_background: true` 的 `Bash` 调用，命令本身就是 `codex exec` 调用。
- 启动一个 Codex 轮次时 → 你 MUST NOT 把 `codex exec` 包进循环、子 shell `( … & )`、包装脚本、watcher 进程、`nohup`、`disown` 或 `setsid`。
- 启动 N 个 Codex 轮次时 → 你 MUST 发出 N 个独立的 `Bash` 调用。
- 编写命令时 → 命令 MUST 采用以下形式：

```bash
codex exec -m <model> -c model_reasoning_effort=<effort> -s <sandbox> -C <workdir> -o <last-message-file> - < <brief-file>
```

- 编写命令时 → stdin MUST 来自 brief 文件（`- < <brief-file>`）或 `</dev/null`。
- 选择 `-m` 和 `model_reasoning_effort` 时 → 你 MUST 按用户或宿主的指令取值。
- `<workdir>` 不在 Codex 信任的 git 仓库内时 → 命令 MUST 带上 `--skip-git-repo-check`。
- 轮次要写文件时 → `-C` MUST 指向这个轮次自己的 worktree。
- 轮次依赖它的 worktree 创建之后目标分支上的改动时 → 你 MUST 在派发前把这些改动带进它的 worktree。
- 同时启动多个轮次时 → 每个轮次的 `-o` 文件和报告文件 MUST 是不同的路径。

## 沙箱

- 轮次只读时 → 你 SHOULD 使用 `-s read-only`。
- 轮次要写文件、构建或运行测试，且不需要下一条列出的任何能力时 → 你 SHOULD 使用 `-s workspace-write`。
- 轮次本身或它运行的测试、工具要绑定或连接 Unix socket、启动它需要观察的服务或守护进程、统计进程数、读取 `sysctl` 或使用网络时 → 你 MUST 使用 `-s danger-full-access`。
- 测试在 `-s workspace-write` 下以 `Operation not permitted` 失败时 → 在用 `-s danger-full-access` 重跑之前，你 MUST NOT 把失败归为环境问题。
- 轮次在 `-s danger-full-access` 下运行时 → 它的 brief MUST 写明理由。
- 轮次在 `-s workspace-write` 下运行时 → 它的 brief MUST 要求 Codex 在 `ps` 或 `sysctl` 被拒时报告“cannot prove”，绝不报告数量为 0。

## brief

- 编写 Codex 轮次的 brief 时 → brief MUST 带上这个轮次要遵守的每一条规则。

编写 Codex 轮次的 brief 时 → brief MUST 写明：

1. 这个轮次能改哪些路径，其他路径一律不碰。
2. 这个轮次能改测试文件还是产品文件；另一类文件一个都不改；认为自己职责之外的文件有错时，停下来报告。
3. 不创建或切换分支，不提交，不推送。
4. 任何地方都不加署名行。
5. 构建和测试在前台运行，拆成每步都能在一次工具调用内完成的若干步，不用 `&`、`nohup`、sleep 循环或轮询循环。
6. 工具把哪条命令转到了后台，就在报告里写明这条命令的完整命令行、日志路径和工作目录。
7. 做不到的事写进报告，并且它 MUST NOT 悄悄缩小范围。
8. 详细报告的路径和格式，这个路径不在提交这个轮次的路径时会被纳入的任何目录里。

## 读取结果

- 通知表明轮次可能仍在运行时 → 在轮次最终的退出通知到达之前，你 MUST NOT 读取它的结果、提交它的 worktree 或收尾它的 worktree。
- 轮次退出时 → 你 MUST 读取它的 `-o` 文件和报告文件。
- 轮次退出时 → 你 MUST NOT 从 harness 捕获的 stdout 里读取这个轮次的结果。
- 轮次的报告声明了某个结果时 → 你 MUST 先按 `verification-before-completion` 验证，再依赖这个结果。
- 轮次的通过结果来自它自己的构建目录或沙箱时 → 你 MUST 先在宿主环境里重跑起决定作用的命令，再依赖这个结果。

## 运行很久或没有输出的轮次

- 轮次的输出没有变化时 → 你 MUST NOT 仅凭这一点断定轮次卡住了。
- 判断轮次是否卡住时 → 你 MUST 检查它的 worktree 里文件的修改时间是否在推进，以及它是否还有存活的子进程。
- 检查某个 Codex 进程是否存活时 → 你 MUST 用 `ps ax -o command=` 列出进程，并用第一个字段匹配可执行文件（`awk '$1 ~ /codex$/'`）。
- 检查某个 Codex 进程是否存活时 → 你 MUST NOT 在 `command=` 前面加任何列。
- 检查某个 Codex 进程是否存活时 → 你 MUST NOT 按参数字符串匹配。
- 结束一个轮次时 → 你 MUST 用 `TaskStop` 按这个轮次的任务 ID 停止它。
- 结束一个轮次时 → 你 MUST NOT 使用 `kill` 或 `pkill`。
- `TaskStop` 已返回而这个轮次的 Codex 进程仍在运行时 → 你 MUST 按可执行文件那一列和它的 worktree 路径确认这个进程，并报告给用户。
- 被停止的轮次留下了改了一半的文件时 → 你 MUST 先检查它的 worktree，再决定保留还是丢弃。
- 另一个轮次可能正在写某个路径时 → 你 MUST NOT 对这个路径运行 `git restore` 或 `git reset`。

## 并行轮次

- 多个轮次同时运行且构建工具是 cargo 时 → 每个 worktree MUST 设置自己的 `CARGO_TARGET_DIR`。
- 两个轮次会改同一个包的文件时 → 你 MUST NOT 让它们同时运行。
- 一个轮次需要另一个轮次尚未合并的分支时 → 你 MUST 在派发前把那条分支合并进这个轮次的 worktree。
- 一个轮次需要另一个轮次尚未合并的分支时 → 你 MUST NOT 为此把那条分支合并进它的目标分支。
- 决定同时运行多少个轮次时 → 你 SHOULD 按机器负载限制数量。
