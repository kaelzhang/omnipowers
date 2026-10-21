"""Chinese style gate: narrative markers, modal words, and mid-sentence wraps.

Frontmatter, fenced code, inline code, quoted text, and blockquotes are exempt.
    python3 style_gate_zh.py [path ...]  # default: skills/zh-CN/**/*.md
"""
import pathlib
import re
import sys

from style_gate import EXEMPT, ROOT

MARKERS = re.compile(
    r"因为|所以|其实|通常|往往|比如|例如|换句话说|值得注意|需要注意|实际上|事实上|总之"
    r"|必须|务必|应该|应当|不应|不得|禁止|严禁|不宜|可以|允许|不必|无须|无需"
)
CJK = r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\U00020000-\U000323af]"


def targets(argv):
    if argv:
        return [pathlib.Path(a) for a in argv]
    return sorted((ROOT / "skills" / "zh-CN").rglob("*.md"))


def scan(path):
    hits = []
    in_code = False
    in_frontmatter = False
    previous = ""
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
            previous = ""
            continue
        if in_code or s.startswith(">"):
            previous = ""
            continue
        prose = EXEMPT.sub("", line).strip()
        for match in MARKERS.finditer(prose):
            hits.append((n, match.group(0), s))
        # Use the original boundaries so an exempt span cannot create a wrap.
        if re.search(CJK + r"$", previous) and re.match(CJK, s) and re.match(CJK, prose):
            hits.append((n, "mid-sentence wrap", s))
        previous = s if re.search(CJK + r"$", prose) else ""
    return hits


def main(argv):
    if not argv and not (ROOT / "skills" / "zh-CN").is_dir():
        print("no zh-CN locale")
        return 0
    total = 0
    for path in targets(argv):
        for n, word, text in scan(path):
            total += 1
            try:
                rel = path.resolve().relative_to(ROOT)
            except ValueError:
                rel = path
            print(f"{rel}:{n}: [{word}] {text[:140]}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
