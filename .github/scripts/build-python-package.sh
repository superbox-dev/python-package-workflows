#!/usr/bin/env bash

set -e

pip install --upgrade pip
pip install ".[build]"
python -m build
