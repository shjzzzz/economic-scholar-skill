#!/usr/bin/env bash
# normalize-eol.sh [--apply] [dir]  - find (and with --apply, fix) CRLF in tool/skill text files.
# Dry-run by default: lists files, changes nothing. Content-preserving (strips the trailing CR only);
# git can undo it. Exit 1 if CRLF files exist and --apply was not given, else 0.
set -uo pipefail
APPLY=0; [ "${1:-}" = "--apply" ] && { APPLY=1; shift; }
ROOT="${1:-${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}}"
N=0
while IFS= read -r -d '' f; do
  grep -q $'\r' "$f" 2>/dev/null || continue
  N=$((N+1))
  if [ "$APPLY" = 1 ]; then sed -i 's/\r$//' "$f"; else echo "CRLF  ${f#$ROOT/}"; fi
done < <(find "$ROOT" \( -path '*/.git' -o -path '*/node_modules' \) -prune -o -type f \
  \( -name '*.sh' -o -name '*.py' -o -name '*.md' -o -name '*.tsv' -o -name '*.json' -o -name '*.ndjson' \
     -o -name '*.toml' -o -name '*.R' -o -name '*.tex' -o -name '.env*' -o -name '.gitignore' \) -print0)
if [ "$APPLY" = 1 ]; then echo "normalized $N file(s) to LF"; exit 0; fi
echo "$N file(s) with CRLF (dry-run; use --apply to fix)"; [ "$N" -eq 0 ]
