# Condition-Based Waiting

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Core principle

A test sleeps for an arbitrary delay (`sleep 50ms`, `wait(2s)`) → you MUST wait for **the actual condition you care about**, not for a duration.

## The pattern

```
# ❌ guessing at timing — a race condition
sleep(50)
assert getResult() is ready

# ✅ waiting for the condition — deterministic
waitFor(() => getResult() is ready, timeout = 5s)
assert getResult() is ready
```

`waitFor` — a bounded poll that repeatedly evaluates a condition until it is true or a timeout elapses:

```
function waitFor(condition, description, timeout = 5s, interval = 10ms):
    deadline = now() + timeout
    loop:
        if condition() is truthy: return its value
        if now() > deadline: fail("timed out waiting for " + description)
        sleep(interval)
```

## Rules

- You MUST include a timeout with a clear, named failure message — a condition that never becomes true MUST fail loudly, not hang forever.
- You MUST re-evaluate the condition *inside* the loop (read fresh state each poll); you MUST NOT cache the state before the loop.
- You SHOULD poll at a modest interval (~10ms), not as fast as possible.

## The one exception — testing timing itself

The behavior under test is timing (a debounce, a throttle, an interval that must tick N times) → you MUST: (1) first wait for the triggering *condition*, (2) base the duration on a known interval rather than a guess, and (3) comment why the duration is what it is.
