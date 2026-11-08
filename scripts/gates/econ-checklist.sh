#!/usr/bin/env bash
# econ-checklist.sh <manuscript.(md|tex|txt) | dir> [--track applied|theory|auto]
# Mechanical presence checks for an economics manuscript. Each line: STATUS check | evidence.
#   PASS = required element is mentioned; WARN = absent but not required for this paper;
#   FAIL = a method is used whose standard companion element is absent.
# SCOPE: this proves a topic is MENTIONED, never that it is done CORRECTLY. Whether the
# parallel-trends test is valid, the instrument credible, or a proof correct stays with a
# human (reported as HUMAN-REVIEW lines). Exit 1 if any FAIL, else 0.
set -uo pipefail
IN="${1:-}"; TRACK=auto
[ "${2:-}" = "--track" ] && TRACK="${3:-auto}"
[ -n "$IN" ] && [ -e "$IN" ] || { echo "usage: econ-checklist.sh <file|dir> [--track applied|theory|auto]" >&2; exit 2; }

TXT="$(mktemp)"; trap 'rm -f "$TXT"' EXIT
if [ -d "$IN" ]; then
  find "$IN" -type f \( -name '*.md' -o -name '*.tex' -o -name '*.txt' \) -print0 | sort -z | xargs -0 cat > "$TXT" 2>/dev/null
else
  cat "$IN" > "$TXT"
fi
[ -s "$TXT" ] || { echo "econ-checklist: no text found in $IN" >&2; exit 2; }

FAILS=0
has()  { grep -Eiq -- "$1" "$TXT"; }
ev()   { local n l; n=$(grep -Eic -- "$1" "$TXT"); l=$(grep -Ein -- "$1" "$TXT" | head -1 | cut -d: -f1); echo "${n} match(es), first at line ${l:-n/a}"; }
pass() { echo "PASS  $1 | $(ev "$2")"; }
warn() { echo "WARN  $1 | $2"; }
fail() { echo "FAIL  $1 | $2"; FAILS=$((FAILS + 1)); }
need() { # need <check-name> <trigger-regex> <required-regex> <fail-message>
  if has "$2"; then
    if has "$3"; then pass "$1" "$3"; else fail "$1" "$4"; fi
  else warn "$1" "not applicable (method not detected)"; fi
}

DID='difference-in-difference|diff-in-diff|\bDiD\b|双重差分|多期DID|staggered'
RD='regression discontinuity|\bRDD\b|\bRD (design|estimat|plot|analysis)|断点回归'
IV='instrumental variable|\b2SLS\b|\bIV (estimat|regress|approach|strateg|design|specification)|工具变量|Bartik|shift-share'
THEORY='\bProposition\b|\bLemma\b|\bTheorem\b|命题|引理|定理'

[ "$TRACK" = auto ] && { has "$THEORY" && ! has "$DID|$RD|$IV|regression|回归" && TRACK=theory || TRACK=applied; }
echo "track: $TRACK   input: $IN"

if [ "$TRACK" = applied ]; then
  need "DiD: pre-trend / event-study evidence" "$DID" 'parallel trend|pre-trend|pretrend|event[- ]study|平行趋势|事件研究|动态效应' "DiD used but no parallel-trends / event-study mention"
  if has "$DID" && has 'TWFE|two-way fixed|双向固定效应|staggered|交错|多期'; then
    if has 'Callaway|Sant.?Anna|Borusyak|Jaravel|Sun and Abraham|Sun & Abraham|de Chaisemartin|Gardner|did2s|csdid|did_imputation|eventstudyinteract|Goodman-Bacon|Bacon decomposition|异质性稳健|稳健估计量'; then
      pass "DiD: heterogeneity-robust estimator or Bacon diagnostic named" 'Callaway|Sant.?Anna|Borusyak|Sun and Abraham|de Chaisemartin|did2s|csdid|Goodman-Bacon|异质性稳健'
    else fail "DiD: heterogeneity-robust estimator" "TWFE/staggered design with no CS/BJS/SA/dCDH/Bacon mention"; fi
  else warn "DiD: heterogeneity-robust estimator" "not applicable (no TWFE/staggered design detected)"; fi
  need "RD: bandwidth + density/manipulation test" "$RD" 'bandwidth|McCrary|density test|manipulation|带宽|密度检验' "RD used but no bandwidth/density-test mention"
  need "IV: first-stage strength" "$IV" 'first[- ]stage|F[- ]stat|weak instrument|Kleibergen|Stock-Yogo|第一阶段|弱工具变量' "IV used but no first-stage / weak-instrument mention"
  if has "regression|回归|estimat|估计|fixed effect|固定效应"; then
    has 'cluster|聚类|robust standard error|heteroskedastic|稳健标准误' && pass "standard errors: clustering / robustness stated" 'cluster|聚类|robust standard error|稳健标准误' || fail "standard errors" "regression reported but SE treatment (clustering) not stated"
    has 'robustness|placebo|falsification|sensitivity|稳健性|安慰剂|证伪|敏感性' && pass "robustness / placebo section present" 'robustness|placebo|稳健性|安慰剂' || fail "robustness" "no robustness / placebo mention"
    has 'percent|percentage point|standard deviation|elasticity|magnitude|量级|经济意义|个百分点|标准差|弹性' && pass "economic magnitude discussed" 'percentage point|standard deviation|elasticity|magnitude|量级|经济意义|个百分点|标准差|弹性' || warn "economic magnitude" "no magnitude language found; coefficients may be reported without interpretation"
  fi
  echo "HUMAN-REVIEW  validity of identification (are pre-trends actually flat? is the instrument credible?), choice of controls, causal claim strength"
else
  has 'Assumption|assume|假设|设定' && pass "theory: assumptions stated" 'Assumption|assume|假设' || fail "theory: assumptions" "no assumptions stated"
  has "$THEORY" && pass "theory: propositions/lemmas stated" "$THEORY" || fail "theory: propositions" "no Proposition/Lemma/Theorem/命题 found"
  has 'comparative static|equilibrium|best response|first[- ]order condition|比较静态|均衡|一阶条件' && pass "theory: equilibrium / comparative statics" 'comparative static|equilibrium|比较静态|均衡' || warn "theory: equilibrium" "no equilibrium / comparative-statics language"
  has 'testable|empirical prediction|prediction|testable implication|可检验|经验预测|预测' && pass "theory: testable prediction linked" 'testable|empirical prediction|可检验|经验预测' || warn "theory: testable prediction" "no testable implication stated"
  echo "HUMAN-REVIEW  correctness of every proof and derivation (this gate checks none), whether assumptions are plausible, novelty vs. the literature"
fi

echo "SUMMARY  fails=$FAILS  (PASS means mentioned, not correct; see HUMAN-REVIEW lines)"
[ "$FAILS" -eq 0 ]
