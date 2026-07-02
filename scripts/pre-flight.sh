#!/usr/bin/env bash
# pre-flight.sh — Pre-Action Git State Check
# BLOCKING gate. Run BEFORE any file edit, creation, or deletion.
# Source: engineering-fundamentals Pre-Flight + AGENTS.md Rule 0d
#
# Usage: bash scripts/pre-flight.sh
#   or source scripts/pre-flight.sh (to get variables)
#
# Exits 0 if all checks pass, 1 if any fail.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
PASS=0
FAIL=0

check() {
  local label="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo -e "  ${GREEN}✓${NC} $label"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $label — $3"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  PRE-FLIGHT CHECK                         ║"
echo "╚════════════════════════════════════════════╝"
echo ""

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$REPO_ROOT" ]; then
  check "Not a git repository" "fail" "Run from a git repo or init first"
  echo -e "\n${RED}✗ $FAIL check(s) failed. BLOCKING.${NC}\n"
  exit 1
fi

cd "$REPO_ROOT"

# 1. Git repository exists
check "Git repository" "ok" ""

# 2. Current branch (main/master or task branch expected)
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
  check "Detached HEAD" "fail" "Checkout a branch before making changes"
else
  check "Branch: $BRANCH" "ok" ""
fi

# 3. Working tree clean
if [ -z "$(git status --porcelain)" ]; then
  check "Working tree clean" "ok" ""
else
  MODIFIED=$(git status --porcelain | wc -l)
  check "Working tree clean" "fail" "$MODIFIED uncommitted change(s). Commit or stash before new work."
fi

# 4. No unpulled remote changes
FETCH_OUTPUT=$(git fetch --dry-run 2>&1)
if [ -z "$FETCH_OUTPUT" ]; then
  check "Remote up to date" "ok" ""
else
  check "Remote up to date" "fail" "Unpulled remote changes. Run 'git pull --rebase' first."
fi

# 5. Upstream tracking configured
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null || echo "")
if [ -z "$UPSTREAM" ]; then
  check "Upstream configured" "fail" "No upstream tracking branch. Set with: git branch -u origin/<branch>"
else
  check "Upstream: $UPSTREAM" "ok" ""
fi

echo ""
echo "───"
if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}✗ $FAIL check(s) failed. BLOCKING.${NC}"
  echo "Run the following before proceeding:"
  if echo "$FETCH_OUTPUT" | grep -q .; then
    echo "  git pull --rebase"
  fi
  if [ -n "$(git status --porcelain)" ]; then
    echo "  git status  (commit or stash changes)"
  fi
  echo ""
  exit 1
else
  echo -e "${GREEN}✓ $PASS check(s) passed. Proceed.${NC}"
  echo ""
  exit 0
fi
