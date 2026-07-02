#!/usr/bin/env bash
# skill-lint.sh — Validates skill structure and Rule 6 compliance
# Run before committing any SKILL.md changes

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SKILLS_DIR="${1:-skills}"
ERRORS=0
WARNINGS=0

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  SKILL LINT — Rule 6 Compliance Check     ║"
echo "╚════════════════════════════════════════════╝"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  [ -f "$skill_file" ] || continue

  lines=$(wc -l < "$skill_file")

  # Check 1: SKILL.md must exist and have content
  if [ "$lines" -lt 10 ]; then
    echo "  ${RED}✗${NC} $skill_name — SKILL.md too short ($lines lines, minimum 10)"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check 2: SKILL.md must be under 250 lines (Rule 6: skills as indexes)
  if [ "$lines" -gt 250 ]; then
    echo "  ${RED}✗${NC} $skill_name — SKILL.md exceeds 250 lines ($lines lines)"
    echo "       Rule 6: Skills must be ~250-line indexes. Move detailed content to guides/"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ${GREEN}✓${NC} $skill_name — SKILL.md size OK ($lines lines)"
  fi

  # Check 3: Must have "when to activate" or equivalent
  if ! grep -qiE '(when to (use|activate|invoke)|use when|triggers on|activate when)' "$skill_file"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — No 'when to activate' section found"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 4: Must have YAML frontmatter with name and description
  if ! head -5 "$skill_file" | grep -q "^name:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'name' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! head -10 "$skill_file" | grep -q "description:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'description' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 5: If skill has guides/, SKILL.md should reference them (index pattern)
  if [ -d "${skill_dir}guides" ]; then
    guide_count=$(find "${skill_dir}guides" -name "*.md" | wc -l)
    ref_count=$(grep -cE 'guides/|→ See' "$skill_file" 2>/dev/null || echo 0)
    if [ "$guide_count" -gt 0 ] && [ "$ref_count" -eq 0 ]; then
      echo "  ${YELLOW}⚠${NC} $skill_name — Has $guide_count guides but SKILL.md doesn't reference them"
      echo "       Rule 6: Skills should be indexes that reference guides"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  # Check 6: Micro-skills (<100 lines) are exempt from 2-guide rule
  if [ "$lines" -lt 100 ]; then
    echo "  ${GREEN}✓${NC} $skill_name — Micro-skill ($lines lines), exempt from guide requirement"
  fi
done

echo ""
echo "───"
if [ "$ERRORS" -gt 0 ]; then
  echo "  ${RED}$ERRORS error(s), $WARNINGS warning(s)${NC}"
  echo "  Fix errors before committing. Warnings are non-blocking."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "  ${YELLOW}0 errors, $WARNINGS warning(s)${NC}"
  echo "  Warnings are non-blocking but recommend fixing."
  exit 0
else
  echo "  ${GREEN}0 errors, 0 warnings — all skills compliant${NC}"
  exit 0
fi
