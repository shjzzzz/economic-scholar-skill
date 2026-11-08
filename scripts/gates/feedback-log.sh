#!/usr/bin/env bash
# feedback-log.sh - turn user feedback into something enforceable instead of one more prompt line.
#   add   --skill S --kind one-off|rule --what "..." --to check|sample|tool|prompt|none [--ref FILE]
#   list                       all entries
#   audit                      exit 1: a rule with to=none, or check/sample/tool whose --ref file is missing
#                              exit 2: more than 10 prompt-only rules (rule bloat)
# one-off = this task only; rule = should never recur. A rule must land in a check, an approved sample
# or a tool (--ref points at it); prompt is the last resort. Sink: SCHOLAR_FEEDBACK_FILE or output/logs/feedback.ndjson
set -uo pipefail
F="${SCHOLAR_FEEDBACK_FILE:-output/logs/feedback.ndjson}"
CMD="${1:-}"; shift || true
case "$CMD" in
  add)
    SKILL=""; KIND=""; WHAT=""; TO=""; REF=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL="${2:-}"; shift 2 ;;
        --kind) KIND="${2:-}"; shift 2 ;;
        --what) WHAT="${2:-}"; shift 2 ;;
        --to) TO="${2:-}"; shift 2 ;;
        --ref) REF="${2:-}"; shift 2 ;;
        *) echo "unknown arg $1" >&2; exit 2 ;;
      esac
    done
    case "$KIND" in one-off|rule) ;; *) echo "--kind one-off|rule" >&2; exit 2 ;; esac
    case "$TO" in check|sample|tool|prompt|none) ;; *) echo "--to check|sample|tool|prompt|none" >&2; exit 2 ;; esac
    [ -n "$SKILL" ] && [ -n "$WHAT" ] || { echo "--skill and --what are required" >&2; exit 2; }
    case "$TO" in check|sample|tool)
      [ -n "$REF" ] && [ -e "$REF" ] || { echo "--to $TO needs an existing --ref file as evidence" >&2; exit 2; } ;;
    esac
    mkdir -p "$(dirname "$F")"
    python3 -c "
import json,sys,datetime
k=['skill','kind','what','to','ref']
d={'ts':datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')}
d.update(dict(zip(k,sys.argv[2:])))
open(sys.argv[1],'a',encoding='utf-8').write(json.dumps(d,ensure_ascii=False)+chr(10))" "$F" "$SKILL" "$KIND" "$WHAT" "$TO" "$REF"
    echo "logged: $KIND/$TO for $SKILL" ;;
  list) if [ -f "$F" ]; then cat "$F"; else echo "(no feedback yet)"; fi ;;
  audit)
    [ -f "$F" ] || { echo "no feedback file: nothing to audit"; exit 0; }
    python3 - "$F" <<'PY'
import json,sys,os
bad=0;prompt=0
for n,l in enumerate(open(sys.argv[1],encoding="utf-8"),1):
    e=json.loads(l)
    if e["kind"]=="rule" and e["to"]=="none":
        print("RED line %d: rule with no enforcement (%s: %s)" % (n,e["skill"],e["what"][:60])); bad=1
    if e["to"] in ("check","sample","tool") and not os.path.exists(e.get("ref","")):
        print("RED line %d: ref missing (%s)" % (n,e.get("ref"))); bad=1
    if e["kind"]=="rule" and e["to"]=="prompt": prompt+=1
print("prompt-only rules: %d" % prompt)
sys.exit(1 if bad else (2 if prompt>10 else 0))
PY
    exit $? ;;
  *) sed -n '2,9p' "$0" >&2; exit 2 ;;
esac
