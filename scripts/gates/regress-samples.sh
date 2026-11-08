#!/usr/bin/env bash
# regress-samples.sh  - approved good/bad samples must keep producing the expected gate verdict.
# tests/samples/expected.tsv: file  tool(checklist|seed)  expect_rc  marker('-' = none)
# A good sample must PASS (rc 0); a bad sample must FAIL with the named marker. If a gate edit flips a verdict,
# this goes RED. This is the home for feedback logged with --to sample. Exit 1 on any mismatch.
set -uo pipefail
ROOT="${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"; S="${SAMPLES_DIR:-$ROOT/tests/samples}"; G="$ROOT/scripts/gates"
RC=0; N=0
while IFS=$'\t' read -r file tool want marker; do
  [ "$file" = file ] && continue; [ -n "$file" ] || continue
  case "$tool" in checklist) cmd=(bash "$G/econ-checklist.sh" "$S/$file") ;; seed) cmd=(bash "$G/seed-check.sh" "$S/$file") ;; *) echo "FAIL  $file: unknown tool $tool"; RC=1; continue ;; esac
  out="$("${cmd[@]}" 2>&1)"; got=$?; N=$((N+1))
  if [ "$got" != "$want" ]; then echo "FAIL  $file: rc $got, want $want"; RC=1
  elif [ "$marker" != "-" ] && ! printf '%s' "$out" | grep -Fq -- "$marker"; then echo "FAIL  $file: marker not found: $marker"; RC=1
  else echo "PASS  $file ($tool rc=$got)"; fi
done < "$S/expected.tsv"
echo "samples: $N checked, $([ $RC -eq 0 ] && echo all as expected || echo REGRESSION)"; exit $RC
