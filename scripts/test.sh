#!/bin/sh
# Run every tests/test_*.sh under each shell given (default: sh). Exits non-zero if any
# file fails under any shell.
#   sh scripts/test.sh            # POSIX sh
#   sh scripts/test.sh sh bash    # both
set -u
cd "$(dirname "$0")/.."
[ $# -eq 0 ] && set -- sh
rc=0
for shell in "$@"; do
  for t in tests/test_*.sh; do
    echo "== $shell $t"
    "$shell" "$t" || rc=1
  done
done
[ $rc -eq 0 ] && echo PASS || echo FAILED
exit $rc
