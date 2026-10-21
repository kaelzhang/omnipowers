#!/usr/bin/env bash
# Compare each translated locale with the English source.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "== locale parity =="
python3 "$SCRIPT_DIR/locale_parity.py"
