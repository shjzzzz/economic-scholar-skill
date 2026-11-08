#!/usr/bin/env bash
# bib-check.sh <refs.bib>  - deterministic hygiene for a bibliography (not proof that a paper exists).
#   FAIL: duplicate cite key | entry with neither doi nor url | year outside 1800..(current year+1) | missing author/title/year
#   WARN: working-paper/unpublished entry (flag so the text never presents it as published)
# A real DOI still has to be resolved by verify-citation-existence.sh or by a lookup tool. Exit 1 on any FAIL.
set -uo pipefail
B="${1:-}"; [ -f "$B" ] || { sed -n '2,6p' "$0" >&2; exit 2; }
python3 - "$B" <<'PY'
import re,sys,datetime
t=open(sys.argv[1],encoding='utf-8').read()
ents=re.findall(r'@(\w+)\s*\{\s*([^,\s]+)\s*,(.*?)(?=\n@|\Z)',t,re.S)
cur=datetime.date.today().year+1; keys={}; bad=0
for typ,key,body in ents:
    f={m.group(1).lower():m.group(2).strip(' {}"') for m in re.finditer(r'(\w+)\s*=\s*(\{(?:[^{}]|\{[^{}]*\})*\}|"[^"]*"|\w+)',body)}
    if key in keys: print('FAIL  %s: duplicate cite key'%key); bad=1
    keys[key]=1
    for r in ('author','title','year'):
        if r not in f and typ.lower()!='misc': print('FAIL  %s: missing %s'%(key,r)); bad=1
    if 'doi' not in f and 'url' not in f: print('FAIL  %s: no doi or url (cannot be checked)'%key); bad=1
    y=f.get('year','')
    if y.isdigit() and not 1800<=int(y)<=cur: print('FAIL  %s: implausible year %s'%(key,y)); bad=1
    if typ.lower() in('unpublished','techreport') or 'working paper' in body.lower(): print('WARN  %s: working/unpublished - never cite as published'%key)
print('bib: %d entries, %s'%(len(ents),'ISSUES' if bad else 'clean'))
sys.exit(bad)
PY
