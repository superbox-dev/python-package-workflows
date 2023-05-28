#!/usr/bin/env bash

set -e

docker load --input nuitka-builder.tar

docker run --rm --privileged \
  -e BUILDER_UID="$(id -u)" -e BUILDER_GID="$(id -g)" \
  -v "${GITHUB_WORKSPACE}:/build" \
  nuitka-builder /build/scripts/entry.sh "${{ matrix.binary-file }}"

chmod +x "${{ matrix.binary-file }}.dist/${{ matrix.binary-file }}"

