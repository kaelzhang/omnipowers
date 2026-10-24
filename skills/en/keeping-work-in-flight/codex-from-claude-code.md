# Dispatching Codex from Claude Code

> Normative keywords — MUST, MUST NOT, SHOULD, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

<!-- Override record (Kael, 2026-10-24): this file and the detached-form rule in dispatch-mechanics.md were added at the user's explicit instruction, overriding the writing-skills requirement of a failing no-skill baseline; the Codex baseline control did not reproduce the detached launch. -->

Scope — a Claude Code agent launching the Codex CLI (`codex exec`) as a subagent; no other host or delegate falls under this file.

Codex round — one `codex exec` process and the work it does.

## Launch

- Launching a Codex round → you MUST issue one `Bash` call with `run_in_background: true` whose command is the `codex exec` invocation itself.
- Launching a Codex round → you MUST NOT wrap `codex exec` in a loop, a subshell `( … & )`, a wrapper script, a watcher process, `nohup`, `disown`, or `setsid`.
- Launching N Codex rounds → you MUST issue N separate `Bash` calls.
- Writing the command → it MUST take this shape:

```bash
codex exec -m <model> -c model_reasoning_effort=<effort> -s <sandbox> -C <workdir> -o <last-message-file> - < <brief-file>
```

- Writing the command → stdin MUST come from the brief file (`- < <brief-file>`) or from `</dev/null`.
- Choosing `-m` and `model_reasoning_effort` → you MUST take them from the user's or the host's instruction.
- `<workdir>` is outside a git repository Codex trusts → the command MUST carry `--skip-git-repo-check`.
- A round writes files → `-C` MUST point at that round's own worktree.
- A round depends on mainline changes made after its worktree was created → you MUST bring them into its worktree before dispatching it.
- Launching rounds concurrently → each round's `-o` file and report file MUST be distinct paths.

## Sandbox

- A round only reads → you SHOULD use `-s read-only`.
- A round writes files, builds, or runs tests, and needs nothing listed in the next rule → you SHOULD use `-s workspace-write`.
- A round starts a server or daemon it must observe, binds or connects to a Unix socket, counts processes, or uses the network → you MUST use `-s danger-full-access`.
- A round runs under `-s danger-full-access` → its brief MUST state why.
- A round runs under `-s workspace-write` → its brief MUST instruct Codex to report "cannot prove" when `ps` or `sysctl` is denied, never a count of 0.

## The brief

- Writing a Codex round's brief → it MUST carry every rule the round follows.

Writing a Codex round's brief → the brief MUST state:

1. The paths the round may change, and that every other path is off limits.
2. Which of test files and production files the round may change; that it changes no file of the other kind; and that it stops and reports when it believes a file outside its role is wrong.
3. That it creates or switches no branch, commits nothing, and pushes nothing.
4. That it adds no attribution trailer anywhere.
5. That builds and tests run in the foreground, split into steps that each finish within one tool call, with no `&`, `nohup`, sleep loop, or poll loop.
6. That any command its tool moved to the background is named in its report with its exact command line, log path, and working directory.
7. That anything it cannot do goes into its report, and that it MUST NOT narrow the scope silently.
8. The path and format of its detailed report, outside every directory a commit of the round's paths would include.

## Reading the result

- A notification says the round may still be running → you MUST NOT read its result, commit its worktree, or finish its worktree before the round's final exit notification.
- A round exits → you MUST read its `-o` file and its report file.
- A round exits → you MUST NOT read the harness's captured stdout for the round's result.
- A round's report claims a result → you MUST verify it under `verification-before-completion` before relying on it.
- A round's passing result came from its own build directory or sandbox → you MUST rerun the decisive command in the host environment before relying on it.

## A long or silent round

- A round's output has not changed → you MUST NOT conclude from that alone that the round is stuck.
- Judging whether a round is stuck → you MUST check whether its worktree's file modification times advance and whether it has live child processes.
- Checking whether a Codex process is alive → you MUST list processes with `ps ax -o command=` and match the first field against the executable (`awk '$1 ~ /codex$/'`).
- Checking whether a Codex process is alive → you MUST NOT add a column before `command=`.
- Checking whether a Codex process is alive → you MUST NOT match the argument string.
- Ending a round → you MUST use `TaskStop` with the round's task ID.
- Ending a round → you MUST NOT use `kill` or `pkill`.
- `TaskStop` has returned and a Codex process of that round still runs → you MUST identify it by the executable column and its worktree path and report it to the user.
- A stopped round left partial changes → you MUST inspect its worktree before keeping or discarding them.
- Another round may be writing a path → you MUST NOT run `git restore` or `git reset` on that path.

## Parallel rounds

- Rounds run concurrently and the build tool is cargo → each worktree MUST set its own `CARGO_TARGET_DIR`.
- Two rounds would change files of the same package → you MUST NOT run them concurrently.
- A round needs another round's unmerged branch → you MUST merge that branch into the round's worktree before dispatching it.
- A round needs another round's unmerged branch → you MUST NOT merge that branch into the mainline for that purpose.
- Choosing how many rounds run at once → you SHOULD limit the count by the machine's load.
