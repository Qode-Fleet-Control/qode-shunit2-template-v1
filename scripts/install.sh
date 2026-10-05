#!/bin/sh
# Local (non-docker) install: shUnit2 is a single shell file. Fetch the pinned release
# into ./.tools/shunit2 and check its sha256 — the same file the Dockerfile ADDs.
set -eu
SHUNIT2_VERSION="v2.1.8"
SHUNIT2_SHA256="d8f8fb2caff6e3ff77cea8837d1ae5e4fed857fe2948f9859f24f72c43814c28"
cd "$(dirname "$0")/.."
mkdir -p .tools
curl -fsSL "https://raw.githubusercontent.com/kward/shunit2/$SHUNIT2_VERSION/shunit2" -o .tools/shunit2
echo "$SHUNIT2_SHA256  .tools/shunit2" | sha256sum -c -
