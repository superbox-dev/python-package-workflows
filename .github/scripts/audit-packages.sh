#!/usr/bin/env bash

set -e

pip install ".[lint,format,audit,tests]"
pip-audit
