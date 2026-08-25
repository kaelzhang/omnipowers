# After the Design

> Normative keywords — MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this once the user has approved the design and before any implementation begins.

### Documentation

- The spec is a **durable design document**. You MUST resolve where it goes in this order, stopping at the first that applies: (1) a location the user states in this session; (2) the host's `Omnipowers` declaration — a section by that name in the host's `AGENTS.md` / `CLAUDE.md`, or in a document that file points to — using its `design-docs` row; (3) where the host already keeps design documents, when that is unambiguous; (4) the fallback `docs/design/YYYY-MM-DD-<topic>.md`.
- Resolved to 3 or 4 → MUST be confirmed with the user before the project's first spec is written. Resolved to 1 or 2 → MUST NOT ask.
- You MUST create any missing parent directories.
- The spec SHOULD follow the structure in `@spec-template.md` (read it when writing the spec); its **Out of Scope** section is REQUIRED.
- The spec MUST NOT embed file paths, line numbers, or code — the implementation plan carries them. A prototype-derived snippet MAY be embedded ONLY when the snippet itself is the recorded decision.
- You MUST place the design document under version control, following the host's declared `vcs` convention where it has one and an ordinary commit otherwise.
- The host declares a `write-authority` model → you MUST obtain authorization through it before writing; the user's approval of the design is not by itself authority to write where the host does not permit.

### Spec self-review

After writing the spec, you MUST review it with fresh eyes and fix any issues inline:

1. **Placeholder scan** — any "TBD", "TODO", incomplete section, or vague requirement MUST be resolved.
2. **Internal consistency** — sections MUST NOT contradict each other; the architecture MUST match the feature descriptions.
3. **Scope check** — the spec MUST be focused enough for a single implementation cycle; if not, it MUST be decomposed.
4. **Ambiguity check** — any requirement open to two interpretations MUST be narrowed to one explicit meaning.

Fix issues inline; you need not re-review after fixing.

### User review gate

- The self-review passes → you MUST ask the user to review the written spec before proceeding, and you MUST wait for their response.
- They request changes → you MUST make them and re-run the spec self-review.
- You MUST proceed only once the user approves.

### Transition to implementation

- Only after the user approves the written spec MAY you begin implementation.
- The host project provides a planning or implementation-planning skill → you SHOULD invoke it next to turn the approved spec into an implementation plan; which one depends on what the host offers.
