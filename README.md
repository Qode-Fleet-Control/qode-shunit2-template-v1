# shUnit2 template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
shUnit2 starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A small POSIX sh library and its [shUnit2](https://github.com/kward/shunit2) xUnit tests:

| path | what |
|---|---|
| `lib/path.sh` | the library: `path_join`, `path_ext`, `path_stem`, `path_is_abs` |
| `tests/test_path.sh` | its tests — `test*` functions, `oneTimeSetUp`/`setUp`/`tearDown`, `assertEquals`/`assertTrue`/`assertFalse`, shUnit2 sourced last |
| `scripts/test.sh` | runs every `tests/test_*.sh` under each shell given (`sh`, `bash` …) |
| `scripts/install.sh` | local download of shUnit2 into `./.tools/shunit2` (sha256-checked) |

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app          # all tests under sh and bash; exit 0 = pass

**Without docker** (needs a POSIX sh, curl, sha256sum):

    sh scripts/install.sh                # = fleet.conf INSTALL_CMD
    sh scripts/test.sh sh bash           # or a single file: sh tests/test_path.sh

## Origin

    hand-written (shUnit2 ships no project generator) — the test-file shape from the
    shUnit2 README: test* functions, then `. shunit2` as the last line

shUnit2 v2.1.8 (`https://raw.githubusercontent.com/kward/shunit2/v2.1.8/shunit2`, sha256
`d8f8fb2caff6e3ff77cea8837d1ae5e4fed857fe2948f9859f24f72c43814c28`). Runtime image:
the official `bash:5.2` (alpine: `/bin/sh` is busybox ash, plus bash).

## Deviations from stock output, and why

- The test file finds shUnit2 through `$SHUNIT2` (set in the image), then
  `./.tools/shunit2`, then `shunit2` on PATH, instead of a hard-coded path — so the
  same file runs in docker and locally.
- `scripts/test.sh` runs the suite under more than one shell, since portability is
  usually the point of testing shell code.
## Verified

**The docker image has NOT been built or run yet**: on 2026-10-05 the shared build host's docker disk was full (0-2 GB free for over 8 hours), so `docker compose build` was never attempted. Run `docker compose build && docker compose run --rm app` once before trusting it.

Without docker (2026-10-05): `sh scripts/install.sh` fetched shUnit2 v2.1.8 (checksum OK),
and `sh scripts/test.sh sh bash` ran 7 tests, all OK, under both shells.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
