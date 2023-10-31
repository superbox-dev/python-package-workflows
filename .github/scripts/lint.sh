#!/usr/bin/env bash

set -e

pip install --upgrade pip
pip install ".[lint,format,tests]"

black --version
# shellcheck disable=SC2046
black --diff --check $(git ls-files '*.py')

mypy --version
# shellcheck disable=SC2046
mypy $(git ls-files '*.py')

ruff --version
# shellcheck disable=SC2046
ruff $(git ls-files '*.py')

yamllint --version
# shellcheck disable=SC2046
yamllint $(git ls-files '*.yaml') $(git ls-files '*.yml')

sudo -E apt-get -qq update
sudo -E apt-get -qq upgrade
sudo apt install shellcheck

find . -type f -name "*.sh" -exec shellcheck --format=gcc {} \;
