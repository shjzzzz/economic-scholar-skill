#!/usr/bin/env bash
# init-project.sh <slug> [applied|theory|theory+applied] [en|zh]  - create paper/<slug>/ with STATE.md. Never overwrites.
set -uo pipefail
SLUG="${1:-}"; TRACK="${2:-applied}"; LANG_="${3:-en}"
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "usage: init-project.sh <slug: a-z 0-9 -> [applied|theory|theory+applied] [en|zh]" >&2; exit 2; }
case "$TRACK" in applied|theory|theory+applied) ;; *) echo "track must be applied|theory|theory+applied" >&2; exit 2 ;; esac
D="paper/$SLUG"; [ -e "$D" ] && { echo "exists: $D (not touched)" >&2; exit 1; }
mkdir -p "$D"/{lit,data/raw,data/processed,analysis,drafts,output/logs}
cat > "$D/STATE.md" <<S
# $SLUG
track: $TRACK | language: $LANG_ | created: $(date +%F)

## Stages (tick only when the gate output is saved under output/logs)
- [ ] 1 literature   gate: bib-check + verify (citation existence)   human: judge the gap
- [ ] 2 question     gate: -                                         human: choose the RQ; proofs = needs-human-review
- [ ] 3 identification gate: econ-checklist                          human: validity of identification
- [ ] 4 analysis     gate: safety-scan, seed-check                   human: read the results
- [ ] 5 writing      gate: version-check before every save           human: argument and voice
- [ ] 6 verify       gate: econ.sh verify; status                    human: identification, proofs, citation-support
- [ ] 7 submit       gate: journal facts from official page          human: final sign-off

## Decisions and open human checks
S
echo "created $D"
