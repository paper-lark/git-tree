#!/usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)"
swift-format lint --configuration "${ROOT}/.swift-format" -r "${ROOT}/git-tree"
