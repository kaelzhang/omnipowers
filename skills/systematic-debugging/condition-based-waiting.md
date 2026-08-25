# Condition-Based Waiting

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Load this technique during `systematic-debugging` when the failure is a **flaky or timing-dependent test** — one that passes sometimes and fails under load, in parallel, or in CI.

## Core principle

A test sleeps for an arbitrary delay (`sleep 50ms`, `wait(2s)`) → you MUST wait for **the actual condition you care about**, not for a duration.

## The pattern

Replace the arbitrary delay with a bounded poll of the real condition:

```
# ❌ guessing at timing — a race condition
sleep(50)
assert getResult() is ready

# ✅ waiting for the condition — deterministic
waitFor(() => getResult() is ready, timeout = 5s)
assert getResult() is ready
```

`waitFor` repeatedly evaluates the condition until it is true or a timeout elapses:

```
function waitFor(condition, description, timeout = 5s, interval = 10ms):
    deadline = now() + timeout
    loop:
        if condition() is truthy: return its value
        if now() > deadline: fail("timed out waiting for " + description)
        sleep(interval)
```

Typical conditions: an expected event has arrived; a state machine reached the target state; a counter reached N; a file/record exists; a compound predicate holds.

## Rules

- You MUST include a timeout with a clear, named failure message — a condition that never becomes true MUST fail loudly, not hang forever.
- You MUST re-evaluate the condition *inside* the loop (read fresh state each poll); you MUST NOT cache the state before the loop.
- You SHOULD poll at a modest interval (e.g. ~10ms), not as fast as possible — busy-spinning can starve the very work you are waiting for.

## The one exception — testing timing itself

The behavior under test *is* the timing (a debounce, a throttle, an interval that must tick N times) → a measured wait is correct. Even then you MUST: (1) first wait for the triggering *condition*, (2) base the duration on a known interval rather than a guess, and (3) comment why the duration is what it is.
