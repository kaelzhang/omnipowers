#!/usr/bin/env bash
# Run the English and Chinese style gates independently.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "== style gates =="
fail=0
for gate in style_gate.py style_gate_zh.py; do
  if out="$(python3 "$SCRIPT_DIR/$gate" 2>&1)"; then
    echo "  ✓ $gate passed${out:+: $out}"
  else
    printf '%s\n' "$out" | sed 's/^/  ✗ /'
    fail=1
  fi
done
exit "$fail"
