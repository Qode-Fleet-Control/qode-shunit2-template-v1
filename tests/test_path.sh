#!/bin/sh
# shUnit2 tests for lib/path.sh — run: sh tests/test_path.sh  (or `docker compose run --rm app`)
# shUnit2 finds every function named test* and runs it; setUp/tearDown wrap each one.

oneTimeSetUp() {
  # shellcheck source=../lib/path.sh
  . "$(dirname "$0")/../lib/path.sh"
}

setUp() {
  workdir=$(mktemp -d)
}

tearDown() {
  rm -rf "$workdir"
}

test_join_collapses_slashes() {
  assertEquals "/usr/local/bin" "$(path_join /usr/ /local bin)"
}

test_join_skips_empty_parts() {
  assertEquals "a/b" "$(path_join a '' b)"
}

test_ext_takes_the_last_extension() {
  assertEquals "gz" "$(path_ext archive.tar.gz)"
  assertEquals "csv" "$(path_ext /tmp/dir.d/report.csv)"
}

test_ext_of_dotfile_or_plain_name_is_empty() {
  assertEquals "" "$(path_ext .bashrc)"
  assertEquals "" "$(path_ext Makefile)"
}

test_stem_drops_dir_and_extension() {
  assertEquals "report" "$(path_stem /tmp/report.csv)"
  assertEquals "archive.tar" "$(path_stem archive.tar.gz)"
}

test_is_abs() {
  assertTrue "/etc is absolute" "path_is_abs /etc"
  assertFalse "etc is relative" "path_is_abs etc"
}

test_join_builds_a_usable_path() {
  touch "$(path_join "$workdir" file.txt)"
  assertTrue "file created through path_join" "[ -f '$workdir/file.txt' ]"
}

# Load shUnit2 last: SHUNIT2 (or ./.tools/shunit2, or shunit2 on PATH).
here=$(cd "$(dirname "$0")/.." && pwd)
SHUNIT2=${SHUNIT2:-$here/.tools/shunit2}
[ -f "$SHUNIT2" ] || SHUNIT2=$(command -v shunit2)
# shellcheck disable=SC1090
. "$SHUNIT2"
