#!/usr/bin/env bash
# commit-approval.sh — Records user approval for commit (v2 — time-window based)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy:
# 1. Agent presents DECISION POINT with manifest, diff, test results
# 2. User says "yes commit" in chat → agent runs this script
# 3. This writes .git/COMMIT_APPROVED with timestamp + message
# 4. commit-msg hook checks: file exists? < 5 min old? message matches?
# 5. No SHA256 tokens. No friction for the user.
#
# Usage: bash scripts/commit-approval.sh "commit message" [file1 file2...]
#   Must be run from repo root.
#   Files parameter is optional — used for audit trail only.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG="${1:-}"
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
APPROVAL_FILE="${REPO_ROOT}/.git/COMMIT_APPROVED"
MANIFEST_FILE="${REPO_ROOT}/.git/COMMIT_MANIFEST"

if [[ -z "$COMMIT_MSG" ]]; then
  echo -e "${RED}Error: No commit message provided.${NC}"
  echo "Usage: bash scripts/commit-approval.sh \"feat: message\" [file1 file2...]"
  echo ""
  echo "  Agent runs this AFTER user says 'yes commit' in chat."
  echo "  Writes .git/COMMIT_APPROVED with timestamp + message."
  echo "  The commit-msg hook checks freshness (<5 min) and message match."
  exit 1
fi

# Check for manifest — optional but recommended
if [[ -f "$MANIFEST_FILE" ]]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  COMMIT MANIFEST — reviewed by user                      ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  cat "$MANIFEST_FILE"
  echo ""
  rm -f "$MANIFEST_FILE"
fi

# Write approval file
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
{
  echo "timestamp=${TIMESTAMP}"
  echo "message=${COMMIT_MSG}"
  if [[ $# -gt 1 ]]; then
    shift
    echo "files=$*"
  fi
} > "$APPROVAL_FILE"

echo -e "${GREEN}✓${NC} Commit approved."
echo "  Message: ${GREEN}${COMMIT_MSG}${NC}"
echo "  Timestamp: ${TIMESTAMP}"
echo "  ${YELLOW}Approval valid for 5 minutes.${NC}"
echo "  ${YELLOW}Agent: User said 'yes commit' in chat before this script ran.${NC}"
