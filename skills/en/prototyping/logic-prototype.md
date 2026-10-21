# Logic Prototype

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Shape

- The question is what something should *look like* → return to the SKILL, read @ui-prototype.md and apply it.
- When building a prototype → you MUST NOT introduce a new package manager, runtime, or styling library.

## Pure Core, Throwaway Shell

Logic prototype — exactly two layers: a pure core and a throwaway shell.

Pure core — the state model or logic under question, exposing a small interface called by the shell.

Throwaway shell — the terminal driver that reads keys, calls the core, and renders frames, owning all I/O with nothing flowing from the shell into the core.

- When building a logic prototype → you MUST NOT blur the pure core and throwaway shell.
- For the pure core → it MUST be pure, with no I/O, terminal codes, prompts, or logging for control flow.
- Once the core is validated and the real implementation is being built → the core MAY be lifted into that implementation.
- For the throwaway shell → it MUST NOT ship anywhere.

## The Full-Frame Terminal Recipe

- For the terminal UI → the whole frame MUST fit on one screen.
- When the core is a state machine → the key legend MUST show only actions legal in the current state, or visibly mark the illegal ones.

## Terminal Loop Template

ESC — the escape byte: `\x1b` / `\033` / `chr(27)`.

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
