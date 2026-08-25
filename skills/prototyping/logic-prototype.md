# Logic Prototype

**Load this reference when:** the prototype's question is about state, logic, transitions, data shape, or API feel.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Shape

Build a tiny interactive terminal app the user drives by hand: press a key, watch the state change.

- The question is what something should *look like* → wrong branch; return to the SKILL and take @ui-prototype.md.
- Build in the host project's own language and runtime. You MUST NOT introduce a new package manager, runtime, or styling library for a prototype.

## Pure Core, Throwaway Shell

A logic prototype has exactly two layers, and you MUST NOT blur them:

- **The pure core** — the state model or logic under question. It MUST be pure: no I/O, no terminal codes, no prompts, no logging for control flow. It exposes a small interface the shell calls into.
- **The throwaway shell** — the terminal driver. It owns all I/O: it reads keys, calls the core, and renders frames. Nothing flows from the shell into the core.

Once validated, the core MAY be lifted into the real implementation when that implementation is built. The shell MUST NOT ship anywhere.

Pick the core's shape to fit the question, never to fit the shell:

- Actions are discrete events over a single state value → **a pure reducer**, `(state, action) -> state`.
- "Which actions are even legal right now" is part of the question → **an explicit state machine**.
- No current state, only transformations → **a set of pure functions over a plain data type**.
- The logic genuinely owns ongoing internal state → **a module with a clear method surface**.

## The Full-Frame Terminal Recipe

Drive the core with a full-frame terminal UI: on every tick, redraw the whole frame — **replace, never append**. The whole frame MUST fit on one screen.

Each frame, top to bottom:

1. **Current state** — pretty-printed, one field per line (or compact formatted JSON). Bold field names; dim secondary context (timestamps, ids, derived values).
2. **Valid actions** — a one-line key legend at the bottom. The core is a state machine → the legend MUST show only the actions legal in the current state, or visibly mark the illegal ones.

The loop: initialize state, render, read one keystroke, dispatch to the core, re-render, repeat until quit.

Sketch (language-agnostic; `ESC` is the escape byte — `\x1b` / `\033` / `chr(27)`; native escape codes suffice, no styling library):

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

Adapt the keystroke read to the host language (raw mode, getch, or line input).

## Hand-Over

Give the user the single run command from the host's task runner and the key legend, then let them drive. Add actions on request. The written question, hygiene, the verdict, and capture are governed by the SKILL.
