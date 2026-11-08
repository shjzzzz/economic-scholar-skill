#!/usr/bin/env bash
# map-check.sh [--print]  - feature-map.tsv (stage -> skill -> input -> output -> gate -> human gate) must match the repo.
# Every internal skill must exist under skills/ and every named gate under scripts/gates.
# ext skills (qje-*/cie-*) are installed separately and are not checked. Exit 1 on any broken reference.
set -uo pipefail
ROOT="${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
M="$ROOT/skills/econ-paper/references/feature-map.tsv"
[ -f "$M" ] || { echo "FAIL  missing $M"; exit 1; }
[ "${1:-}" = "--print" ] && { column -t -s$'\t' "$M" 2>/dev/null || cat "$M"; exit 0; }
python3 - "$ROOT" "$M" <<'PY'
import sys,os
root,m=sys.argv[1:]; bad=0; n=0
for i,l in enumerate(open(m,encoding='utf-8')):
    c=l.rstrip('\n').split('\t')
    if i==0: continue
    if len(c)!=8: print("FAIL  line %d: %d columns, want 8"%(i+1,len(c))); bad=1; continue
    n+=1; stage,track,skill,_,_,gate,_,_=c
    if not os.path.isfile(os.path.join(root,'skills',skill,'SKILL.md')): print("FAIL  %s: skill %s not found"%(stage,skill)); bad=1
    if gate!='-' and not os.path.isfile(os.path.join(root,'scripts/gates',gate)): print("FAIL  %s: gate %s not found"%(stage,gate)); bad=1
print("map: %d stages, %s"%(n,"BROKEN" if bad else "consistent"))
sys.exit(bad)
PY
