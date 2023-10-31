#!/usr/bin/env bash

set -e

pip install --upgrade pip
pip install ".[tests]"

pytest \
  -n auto \
  --cov-report term-missing \
  --cov="${PACKAGE_NAME/-/_}"
