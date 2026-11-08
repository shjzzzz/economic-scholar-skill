#!/usr/bin/env bash
# test-selfimprove.sh - pins doctor, normalize-eol, seed-check, accept-check, map-check, feedback-triage, regress-samples,
# including mutation tests: a deliberately broken input must turn the gate RED (otherwise the gate proves nothing).
set -uo pipefail
R="$(cd "$(dirname "$0")/../.." && pwd)"; G="$R/scripts/gates"
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "  PASS: $1"; }; no(){ FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
T="$(mktemp -d -t selfimp.XXXXXX)"; trap 'rm -rf "$T"' EXIT

# --- normalize-eol: dry-run changes nothing; --apply strips CR only
mkdir -p "$T/e"; printf 'a\r\nb\r\n' > "$T/e/x.sh"; cp "$T/e/x.sh" "$T/e/keep.sh"
bash "$G/normalize-eol.sh" "$T/e" >/dev/null 2>&1 && no "CRLF not detected" || ok "CRLF detected"
cmp -s "$T/e/x.sh" "$T/e/keep.sh" && ok "dry-run leaves files untouched" || no "dry-run modified a file"
bash "$G/normalize-eol.sh" --apply "$T/e" >/dev/null 2>&1; grep -q $'\r' "$T/e/x.sh" && no "apply left CR" || ok "apply strips CR"
[ "$(tr -d '\r\n' < "$T/e/keep.sh")" = "$(tr -d '\n' < "$T/e/x.sh")" ] && ok "content preserved" || no "content changed"

# --- seed-check
bash "$G/seed-check.sh" "$R/tests/samples/good-seed.R" >/dev/null 2>&1 && ok "seeded script passes" || no "seeded script failed"
bash "$G/seed-check.sh" "$R/tests/samples/bad-seed.R" >/dev/null 2>&1 && no "unseeded script passed" || ok "unseeded script RED"
bash "$G/seed-check.sh" "$R/tests/samples/clock-seed.R" >/dev/null 2>&1 && no "clock seed passed" || ok "clock seed RED"

# --- regress-samples + mutation: weaken a good sample, the gate must notice
bash "$G/regress-samples.sh" >/dev/null 2>&1 && ok "approved samples hold" || no "sample regression on pristine repo"
mkdir -p "$T/s"; cp "$R"/tests/samples/* "$T/s/"; sed -i 's/Callaway and Sant.Anna/an estimator/' "$T/s/good-applied.md"
SAMPLES_DIR="$T/s" bash "$G/regress-samples.sh" >/dev/null 2>&1 && no "mutated good sample still passes" || ok "mutated good sample caught"
# a gate that stops failing on a bad sample is also caught
cp "$R"/tests/samples/* "$T/s/"; printf 'staggered DiD with Callaway Sant Anna event study cluster robustness percentage point\n' > "$T/s/bad-twfe.md"
SAMPLES_DIR="$T/s" bash "$G/regress-samples.sh" >/dev/null 2>&1 && no "bad sample turned good unnoticed" || ok "bad sample drift caught"

# --- map-check / accept-check on the real repo, and on a broken copy
bash "$G/map-check.sh" >/dev/null 2>&1 && ok "feature map consistent" || no "feature map broken"
bash "$G/accept-check.sh" >/dev/null 2>&1 && ok "acceptance refs resolve" || no "acceptance has broken refs"
bash "$G/accept-check.sh" --strict >/dev/null 2>&1 && no "--strict ignored must-gaps" || ok "--strict reports must-gaps"
mkdir -p "$T/r"; cp -r "$R/skills" "$T/r/skills"; mkdir -p "$T/r/scripts/gates"
sed -i 's#scripts/gates/seed-check.sh#scripts/gates/nope.sh#' "$T/r/skills/econ-paper/references/acceptance.tsv"
ECON_ROOT="$T/r" bash "$G/accept-check.sh" >/dev/null 2>&1 && no "broken ref accepted" || ok "broken check ref RED"
sed -i 's#econ-literature#no-such-skill#' "$T/r/skills/econ-paper/references/feature-map.tsv"
ECON_ROOT="$T/r" bash "$G/map-check.sh" >/dev/null 2>&1 && no "missing skill accepted" || ok "map with missing skill RED"

# --- doctor on a synthetic broken tree
mkdir -p "$T/d/skills/foo" "$T/d/scripts/gates"; cp "$G/normalize-eol.sh" "$G/map-check.sh" "$T/d/scripts/gates/"
printf -- '---\r\nname: bar\r\n---\r\nrun scripts/gates/ghost.sh and references/none.md\r\n' > "$T/d/skills/foo/SKILL.md"
out="$(ECON_ROOT="$T/d" bash "$G/doctor.sh" 2>&1)"; rc=$?
[ $rc -ne 0 ] && ok "doctor RED on broken tree" || no "doctor passed a broken tree"
for w in 'CRLF' "dir 'foo' != frontmatter name 'bar'" 'missing file scripts/gates/ghost.sh' 'missing file references/none.md'; do echo "$out" | grep -Fq "$w" && ok "doctor reports: $w" || no "doctor missed: $w"; done
bash "$G/doctor.sh" >/dev/null 2>&1 && ok "doctor GREEN on the real package" || no "doctor RED on the real package"

# --- bib-check
printf '@article{a1,author={A},title={T},year={2020},doi={10.1/x}}\n@article{a1,author={B},title={U},year={2021},doi={10.1/y}}\n@article{b2,author={C},title={V},year={2022}}\n@article{c3,author={D},title={W},year={2999},doi={10.1/z}}\n' > "$T/bad.bib"
out="$(bash "$G/bib-check.sh" "$T/bad.bib" 2>&1)"; rc=$?
[ $rc -eq 1 ] && ok "bib-check RED on bad bib" || no "bib-check passed a bad bib"
for w in 'a1: duplicate' 'b2: no doi or url' 'c3: implausible year'; do echo "$out" | grep -Fq "$w" && ok "bib-check reports: $w" || no "bib-check missed: $w"; done
printf '@article{a1,author={A},title={T},year={2020},doi={10.1/x}}\n' > "$T/good.bib"; bash "$G/bib-check.sh" "$T/good.bib" >/dev/null 2>&1 && ok "bib-check GREEN on clean bib" || no "bib-check false alarm"

# --- feedback-triage
export SCHOLAR_FEEDBACK_FILE="$T/fb.ndjson"
bash "$G/feedback-log.sh" add --skill econ-write --kind rule --what "cite only verified refs" --to prompt >/dev/null
bash "$G/feedback-triage.sh" >/dev/null 2>&1; [ $? -eq 0 ] && ok "single prompt-only rule tolerated" || no "triage too strict"
bash "$G/feedback-log.sh" add --skill econ-write --kind rule --what "cite only verified refs" --to prompt >/dev/null
out="$(bash "$G/feedback-triage.sh" 2>&1)"; echo "$out" | grep -q RECURRING && ok "recurring unenforced rule escalated" || no "recurrence not detected"
bash "$G/feedback-triage.sh" >/dev/null 2>&1; [ $? -eq 1 ] && ok "recurrence exits 1" || no "recurrence exit code"
rm -f "$SCHOLAR_FEEDBACK_FILE"
bash "$G/feedback-log.sh" add --skill econ-causal --kind rule --what "no bare TWFE" --to sample --ref "$R/tests/samples/bad-twfe.md" >/dev/null
out="$(bash "$G/feedback-triage.sh" 2>&1)"; echo "$out" | grep -q ' ENFORCED' && ok "wired sample counts as enforced" || no "wired sample not recognised"
: > "$T/orphan.md"; bash "$G/feedback-log.sh" add --skill econ-causal --kind rule --what "x2" --to sample --ref "$T/orphan.md" >/dev/null
out="$(bash "$G/feedback-triage.sh" 2>&1)"; echo "$out" | grep -q 'SAMPLE-NOT-WIRED' && ok "unwired sample flagged" || no "unwired sample accepted"
echo "passed=$PASS failed=$FAIL"; [ "$FAIL" -eq 0 ]
