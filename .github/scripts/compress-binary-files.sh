#!/usr/bin/env bash

set -e

tar czvf \
  "${{ matrix.binary-file }}-${{ inputs.package-version }}-arm64.tar.gz" \
  "${{ matrix.binary-file }}"
