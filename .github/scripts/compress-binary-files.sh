#!/usr/bin/env bash

set -e

tar czvf \
  "${BINARY_FILE}-${PACKAGE_VERSION}-arm64.tar.gz" \
  "${BINARY_FILE}"
