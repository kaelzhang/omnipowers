# UI Prototype

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Shape — a Variant Matrix

Variant matrix — UI variations on one route, switchable in the browser through a `?variant=` query parameter and a floating switcher.

Structurally different variants — variants with different layout, different information hierarchy, and different primary affordance, excluding palette swaps, copy tweaks, and re-spaced card grids.

- The question is about logic or state rather than looks → return to the SKILL, read @logic-prototype.md and apply it.
- When building the variant matrix → you SHOULD build 3 variants.
- When building the variant matrix → you MUST NOT exceed 5 variants.
- For the variant matrix → variants MUST be structurally different.
- When two drafts converge on the same structure → you MUST redo one under an explicit structural constraint.
- For each variant → it MUST use the host project's existing component library and styling system.
- For each variant → it MUST export a clearly named component (`VariantA`, `VariantB`, …).

## Embed in a Real Page

- When embedding variants → you MUST embed them in a real, existing page by default, with its real header, sidebar, data, and density.
- When no plausible host page exists → you MAY create a bare new route ONLY under that condition.
- When creating a bare new route → you MUST record next to the written question why no host page exists.
- For a bare new route → it MUST follow the project's existing routing conventions.
- For a bare new route → it MUST be named as an obvious prototype, with the word `prototype` in the path.

## Wiring Template

```
// pseudo-code — adapt to the host framework's router and params API
variant = searchParams.get("variant") ?? "A"
render:
    variant == "A" -> <VariantA {...data} />
    variant == "B" -> <VariantB {...data} />
    variant == "C" -> <VariantC {...data} />
    <PrototypeSwitcher variants={["A", "B", "C"]} current={variant} />
```

## Wiring Rules

- For variants → they MAY share small leaf components the page already has.
- For variants → they MUST NOT share a layout shell.
- For variants → they MUST NOT trigger real mutations.

## The Floating Switcher

Floating switcher — a fixed pill at the bottom-center of the viewport, visually distinct from the page through high contrast and shadow.

- When switching variants → switching MUST update the `?variant=` parameter through the framework's router.
- While an input, textarea, or contenteditable element is focused → the switcher MUST NOT intercept left/right arrow keys.

## Production Gate

For production builds → the variants and switcher MUST be unreachable, gated behind a build-time development check using the host framework's equivalent of "not a production build".

## Hand-Over

For code written under prototype constraints → it MUST NOT be promoted to production as-is.
