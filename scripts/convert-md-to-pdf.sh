#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: ./convert.sh path/to/file.md [landscape]"
    exit 1
fi

INPUT_PATH=$(realpath "$1")
INPUT_DIR=$(dirname "$INPUT_PATH")
INPUT_FILENAME=$(basename "$INPUT_PATH")
OUTPUT_FILENAME="${INPUT_FILENAME%.md}.pdf"

# Default geometry settings
GEOMETRY_VARS="-V geometry:margin=1in"

# Check if the second argument is "landscape"
if [ "$2" == "landscape" ]; then
    echo "Orientation: Landscape"
    GEOMETRY_VARS="$GEOMETRY_VARS -V geometry:landscape"
else
    echo "Orientation: Portrait"
fi

if [ ! -f "$INPUT_PATH" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

echo "Converting $INPUT_FILENAME to PDF via Pandoc..."

docker run --rm \
    -v "$INPUT_DIR:/data" \
    -u "$(id -u):$(id -g)" \
    pandoc/latex \
    "$INPUT_FILENAME" \
    -o "$OUTPUT_FILENAME" \
    $GEOMETRY_VARS \
    --pdf-engine=xelatex

echo "Success: $OUTPUT_FILENAME created."