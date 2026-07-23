# Code Smells Baseline — requesting-code-review

> Normative keywords — MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

A portable code-quality baseline for reviewers: twelve classic structural smells that apply in any host project, including one that documents no coding standards of its own. Read this file when a review assesses code quality; it supplements the code-quality checks in the reviewer brief.

## Governing rules — read before the table

1. **The host repo overrides.** Wherever the host project's own documented standards (coding-standards doc, contributor guide, style guide, lint or formatter configuration) conflict with this baseline, the host's standard wins: you MUST suppress the conflicting smell. This baseline fills the gap where the host documents nothing; a finding that overrules a documented host standard is a false finding and wastes the owner's trust.
2. **Every smell is a labelled judgement call — never a hard violation.** A match is a heuristic signal, not proof of a defect. You SHOULD flag a match, and every flag MUST name the smell and state the concrete reasoning (e.g. "possible Feature Envy — `renderTotals()` reads five fields of `Invoice` and none of its own"). You MUST NOT report a smell as an automatic defect, a rule breach, or a Critical issue on the smell's authority alone — inflated severity buries the review's real findings. The code's owner decides whether the signal warrants a change; the table's fix direction is a reference suggestion, never a mandate.

You SHOULD skip any smell the host's tooling already detects or auto-fixes — duplicating a linter's report is noise.

## The baseline

Each entry is *what it is* → *how to fix*. Match against the diff under review, not the whole codebase.

| Smell | What it is | How to fix |
|---|---|---|
| **Long Function** | One function carrying several jobs, readable only via internal comments or blank-line "paragraphs". | Extract each step into its own intention-named function. |
| **Duplicated Logic Block** | The same logic shape written out in two or more places, so one change must be repeated everywhere to stay correct. | Extract the shared shape once; call it from every site. |
| **Feature Envy** | A function that works mostly with another module's data instead of its own. | Move the function next to the data it keeps reaching for. |
| **Primitive Obsession** | A bare string/number/bool standing in for a real domain concept (an ID, money, a range, a state). | Give the concept its own small type that carries its rules. |
| **Shotgun Surgery** | One logical change forcing small edits scattered across many files. | Gather the pieces that change together into one module. |
| **Divergent Change** | One module repeatedly edited for several unrelated reasons. | Split it so each resulting module changes for exactly one reason. |
| **Data Clump** | The same few fields or parameters always travelling together. | Bundle them into one named type; pass that instead. |
| **Long Parameter List** | Enough parameters that call sites become unreadable or transposition-prone. | Group related parameters into an object, or let the callee derive what it can itself. |
| **Speculative Generality** | Abstraction, hooks, or parameters built for a future need nothing uses yet. | Delete it; reintroduce the abstraction when a real second use arrives. |
| **Message Chain** | A caller navigating `a.b().c().d()`, coupling itself to every link of the structure. | Hide the walk behind one method on the object the caller already holds. |
| **Inappropriate Intimacy** | Two modules reading or manipulating each other's internals. | Narrow the contact to an explicit interface, or move the entangled parts together. |
| **Dead Code** | Code no path reaches — unused functions, unreferenced branches, commented-out blocks. | Delete it; version control keeps the history if it is ever needed again. |

## Reporting shape

Every flagged smell MUST carry three parts: the smell's name, the evidence in the diff (file and lines), and the fix direction from the table as a reference suggestion for the owner. A bare "this smells" with no evidence and no suggestion is not a finding.
