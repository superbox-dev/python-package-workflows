#!/usr/bin/env bash

set -e

pip install --upgrade pip
pip install ".[tests]"
coverage-badge -f -o coverage.svg
