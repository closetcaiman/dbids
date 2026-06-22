#!/bin/bash

set -e

MSG_FILE="$1"

if [ -z "$MSG_FILE" ]; then
    echo "Usage: check-commit-msg.sh <commit-msg-file>"
    exit 1
fi

MSG=$(head -1 "$MSG_FILE")

# Allow merge commits and fixup!/squash! commits
if echo "$MSG" | grep -qE '^(Merge|Revert|fixup!|squash!)'; then
    exit 0
fi

PATTERN='^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert)(\(.+\))?: .+'

if ! echo "$MSG" | grep -qE "$PATTERN"; then
    echo ""
    echo "  Commit message does not follow Conventional Commits format."
    echo ""
    echo "  Expected:  <type>(optional scope): <description>"
    echo "  Got:       $MSG"
    echo ""
    echo "  Valid types: feat fix docs style refactor test chore ci build perf revert"
    echo "  Examples:"
    echo "    feat(lab3): add DTA index recommendations"
    echo "    fix(lab11): raise Neo4j password to 8 characters"
    echo "    docs: add per-lab READMEs"
    echo "    chore: restructure labs into template/ and solution/"
    echo ""
    exit 1
fi
