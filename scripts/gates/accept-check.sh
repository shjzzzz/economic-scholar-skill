#!/usr/bin/env bash
# accept-check.sh [--strict]  - which acceptance criteria are backed by a real check, which only by a human, which by nothing.
# Source: skills/econ-paper/references/acceptance.tsv  (id stage level criterion enforcement check source confirmed)
#   enforcement: auto | auto-weak (mention-level, can false-pass) | human | none
# Exit 1: a declared check file does not exist (broken reference). With --strict also: a `must` criterion with none.
# `confirmed=no` rows are proposals drawn from existing project docs, awaiting the user's confirmation.
set -uo pipefail
ROOT="${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
python3 - "$ROOT" "${1:-}" <<'PY'
import sys,os,collections
root,strict=sys.argv[1:]
f=os.path.join(root,'skills/econ-paper/references/acceptance.tsv')
rows=[l.rstrip('\n').split('\t') for l in open(f,encoding='utf-8')][1:]
ITEMS={'identification','proofs','citation-support','formal-write'}
broken=gaps=0; cnt=collections.Counter()
for id_,stage,lvl,crit,enf,chk,src,conf in rows:
    cnt[(lvl,enf)]+=1; tag=enf.upper()
    if enf in('auto','auto-weak') and not os.path.isfile(os.path.join(root,chk)):
        tag='BROKEN-REF'; broken=1
    if enf=='human' and chk not in ITEMS|{'-'}: tag='BROKEN-REF'; broken=1
    if enf=='none' and lvl=='must': tag='GAP'; gaps+=1
    print('%-4s %-8s %-14s %-12s %s'%(id_,lvl,stage,tag,crit))
print()
for (lvl,enf),n in sorted(cnt.items()): print('  %-6s %-9s %d'%(lvl,enf,n))
unc=sum(1 for r in rows if r[7]!='yes')
print('criteria: %d | unconfirmed by user: %d | must-gaps (no check at all): %d | broken refs: %s'%(len(rows),unc,gaps,'YES' if broken else 'no'))
sys.exit(1 if broken or (strict=='--strict' and gaps) else 0)
PY
