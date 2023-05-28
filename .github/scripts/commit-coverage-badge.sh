#!/usr/bin/env bash

set -e

git config --local user.email "github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"
git add coverage.svg
git commit -m "Updated coverage.svg"

