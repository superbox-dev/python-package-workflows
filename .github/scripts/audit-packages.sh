#!/usr/bin/env bash

set -e

pip install --upgrade pip
pip install -U ".[build,lint,format,audit,tests]"
pip-audit
