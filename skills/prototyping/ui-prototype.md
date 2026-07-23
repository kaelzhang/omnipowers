# UI Prototype

**Load this reference when:** the prototype's question is about UI, layout, information hierarchy, or what a page or screen should look like.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Shape — a Variant Matrix

Build **N structurally different variations** of the UI on a single route, switchable in the browser via a `?variant=` query param and a floating switcher. The user flips between them live and picks a winner — or composes one ("the header from B with the sidebar from C"; that composite is usually the real answer). If the question is about logic or state rather than looks, this is the wrong branch — return to the SKILL and take @logic-prototype.md.

- You SHOULD build 3 variants; you MUST NOT exceed 5 — beyond that, variants stop being structurally different and become noise.
- Variants MUST be **structurally different**: different layout, different information hierarchy, different primary affordance. Palette swaps, copy tweaks, and re-spaced card grids are not variants — they answer no structural question. If two drafts converge on the same structure, you MUST redo one under an explicit structural constraint (e.g. "no card grid").
- Each variant MUST use the host project's existing component library and styling system, and MUST export a clearly named component (`VariantA`, `VariantB`, …).

## Embed in a Real Page

You MUST embed the variants in a **real, existing page** by default — real header, real sidebar, real data, real density. An empty route is a vacuum: every variant looks fine in isolation, and the density and hierarchy problems the prototype exists to test stay hidden. If the thing being prototyped has no page yet but would naturally live inside one (a new dashboard section, a new settings card, a new step in an existing flow), it is still embedded — mount the variants inside that host page. Keep the host page's data fetching, params, and auth intact; only the rendered subtree swaps per variant.

You MAY create a bare new route ONLY when no plausible host page exists (a genuinely new top-level surface), and you MUST record next to the written question why no host page exists. The bare route MUST follow the project's existing routing conventions and MUST be named as an obvious prototype (the word `prototype` in the path).

## Wiring

One switcher on the route reads the query param and renders the matching variant:

```
// pseudo-code — adapt to the host framework's router and params API
variant = searchParams.get("variant") ?? "A"
render:
    variant == "A" -> <VariantA {...data} />
    variant == "B" -> <VariantB {...data} />
    variant == "C" -> <VariantC {...data} />
    <PrototypeSwitcher variants={["A", "B", "C"]} current={variant} />
```

- Variants MAY share small leaf components the page already has (a real `<Header>`); they MUST NOT share a layout shell — each variant must be free to throw the layout away, or the matrix cannot disagree about structure.
- Variants MUST NOT trigger real mutations. Read-only against real data is ideal; where a variant needs a mutation to be judged, point it at a stub.

## The Floating Switcher

A small fixed pill at the bottom-center of the viewport, visually distinct from the page (high contrast, shadow) so it is obviously not part of the design under evaluation:

- **Prev / next arrows** cycle through the variants with wraparound; the label between them shows the current key and, when available, the variant's name (`B — sidebar layout`).
- Switching MUST update the `?variant=` param through the framework's router, so every variant is shareable by URL and stable across reloads.
- Left/right arrow keys also cycle, but the switcher MUST NOT intercept them while an input, textarea, or contenteditable element is focused.
- Build the switcher once, as a single shared component, wherever the project keeps shared UI.

## Production Gate

The variants and the switcher MUST be unreachable in production builds — gate them behind a build-time development check (the host framework's equivalent of "not a production build"). Without the gate, one stray merge ships the prototype matrix to real users.

## Hand-Over

Give the user the URL and the variant keys; they flip through in the browser and deliver the verdict. Code written under prototype constraints MUST NOT be promoted to production as-is — when the design is implemented, the winning structure is rebuilt properly. The written question, hygiene, verdict, and capture are governed by the SKILL.
