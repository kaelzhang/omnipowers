"""Check locale structure, normative force, pointers, fences, and shared scripts."""
from collections import Counter
from pathlib import Path
import os
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
KEYWORDS = (
    "MUST NOT", "SHOULD NOT", "SHALL NOT", "MUST", "SHOULD", "SHALL",
    "MAY", "REQUIRED", "RECOMMENDED", "OPTIONAL",
)
KEYWORD = re.compile(r"\b(?:" + "|".join(KEYWORDS) + r")\b")
POINTER = re.compile(r"@[\w.-]+\.md\b")


def counts(text):
    text = "\n".join(line for line in text.splitlines()
                     if not (line.startswith("> ") and "BCP 14" in line))
    return Counter(KEYWORD.findall(text))


def name(text):
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    match = re.search(r"^name:\s*(.*?)\s*$", text[4:end], re.M)
    return match.group(1).strip("\"'") if match else None


def files(directory):
    return {p.relative_to(directory).as_posix() for p in directory.rglob("*")
            if p.is_file() or p.is_symlink()}


def main():
    skills = ROOT / "skills"
    english = skills / "en"
    locales = sorted(p for p in skills.iterdir() if p.is_dir() and p.name != "en")
    if not locales:
        print("  ✓ no non-en locale")
        return 0
    failures = 0

    def compare(path, what, en, locale, other):
        nonlocal failures
        if en != other:
            print(f"{path.relative_to(ROOT)}: {what} en={en!r} {locale}={other!r}")
            failures += 1

    en_skills = {p.name for p in english.iterdir() if p.is_dir()}
    for locale in locales:
        local_skills = {p.name for p in locale.iterdir() if p.is_dir()}
        compare(locale, "skill dirs", sorted(en_skills), locale.name, sorted(local_skills))
        for skill in sorted(en_skills | local_skills):
            source, translated = english / skill, locale / skill
            en_files, local_files = files(source), files(translated)
            compare(translated, "file list", sorted(en_files), locale.name, sorted(local_files))
            # Validate shared scripts even when a file has no English counterpart.
            for filename in sorted(local_files):
                path = translated / filename
                if path.suffix == ".md":
                    continue
                target = os.readlink(path) if path.is_symlink() else None
                valid = (target is not None and not os.path.isabs(target)
                         and path.is_file() and (source / filename).is_file()
                         and path.resolve() == (source / filename).resolve())
                compare(path, "relative symlink to en file", True, locale.name, valid)
            for filename in sorted(en_files & local_files):
                path = translated / filename
                if path.suffix != ".md":
                    continue
                try:
                    en_text = (source / filename).read_text(encoding="utf-8")
                    text = path.read_text(encoding="utf-8")
                except (OSError, UnicodeError) as exc:
                    compare(path, "readable Markdown", "readable", locale.name, str(exc))
                    continue
                compare(path, "frontmatter name", name(en_text), locale.name, name(text))
                en_counts, local_counts = counts(en_text), counts(text)
                for keyword in KEYWORDS:
                    compare(path, keyword, en_counts[keyword], locale.name, local_counts[keyword])
                compare(path, "@ pointers", sorted(set(POINTER.findall(en_text))),
                        locale.name, sorted(set(POINTER.findall(text))))
                compare(path, "``` fences", len(re.findall(r"^\s*```", en_text, re.M)),
                        locale.name, len(re.findall(r"^\s*```", text, re.M)))
    if not failures:
        print(f"  ✓ parity passed for {', '.join(p.name for p in locales)}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
