#!/usr/bin/env bash
# task-manifest.sh — Verify task manifest exists and has content
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# The Mayéutic Challenge: agents must analyze before executing.
# This script verifies that a TASK_MANIFEST exists and contains
# minimum required fields before any non-trivial task can proceed.
#
# Usage:
#   bash scripts/task-manifest.sh check    # Verify manifest exists and has content
#   bash scripts/task-manifest.sh create   # Create empty manifest template
#   bash scripts/task-manifest.sh show     # Show current manifest content
#
# Exit codes:
#   0 — Manifest exists and has required content
#   1 — Manifest missing or incomplete
#   2 — Usage error

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
MANIFEST="${REPO_ROOT}/.git/TASK_MANIFEST"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; }

ACTION="${1:-check}"

case "$ACTION" in
  check)
    if [ ! -f "$MANIFEST" ]; then
      fail "No TASK_MANIFEST found at .git/TASK_MANIFEST"
      echo ""
      echo "  The Mayéutic Challenge requires a task manifest before execution."
      echo "  Run: bash scripts/task-manifest.sh create"
      echo ""
      exit 1
    fi

    # Check manifest has minimum content (not empty or too short)
    CONTENT=$(cat "$MANIFEST" 2>/dev/null || echo "")
    LINES=$(echo "$CONTENT" | wc -l)
    CHARS=$(echo "$CONTENT" | wc -c)

    if [ "$CHARS" -lt 50 ]; then
      fail "TASK_MANIFEST is too short (${CHARS} chars, minimum 50)"
      echo ""
      echo "  The manifest must contain:"
      echo "  - Files affected"
      echo "  - Edge cases found"
      echo "  - Alternatives considered"
      echo "  - Risks identified"
      echo ""
      exit 1
    fi

    # Check for required fields
    MISSING=0
    for field in "Files affected" "Edge cases" "Alternatives" "Risks"; do
      if ! echo "$CONTENT" | grep -qi "$field"; then
        fail "Missing required field: $field"
        MISSING=1
      fi
    done

    if [ "$MISSING" -eq 1 ]; then
      echo ""
      echo "  Manifest must contain these fields:"
      echo "  - Files affected"
      echo "  - Edge cases found"
      echo "  - Alternatives considered"
      echo "  - Risks identified"
      echo ""
      exit 1
    fi

    ok "TASK_MANIFEST exists and has required content"
    exit 0
    ;;

  create)
    cat > "$MANIFEST" << 'EOF'
# Task Manifest
# Created: $(date)
# Required fields before execution:

## Files affected
- [List files that will be modified]

## Edge cases found
- [List edge cases discovered]

## Alternatives considered
- [List alternative approaches]

## Risks identified
- [List potential risks]

## Question for user
- [Any questions before proceeding]
EOF
    ok "TASK_MANIFEST template created at .git/TASK_MANIFEST"
    echo "  Fill in the fields before executing any task."
    exit 0
    ;;

  show)
    if [ ! -f "$MANIFEST" ]; then
      fail "No TASK_MANIFEST found"
      exit 1
    fi
    echo "=== TASK_MANIFEST ==="
    cat "$MANIFEST"
    exit 0
    ;;

  *)
    echo "Usage: bash scripts/task-manifest.sh [check|create|show]"
    exit 2
    ;;
esac
