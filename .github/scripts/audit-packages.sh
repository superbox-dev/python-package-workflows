#!/usr/bin/env bash

set -e

pip install ".[build,lint,format,audit,tests]"
pip-audit
