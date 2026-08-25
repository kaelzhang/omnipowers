#!/usr/bin/env bash
# Frontmatter integrity — runs free, on every `make test`.
# Catches the failure that has shipped twice: a bare colon inside an unquoted
# description value, which makes the whole skill unparseable to its host.
set -uo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "== frontmatter =="
fail=0; ran=0

for md in "$DIR"/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$md")")"
  ran=$((ran + 1))
  out="$(python3 - "$md" "$name" <<'PY'
import sys, re
path, dirname = sys.argv[1], sys.argv[2]
src = open(path, encoding="utf-8").read()
if not src.startswith("---\n"):
    print("no frontmatter block"); sys.exit(1)
end = src.find("\n---\n", 4)
if end == -1:
    print("frontmatter block is not closed"); sys.exit(1)
fm = src[4:end]
try:
    import yaml
    d = yaml.safe_load(fm)
    if not isinstance(d, dict):
        print("frontmatter is not a mapping"); sys.exit(1)
    keys = set(d)
except ImportError:
    # No PyYAML: catch the one failure mode that matters, by hand.
    d, keys = {}, set()
    for line in fm.split("\n"):
        m = re.match(r'^([A-Za-z_][\w-]*):\s*(.*)$', line)
        if not m:
            continue
        k, v = m.group(1), m.group(2)
        keys.add(k); d[k] = v
        if v and v[0] not in "\"'" and re.search(r':\s', v):
            print(f"unquoted '{k}' contains a bare colon — YAML will not parse it")
            sys.exit(1)
for k in ("name", "description"):
    if k not in keys:
        print(f"missing '{k}'"); sys.exit(1)
if str(d["name"]).strip() != dirname:
    print(f"name '{d['name']}' does not match directory '{dirname}'"); sys.exit(1)
body = re.search(r'^description:(.*)$', fm, re.M)
if body and body.group(1).strip() == "":
    print("description is empty or wrapped onto the next line"); sys.exit(1)
PY
)"
  if [ -n "$out" ]; then echo "  ✗ $name — $out"; fail=1; else echo "  ✓ $name"; fi
done

echo "  → checked=$ran failed=$fail"
[ "$fail" = 0 ] || exit 1
