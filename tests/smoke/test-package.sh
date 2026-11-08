#!/usr/bin/env bash
# test-package.sh - package structure, project init, and the four-state ledger (verify/status/mark, stale on edit).
set -uo pipefail
R="$(cd "$(dirname "$0")/../.." && pwd)"; G="$R/scripts/gates"; E="$R/scripts/econ.sh"
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "  PASS: $1"; }; no(){ FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
T="$(mktemp -d -t pkg.XXXXXX)"; trap 'rm -rf "$T"' EXIT

# structure: 8 skills, frontmatter, lean
n=0; for d in "$R"/skills/*/; do n=$((n+1)); k=$(basename "$d"); f="$d/SKILL.md"
  head -1 "$f" | grep -q '^---$' && grep -q "^name: $k$" "$f" && grep -q '^description: .\{40,\}' "$f" || no "$k: frontmatter"
  [ "$(wc -l < "$f")" -le 120 ] || no "$k: SKILL.md over 120 lines (keep routing lean; move detail to references/)"
done
[ "$n" -eq 8 ] && ok "8 skills present" || no "expected 8 skills, found $n"
[ -f "$R/.claude-plugin/plugin.json" ] && python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$R/.claude-plugin/plugin.json" && ok "plugin.json is valid JSON" || no "plugin.json invalid"
# pipeline coverage: every stage in the router names an existing skill
for k in econ-literature econ-question econ-identification econ-analysis econ-writing econ-verify econ-submit; do
  grep -q "\`$k\`" "$R/skills/econ-paper/SKILL.md" && [ -d "$R/skills/$k" ] || no "router does not route to $k"; done; ok "router covers all stage skills"

# init-project
cd "$T"; bash "$E" init demo-paper applied zh >/dev/null 2>&1 && [ -f paper/demo-paper/STATE.md ] && [ -d paper/demo-paper/lit ] && ok "init creates project" || no "init failed"
bash "$E" init demo-paper >/dev/null 2>&1 && no "init overwrote an existing project" || ok "init refuses to overwrite"
bash "$E" init 'Bad Slug' >/dev/null 2>&1 && no "init accepted a bad slug" || ok "init rejects bad slug"

# four-state ledger
export OUTPUT_ROOT="$T/out"
printf 'We use OLS regression. Standard errors are clustered at the firm level. Robustness checks follow.\n' > "$T/m.md"
bash "$E" verify "$T/m.md" >/dev/null 2>&1
bash "$E" status "$T/m.md" | grep -q 'econ-checklist .*automated-check-passed' && ok "verify recorded for current file" || no "verify not recorded"
bash "$E" status "$T/m.md" | grep -q 'identification .*not-yet-verified' && ok "human item not auto-passed" || no "human item auto-passed"
bash "$E" mark "$T/m.md" proofs human-confirmed >/dev/null 2>&1 && no "mark without who accepted" || ok "mark requires who"
bash "$E" mark "$T/m.md" proofs human-confirmed me >/dev/null 2>&1
bash "$E" status "$T/m.md" | grep -q 'proofs .*human-confirmed' && ok "human mark recorded" || no "human mark lost"
echo "edit" >> "$T/m.md"
bash "$E" status "$T/m.md" | grep -q 'proofs .*not-yet-verified' && ok "edit invalidates earlier marks" || no "stale mark still counted"
# a manuscript that should FAIL the checklist must make verify exit non-zero
printf 'Staggered difference-in-differences with two-way fixed effects, regression reported.\n' > "$T/bad.md"
bash "$E" verify "$T/bad.md" >/dev/null 2>&1 && no "bad manuscript passed verify" || ok "bad manuscript fails verify"
# feedback rules cannot be left unenforced
export SCHOLAR_FEEDBACK_FILE="$T/fb.ndjson"
bash "$E" feedback add --skill econ-writing --kind rule --what x --to none >/dev/null 2>&1
bash "$E" feedback audit >/dev/null 2>&1; [ $? -eq 1 ] && ok "rule with no enforcement is RED" || no "unenforced rule not flagged"
bash "$E" feedback add --skill econ-writing --kind rule --what y --to check --ref /nonexistent >/dev/null 2>&1 && no "missing ref accepted" || ok "missing ref rejected"
echo "passed=$PASS failed=$FAIL"; [ "$FAIL" -eq 0 ]
