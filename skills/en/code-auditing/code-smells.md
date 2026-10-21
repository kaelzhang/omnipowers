# Code Smells Baseline — code-auditing

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Governing rules

- The host project's documented standards (coding-standards doc, contributor guide, style guide, lint or formatter configuration) conflict with this baseline → you MUST suppress the conflicting smell.
- A smell matches → you SHOULD flag the match.
- A smell is flagged → the flag MUST name the smell and state the concrete reasoning.
- A smell matches → you MUST NOT report it as an automatic defect, a rule breach, or a Critical issue on the smell's authority alone.
- The host's tooling detects or auto-fixes a smell → you SHOULD skip that smell.

## The baseline

Baseline entry — a smell definition and its reference fix direction in the table below.

| Smell | Definition | Fix direction |
|---|---|---|
| **Long Function** | One function carrying several jobs, readable only via internal comments or blank-line "paragraphs". | Extraction of each step into its own intention-named function. |
| **Duplicated Logic Block** | The same logic shape written out in two or more places, requiring a change to be repeated everywhere to preserve correctness. | Extraction of the shared shape once, with calls from every site. |
| **Feature Envy** | A function that works mostly with another module's data instead of its own. | Relocation of the function next to the data it keeps reaching for. |
| **Primitive Obsession** | A bare string/number/bool standing in for a real domain concept (an ID, money, a range, a state). | A dedicated type for the concept and its rules. |
| **Shotgun Surgery** | One logical change forcing small edits scattered across many files. | Consolidation of pieces that change together into one module. |
| **Divergent Change** | One module repeatedly edited for several unrelated reasons. | Separation into modules that each change for exactly one reason. |
| **Data Clump** | The same few fields or parameters always travelling together. | Bundling into one named type passed in place of the fields or parameters. |
| **Long Parameter List** | Enough parameters that call sites become unreadable or transposition-prone. | Grouping related parameters into an object, or derivation by the callee. |
| **Speculative Generality** | Abstraction, hooks, or parameters built for a future need nothing uses yet. | Deletion, with reintroduction when a real second use arrives. |
| **Message Chain** | A caller navigating `a.b().c().d()`, coupling itself to every link of the structure. | Encapsulation of the walk in one method on the object the caller already holds. |
| **Inappropriate Intimacy** | Two modules reading or manipulating each other's internals. | An explicit interface, or colocation of the entangled parts. |
| **Dead Code** | Code no path reaches — unused functions, unreferenced branches, commented-out blocks. | Deletion. |

## Reporting shape

A smell is flagged → it MUST carry three parts: the smell's name, the evidence in the diff (file and lines), and the fix direction from the table as a reference suggestion, never a mandate.
