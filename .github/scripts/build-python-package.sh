#!/usr/bin/env bash

set -e

pip install ".[build]"
python -m build
