#!/usr/bin/env bash
# skill-gate.sh — Verify skills were consulted before implementation
# Rule 1: "Always check skills first. Never implement directly if a skill applies."
#
# This script checks if the session has evidence of skill consultation.
# Called by pre-commit hook and by agent before any file modifications.
#
# Usage:
#   bash scripts/skill-gate.sh check    # Check if skills were loaded
#   bash scripts/skill-gate.sh mark     # Mark that skills were consulted
#   bash scripts/skill-gate.sh reset    # Reset skill consultation marker
#
# Exit codes:
#   0 = skills consulted (or gate passed)
#   1 = skills NOT consulted — BLOCK implementation

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
SKILL_MARKER="${REPO_ROOT}/.git/SKILLS_CONSULTED"
SESSION_FILE="${REPO_ROOT}/.git/SESSION_SKILLS"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ACTION="${1:-check}"

case "$ACTION" in
  check)
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  SKILL GATE — Rule 1 Enforcement           ║"
    echo "╚════════════════════════════════════════════╝"

    # Check if skill marker exists
    if [ ! -f "$SKILL_MARKER" ]; then
      echo ""
      echo "  ${RED}✗ NO SKILLS CONSULTED${NC}"
      echo ""
      echo "  Rule 1: 'Always check skills first."
      echo "  Never implement directly if a skill applies.'"
      echo ""
      echo "  Required actions BEFORE any file modification:"
      echo "  1. Load using-agent-skills: skill('using-agent-skills')"
      echo "  2. Identify applicable skill from discovery flow"
      echo "  3. Load the skill: skill('<skill-name>')"
      echo "  4. Follow the skill's workflow"
      echo ""
      echo "  Available skills for this task:"
      echo "    - frontend-web (websites, landing pages)"
      echo "    - frontend-ui-engineering (UI components)"
      echo "    - visual-frontend-mastery (design + animations)"
      echo "    - security-and-hardening (security review)"
      echo "    - test-driven-development (testing)"
      echo "    - code-review-and-quality (review)"
      echo "    - ... and 30+ more"
      echo ""
      echo "  ${YELLOW}To bypass (NOT RECOMMENDED):${NC}"
      echo "    echo 'override: <reason>' > $SKILL_MARKER"
      echo ""
      exit 1
    fi

    # Verify marker is fresh (created this session)
    MARKER_AGE=$(( $(date +%s) - $(stat -c %Y "$SKILL_MARKER" 2>/dev/null || echo "0") ))
    if [ "$MARKER_AGE" -gt 3600 ]; then
      echo ""
      echo "  ${YELLOW}⚠ Skill marker is ${MARKER_AGE}s old (>1 hour)${NC}"
      echo "  Consider re-consulting skills if task context changed."
      echo ""
    fi

    SKILL_NAME=$(cat "$SKILL_MARKER" 2>/dev/null | head -1)
    echo "  ${GREEN}✓${NC} Skills consulted: ${SKILL_NAME:-unknown}"
    echo ""
    ;;

  mark)
    # Mark that skills were consulted
    SKILL_NAME="${2:-unknown}"
    mkdir -p "$(dirname "$SKILL_MARKER")"
    echo "$SKILL_NAME" > "$SKILL_MARKER"
    echo "$SKILL_NAME:$(date +%s)" >> "$SESSION_FILE"
    echo "  ${GREEN}✓${NC} Skill consultation marked: $SKILL_NAME"
    ;;

  reset)
    # Reset marker (new session)
    rm -f "$SKILL_MARKER"
    echo "  ${GREEN}✓${NC} Skill marker reset"
    ;;

  *)
    echo "Usage: $0 {check|mark|reset}"
    echo "  check  — Verify skills were consulted (exit 1 if not)"
    echo "  mark   — Mark that skills were consulted"
    echo "  reset  — Reset skill consultation marker"
    exit 1
    ;;
esac
