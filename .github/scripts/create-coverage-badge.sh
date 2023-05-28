#!/usr/bin/env bash

set -e

pip install ".[tests]"
coverage-badge -f -o coverage.svg
