#!/usr/bin/env bash
# econ.sh - one entry point over the suite's gates. Thin dispatcher; every command runs an existing script.
#   doctor                         is the suite itself runnable here? (CRLF, symlinks, name drift)
#   map [--check]                  stage -> skill -> input -> output -> gate -> human gate
#   accept [--strict]              acceptance criteria: auto / weak / human / none
#   verify <ms> [bib]              run automated gates on a manuscript, append a receipt
#   status <ms>                    4-state status for the CURRENT file content
#   mark <ms> <item> <ai-assessed|human-confirmed> <who>
#   seed <script|dir>              fixed-seed check for analysis scripts
#   regress                        approved good/bad samples still give the expected verdicts
#   feedback add|list|audit|triage record user feedback and turn it into a check/sample/tool
#   init <slug> [track] [en|zh]    create paper/<slug>/ with STATE.md
#   bib <refs.bib>                 bibliography hygiene (dup keys, missing doi/url, implausible year)
#   test                           package tests
set -uo pipefail
R="$(cd "$(dirname "$0")/.." && pwd)"; G="$R/scripts/gates"; export ECON_ROOT="$R"
c="${1:-}"; shift || true
case "$c" in
  doctor)   exec bash "$G/doctor.sh" "$@" ;;
  map)      if [ "${1:-}" = "--check" ]; then exec bash "$G/map-check.sh"; else exec bash "$G/map-check.sh" --print; fi ;;
  accept)   exec bash "$G/accept-check.sh" "$@" ;;
  verify)   exec bash "$G/econ-verify-all.sh" run "$@" ;;
  status)   exec bash "$G/econ-verify-all.sh" status "$@" ;;
  mark)     exec bash "$G/econ-verify-all.sh" mark "$@" ;;
  seed)     exec bash "$G/seed-check.sh" "$@" ;;
  regress)  exec bash "$G/regress-samples.sh" "$@" ;;
  feedback) sub="${1:-}"; shift || true
            case "$sub" in add|list|audit) exec bash "$G/feedback-log.sh" "$sub" "$@" ;; triage) exec bash "$G/feedback-triage.sh" ;;
              *) echo "feedback add|list|audit|triage" >&2; exit 2 ;; esac ;;
  init)     exec bash "$G/init-project.sh" "$@" ;;
  bib)      exec bash "$G/bib-check.sh" "$@" ;;
  test)     exec bash "$R/tests/smoke/run-all.sh" ;;
  *)        sed -n '2,14p' "$0" >&2; exit 2 ;;
esac
