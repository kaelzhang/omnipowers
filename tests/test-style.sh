#!/usr/bin/env bash
# Style gate: every sentence in a skill is a rule, a definition, or a template.
# Fails on the narrative markers style_gate.py lists, in skills/ and AGENTS.md.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "== style gate =="
if out="$(python3 "$SCRIPT_DIR/style_gate.py" 2>&1)"; then
  echo "  ✓ no narrative markers in skills/ or AGENTS.md"
  exit 0
fi
printf '%s\n' "$out" | sed 's/^/  ✗ /'
exit 1
