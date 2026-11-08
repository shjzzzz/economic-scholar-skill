#!/usr/bin/env bash
# doctor.sh - is the package itself runnable and internally consistent?
#   tools | LF line endings | skill dir name == frontmatter name | every scripts/ and references/ path named in a
#   SKILL.md exists | feature map ok. Prints OK/FAIL with the exact fix. Exit 1 on any FAIL. Never modifies anything.
set -uo pipefail
ROOT="${ECON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"; RC=0
ok(){ echo "OK    $1"; }; bad(){ echo "FAIL  $1"; echo "      fix: $2"; RC=1; }
for t in python3 jq; do command -v $t >/dev/null 2>&1 && ok "tool $t" || bad "tool $t missing (data guard fails closed)" "install $t"; done
n=$(bash "$ROOT/scripts/gates/normalize-eol.sh" "$ROOT" 2>/dev/null | grep -c '^CRLF')
[ "$n" -eq 0 ] && ok "line endings LF" || bad "$n file(s) have CRLF; bash aborts with 'set: pipefail: invalid option name'" "bash scripts/gates/normalize-eol.sh --apply"
for d in "$ROOT"/skills/*/; do
  f="$d/SKILL.md"; [ -f "$f" ] || continue
  dn=$(basename "$d"); nm=$(tr -d '\r' < "$f" | awk 'NR>1&&/^---$/{exit} /^name:/{sub(/^name:[ ]*/,"");gsub(/["'"'"']/,"");print;exit}')
  [ "$dn" = "$nm" ] || bad "skill dir '$dn' != frontmatter name '$nm'" "rename the directory or the name field"
  for p in $(grep -oE '(scripts/[A-Za-z0-9_./-]+\.(sh|py)|([a-z]+-[a-z]+/)?references/[A-Za-z0-9_.-]+\.(md|tsv|R))' "$f" | sort -u); do
    case "$p" in references/*) t="$d/$p" ;; scripts/*) t="$ROOT/$p" ;; *) t="$ROOT/skills/$p" ;; esac
    [ -f "$t" ] || bad "$dn/SKILL.md names missing file $p" "create it or fix the path"
  done
done
[ "$RC" -eq 0 ] && ok "skills: names match, referenced files exist"
ECON_ROOT="$ROOT" bash "$ROOT/scripts/gates/map-check.sh" >/dev/null 2>&1 && ok "feature map consistent" || bad "feature map references a missing skill/gate" "bash scripts/econ.sh map --check"
exit $RC
