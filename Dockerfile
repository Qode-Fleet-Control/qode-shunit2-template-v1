# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: the official bash image (alpine; its /bin/sh is busybox ash),
# shUnit2 v2.1.8 added from its release tag with a pinned checksum, a non-root user. The
# default command runs every tests/test_*.sh under both POSIX sh and bash
# (scripts/test.sh) and exits 0 when all pass.

FROM bash:5.2
ARG BUILD_ID=""
ENV BUILD_ID=$BUILD_ID SHUNIT2=/usr/local/bin/shunit2
ADD --checksum=sha256:d8f8fb2caff6e3ff77cea8837d1ae5e4fed857fe2948f9859f24f72c43814c28 \
    https://raw.githubusercontent.com/kward/shunit2/v2.1.8/shunit2 /usr/local/bin/shunit2
RUN chmod 644 /usr/local/bin/shunit2 && adduser -D -u 10001 app
WORKDIR /app
COPY --chown=app:app . .
USER app
CMD ["sh", "scripts/test.sh", "sh", "bash"]
