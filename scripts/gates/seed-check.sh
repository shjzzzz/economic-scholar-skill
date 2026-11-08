#!/usr/bin/env bash
# seed-check.sh <script|dir>...  - random steps (bootstrap/simulation/shuffle/split) need a fixed seed.
#   PASS = randomness found and a literal seed is set | FAIL = randomness, no seed (or a clock seed)
#   N/A  = no randomness detected. Exit 1 on any FAIL.
# SCOPE: detects that a seed is SET, not that it precedes every random call. Mention-level check.
set -uo pipefail
[ $# -ge 1 ] || { sed -n '2,5p' "$0" >&2; exit 2; }
RC=0
RND='rnorm|runif|rbinom|rpois|rbeta|\bsample\(|\breplicate\(|\bboot\(|bsample|runiform|rnormal|simulate|np\.random\.|numpy\.random|default_rng|\brandom\.(random|choice|shuffle|sample|randint|uniform|gauss)|train_test_split|bootstrap|RandomForest|shuffle=True|\brand\(|\brandn\('
SEED='set\.seed\(\s*[0-9]|set seed [0-9]|np\.random\.seed\(\s*[0-9]|random\.seed\(\s*[0-9]|default_rng\(\s*[0-9]|RandomState\(\s*[0-9]|random_state=\s*[0-9]|manual_seed\(\s*[0-9]|seed!\(\s*[0-9]|Random\.seed!\(\s*[0-9]|rng\(\s*[0-9]|\bseed\s*=\s*[0-9]'
CLOCK='set\.seed\(\s*(Sys\.|as\.numeric\(Sys)|seed\(\s*(time|int\(time)'
while IFS= read -r -d '' f; do
  if ! grep -Eq -- "$RND" "$f"; then echo "N/A   $f | no randomness detected"; continue; fi
  if grep -Eq -- "$CLOCK" "$f"; then echo "FAIL  $f | clock-based seed is not reproducible"; RC=1
  elif grep -Eq -- "$SEED" "$f"; then echo "PASS  $f | seed set"
  else echo "FAIL  $f | random step without a fixed seed"; RC=1; fi
done < <(for a in "$@"; do
  if [ -d "$a" ]; then find "$a" -type f \( -name '*.R' -o -name '*.r' -o -name '*.py' -o -name '*.do' -o -name '*.jl' \) -print0
  elif [ -f "$a" ]; then printf '%s\0' "$a"; fi; done)
exit $RC
