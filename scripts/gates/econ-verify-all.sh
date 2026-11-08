#!/usr/bin/env bash
# econ-verify-all.sh - one entry point for the checks that CAN be automated, plus an honest status ledger.
#   run    <manuscript> [bib]                    run the gates, append a receipt
#   status <manuscript>                          4-state status for the CURRENT file content
#   mark   <manuscript> <item> <ai-assessed|human-confirmed> <who>   record a judgement
# items (never auto-passed): identification | proofs | citation-support | formal-write
# States: automated-check-passed / AI-assessed / human-confirmed / not-yet-verified (+ failed).
# Receipt: ${OUTPUT_ROOT:-output}/logs/verify-<stem>.ndjson, append-only. Each event carries the file sha256,
# so editing the manuscript makes earlier results stop counting (they show as stale).
# automated-check-passed = a mention/format check passed, NOT proof the method or citation is correct.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CMD="${1:-}"; MS="${2:-}"
ITEMS="identification proofs citation-support formal-write"
[ -f "$MS" ] || { sed -n '2,10p' "$0" >&2; exit 2; }
if command -v sha256sum >/dev/null 2>&1; then SHA="$(sha256sum "$MS" | cut -d' ' -f1)"; else SHA="$(shasum -a 256 "$MS" | cut -d' ' -f1)"; fi
LOG_DIR="${OUTPUT_ROOT:-output}/logs"; STEM="$(basename "$MS")"; LOG="$LOG_DIR/verify-${STEM%.*}.ndjson"

emit() {
  mkdir -p "$LOG_DIR"
  python3 -c "
import json,sys,datetime
d={'ts':datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')}
for a in sys.argv[2:]:
    k,v=a.split('=',1); d[k]=int(v) if k=='rc' else v
open(sys.argv[1],'a',encoding='utf-8').write(json.dumps(d,ensure_ascii=False)+chr(10))" "$LOG" "$@"
}

FAILED=0
run_check() {
  local name="$1" out rc st ev; shift
  out="$("$@" 2>&1)"; rc=$?
  case $rc in 0) st=automated-check-passed ;; 2) st=not-yet-verified ;; *) st=failed; FAILED=1 ;; esac
  ev="$(printf '%s' "$out" | grep -E '^(FAIL|SUMMARY|ERROR|WARN|INFO)|RED|YELLOW|UNRESOLVED' | head -5 | tr '\n' ' ' | cut -c1-400)"
  emit kind=check file="$MS" sha="$SHA" check="$name" rc=$rc status=$st evidence="$ev"
  printf '  %-22s %-24s %s\n' "$name" "$st" "$ev"
}

status() {
  python3 - "$LOG" "$SHA" $ITEMS <<'PY'
import json,sys,os
log,sha,*items=sys.argv[1:]
ev=[json.loads(l) for l in open(log,encoding="utf-8")] if os.path.exists(log) else []
cur={};stale=0
for e in ev:
    if e.get("sha")!=sha: stale+=1; continue
    cur[e.get("check") or e.get("item")]=e
print("file sha256 %s | stale events ignored: %d" % (sha[:12],stale))
for c in ("econ-checklist","citation-fabrication","citation-existence"):
    e=cur.get(c); print("  [check] %-22s %s" % (c, e["status"] if e else "not-yet-verified"))
for i in items:
    e=cur.get(i); print("  [human] %-22s %s" % (i, (e["status"]+"  by "+e["who"]) if e else "not-yet-verified"))
PY
}

case "$CMD" in
  run)
    BIB="${3:-}"
    echo "verify: $MS (sha ${SHA:0:12})"
    run_check econ-checklist bash "$HERE/econ-checklist.sh" "$MS"
    run_check citation-fabrication bash "$HERE/verify-citations.sh" "$MS"
    if [ -n "$BIB" ] && [ -f "$BIB" ]; then run_check citation-existence bash "$HERE/verify-citation-existence.sh" "$MS" "$BIB"
    else echo "  citation-existence     not-yet-verified         (no .bib given)"; fi
    echo "Human items still open: $ITEMS  -> use mark. Receipt: $LOG"
    exit $FAILED ;;
  status) status ;;
  mark)
    ITEM="${3:-}"; STATE="${4:-}"; WHO="${5:-}"
    case " $ITEMS " in *" $ITEM "*) ;; *) echo "item must be one of: $ITEMS" >&2; exit 2 ;; esac
    case "$STATE" in ai-assessed|human-confirmed) ;; *) echo "state must be ai-assessed|human-confirmed" >&2; exit 2 ;; esac
    [ -n "$WHO" ] || { echo "who is required" >&2; exit 2; }
    emit kind=mark file="$MS" sha="$SHA" item="$ITEM" status="$STATE" who="$WHO"; echo "recorded $ITEM=$STATE by $WHO" ;;
  *) sed -n '2,10p' "$0" >&2; exit 2 ;;
esac
