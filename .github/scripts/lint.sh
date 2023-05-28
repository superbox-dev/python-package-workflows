#!/usr/bin/env bash

set -e

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

pylint --version
# shellcheck disable=SC2046
pylint $(git ls-files '*.py')

yamllint --version
# shellcheck disable=SC2046
yamllint $(git ls-files '*.yaml') $(git ls-files '*.yml')
