#!/usr/bin/env bash

set -e

pip install ".[tests]"

package_name="${{ inputs.package-name }}"

pytest \
  -n auto \
  --cov-report term-missing \
  --cov="${package_name/-/_}"
