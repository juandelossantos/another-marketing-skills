#!/usr/bin/env bash
# edit-guard — Structural Integrity Gate for File Edits
# BLOCKING gate. Run BEFORE and AFTER every file edit.
# Prevents the "lost sections" failure mode by verifying:
#   - File structure before edit (known markers present)
#   - String uniqueness before edit (oldString count = 1)
#   - File structure after edit (same markers still present)
#
# Usage:
#   bash scripts/edit-guard.sh check <file> <marker> [marker...]
#     Verifies all markers exist in file. Exits 1 if any missing.
#
#   bash scripts/edit-guard.sh count <file> <string>
#     Counts occurrences of exact string. Exits 1 if not exactly 1.
#
#   bash scripts/edit-guard.sh lines <file>
#     Returns line count.
#
#   bash scripts/edit-guard.sh preflight <file> <markers...>
#     Combined: check markers + record line count to tmpfile.
#     Usage: PRE=$(bash scripts/edit-guard.sh preflight index.html marker1 marker2)
#
#   bash scripts/edit-guard.sh verify <file>
#     After edit: compare line count with tmpfile, warn if >20% change.
#
# Exit codes:
#   0 — All checks pass
#   1 — BLOCKING. Integrity violation.
#   2 — Usage error.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TMPDIR="${REPO_ROOT}/.opencode/.edit-guard"
mkdir -p "$TMPDIR"

usage() {
  echo "Usage:"
  echo "  bash scripts/edit-guard.sh check <file> <marker> [marker...]"
  echo "  bash scripts/edit-guard.sh count <file> <string>"
  echo "  bash scripts/edit-guard.sh lines <file>"
  echo "  bash scripts/edit-guard.sh preflight <file> <marker> [marker...]"
  echo "  bash scripts/edit-guard.sh verify <file>"
  exit 2
}

cmd_check() {
  local file="$1"
  shift
  local markers=("$@")
  local missing=0

  if [ ! -f "$file" ]; then
    echo "  ${RED}✗${NC} File not found: $file"
    return 1
  fi

  for marker in "${markers[@]}"; do
    if grep -Fqc "$marker" "$file" 2>/dev/null; then
      echo "  ${GREEN}✓${NC} Marker found: ${marker:0:60}"
    else
      echo "  ${RED}✗${NC} MISSING: ${marker:0:60}"
      missing=$((missing + 1))
    fi
  done

  [ "$missing" -eq 0 ]
}

cmd_count() {
  local file="$1"
  local string="$2"

  if [ ! -f "$file" ]; then
    echo "  ${RED}✗${NC} File not found: $file"
    return 1
  fi

  local count
  count=$(grep -Fc "$string" "$file" 2>/dev/null || echo 0)

  echo "  Count of \"${string:0:50}\": $count"

  if [ "$count" -eq 0 ]; then
    echo "  ${RED}✗${NC} String NOT found — cannot edit. Verify exact text."
    return 1
  elif [ "$count" -gt 1 ]; then
    echo "  ${RED}✗${NC} String found $count times — not unique. Provide more context."
    return 1
  fi

  echo "  ${GREEN}✓${NC} String is unique — safe to edit."
}

cmd_lines() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "0"
    return 1
  fi

  wc -l < "$file" | tr -d ' '
}

cmd_preflight() {
  local file="$1"
  shift
  local markers=("$@")
  local pass=true

  FILE_ID=$(echo "$file" | md5sum | cut -c1-8)
  LINES=$(cmd_lines "$file")
  echo "$LINES" > "$TMPDIR/lines-$FILE_ID"

  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║  EDIT GUARD — PRE-FLIGHT                  ║"
  echo "╚════════════════════════════════════════════╝"
  echo "  File: $file"
  echo "  Lines: $LINES"
  echo ""

  if ! cmd_check "$file" "${markers[@]}"; then
    echo ""
    echo "  ${RED}✗ BLOCKING: Structural integrity check failed.${NC}"
    echo "  File is corrupted or missing expected sections."
    echo "  STOP. Do not edit. Investigate first."
    echo ""
    return 1
  fi

  echo ""
  echo "  ${GREEN}✓ Pre-flight passed — safe to edit.${NC}"
  echo ""
}

cmd_verify() {
  local file="$1"

  FILE_ID=$(echo "$file" | md5sum | cut -c1-8)
  LINES_BEFORE=$(cat "$TMPDIR/lines-$FILE_ID" 2>/dev/null || echo 0)
  LINES_AFTER=$(cmd_lines "$file")

  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║  EDIT GUARD — VERIFY                      ║"
  echo "╚════════════════════════════════════════════╝"
  echo "  File: $file"
  echo "  Lines before: $LINES_BEFORE"
  echo "  Lines after:  $LINES_AFTER"
  echo "  Diff:         $(( LINES_AFTER - LINES_BEFORE ))"

  if [ "$LINES_BEFORE" -eq 0 ]; then
    echo "  ${YELLOW}⚠ No pre-flight data. Run preflight before editing.${NC}"
    return 1
  fi

  local diff=$(( LINES_AFTER - LINES_BEFORE ))
  local abs_diff=${diff#-}
  local threshold=$(( LINES_BEFORE / 5 ))  # 20%

  if [ "$abs_diff" -gt "$threshold" ] && [ "$abs_diff" -gt 5 ]; then
    echo "  ${RED}✗ BLOCKING: Line count changed by $abs_diff (>{${threshold}}).${NC}"
    echo "  Edit may have corrupted the file structure."
    echo "  STOP. Read file and verify integrity."
    echo ""
    return 1
  fi

  echo "  ${GREEN}✓ Line count within tolerance.${NC}"
  echo ""
}

case "${1:-}" in
  check)    shift; cmd_check "$@" ;;
  count)    shift; cmd_count "$@" ;;
  lines)    shift; cmd_lines "$@" ;;
  preflight) shift; cmd_preflight "$@" ;;
  verify)   shift; cmd_verify "$@" ;;
  *)        usage ;;
esac
