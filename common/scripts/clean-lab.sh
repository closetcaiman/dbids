#!/bin/bash

set -e

ROOT="$(git rev-parse --show-toplevel)"
LAB_DIR="$ROOT/labs/$1"

docker build -q -t lab_cleaner "$ROOT/common/dockerfiles/lab-cleaner" > /dev/null
docker run --rm -u root -v "$LAB_DIR:/lab" lab_cleaner
