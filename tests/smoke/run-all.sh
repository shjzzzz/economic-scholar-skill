#!/usr/bin/env bash
# Run every test-*.sh in this directory; exit 1 if any fails.
D="$(cd "$(dirname "$0")" && pwd)"; RC=0
for t in "$D"/test-*.sh; do echo "== $(basename "$t")"; bash "$t" 2>&1 | tail -n 3; [ "${PIPESTATUS[0]}" -eq 0 ] || RC=1; done
[ $RC -eq 0 ] && echo "ALL PASSED" || echo "FAILURES"; exit $RC
