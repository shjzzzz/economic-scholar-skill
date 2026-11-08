#!/usr/bin/env bash
# feedback-triage.sh  - next-round entry: turn the feedback log into a to-do list of mechanical fixes.
# Reads SCHOLAR_FEEDBACK_FILE (default output/logs/feedback.ndjson), written by feedback-log.sh.
# Per entry: ENFORCED | SAMPLE-NOT-WIRED | PROMPT-ONLY | UNENFORCED | ONE-OFF, plus
#   RECURRING (same skill+text logged >=2x and still not enforced -> escalate) and BLOAT (>3 prompt-only rules per skill).
# Exit 1: UNENFORCED, SAMPLE-NOT-WIRED or RECURRING-not-enforced. Exit 2: only BLOAT. Else 0.
set -uo pipefail
ROOT="${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
F="${SCHOLAR_FEEDBACK_FILE:-output/logs/feedback.ndjson}"
[ -f "$F" ] || { echo "no feedback yet: nothing to triage"; exit 0; }
python3 - "$F" "$ROOT" <<'PY'
import json,sys,os,collections
F,root=sys.argv[1:]
E=[json.loads(l) for l in open(F,encoding='utf-8') if l.strip()]
wired=set()
ex=os.path.join(root,'tests/samples/expected.tsv')
if os.path.isfile(ex):
    for l in list(open(ex,encoding='utf-8'))[1:]: wired.add(os.path.realpath(os.path.join(root,'tests/samples',l.split('\t')[0])))
key=lambda e:(e['skill'],' '.join(e['what'].lower().split()))
seen=collections.Counter(key(e) for e in E); prompt=collections.Counter()
bad=bloat=0
for n,e in enumerate(E,1):
    if e['kind']=='one-off': st='ONE-OFF'
    elif e['to']=='none': st='UNENFORCED'
    elif e['to']=='prompt': st='PROMPT-ONLY'; prompt[e['skill']]+=1
    elif not os.path.exists(e.get('ref','')): st='UNENFORCED'
    elif e['to']=='sample' and os.path.realpath(e['ref']) not in wired: st='SAMPLE-NOT-WIRED'
    else: st='ENFORCED'
    rec=seen[key(e)]>=2 and st not in('ENFORCED','ONE-OFF')
    if st in('UNENFORCED','SAMPLE-NOT-WIRED') or rec: bad=1
    hint={'UNENFORCED':'add a check/sample/tool and log it with --ref','SAMPLE-NOT-WIRED':'list the file in tests/samples/expected.tsv',
          'PROMPT-ONLY':'last resort: try a sample or check first','ONE-OFF':'no rule needed','ENFORCED':'done'}[st]
    print('%2d %-16s %-18s %s%s'%(n,st,e['skill'],e['what'][:60],'  [RECURRING x%d -> escalate: make it a check]'%seen[key(e)] if rec else ''))
    print('   next: '+hint)
for s,c in prompt.items():
    if c>3: print('BLOAT %s has %d prompt-only rules (budget 3): convert some to checks/samples'%(s,c)); bloat=1
sys.exit(1 if bad else (2 if bloat else 0))
PY
