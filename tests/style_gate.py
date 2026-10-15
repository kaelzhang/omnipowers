"""Style gate: a skill sentence is a rule, a definition, or a template.

Flags the narrative markers that mean a sentence explains, justifies, or tells a
story instead of stating a rule. Text inside fenced code blocks, inline code,
and double quotes is exempt: templates and red-flag thoughts are reproduced
verbatim, not stated.

    python3 style_gate.py [path ...]     # default: skills/ and AGENTS.md
Exit 1 and one line per hit when anything is flagged.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

MARKERS = re.compile(
    r"\b(?:"
    r"because|which is why|that is why|this is (?:how|why)|so that|in order to"
    r"|the reason|the point is|the whole point|is a smell|strong smell"
    r"|buys nothing|is paid for|in practice|tends to|for example|e\.g\."
    r"|for instance|in other words|note that|keep in mind|remember that"
    r")\b",
    re.IGNORECASE,
)
EXEMPT = re.compile(r"`[^`]*`|\"[^\"]*\"|“[^”]*”|「[^」]*」")


def targets(argv):
    if argv:
        return [pathlib.Path(a) for a in argv]
    return sorted((ROOT / "skills").rglob("*.md")) + [ROOT / "AGENTS.md"]


def scan(path):
    hits = []
    in_code = False
    in_frontmatter = False
    for n, line in enumerate(path.read_text(encoding="utf-8").split("\n"), 1):
        s = line.strip()
        if n == 1 and s == "---":
            in_frontmatter = True
            continue
        if in_frontmatter:
            if s == "---":
                in_frontmatter = False
            continue
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code or s.startswith(">"):
            continue
        m = MARKERS.search(EXEMPT.sub("", line))
        if m:
            hits.append((n, m.group(0), s))
    return hits


def main(argv):
    total = 0
    for path in targets(argv):
        for n, word, text in scan(path):
            total += 1
            rel = path.resolve().relative_to(ROOT)
            print(f"{rel}:{n}: [{word}] {text[:140]}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
