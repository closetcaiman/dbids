#!/bin/bash

set -e

ROOT="$(git rev-parse --show-toplevel)"

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$ROOT:/workdir" \
    -w /workdir \
    davidanson/markdownlint-cli2 \
    "$@"
