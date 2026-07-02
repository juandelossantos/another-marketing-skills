#!/usr/bin/env bash
# check-coverage.sh — Validate eval coverage across all skills
# Reports per-skill coverage: trigger, golden, adversarial
# Exit codes: 0 = all covered, 1 = any missing

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"
TOTAL=0; FULL=0; PARTIAL=0; NONE=0

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  EVAL COVERAGE REPORT                      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

printf "  %-40s %-10s %-10s %-10s\n" "Skill" "Trigger" "Golden" "Adversarial"
printf "  %-40s %-10s %-10s %-10s\n" "----" "-------" "------" "-----------"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill=$(basename "$skill_dir")
  TOTAL=$((TOTAL + 1))

  has_trigger=""; has_golden=""; has_adversarial=""
  trigger_count=0; golden_count=0; adv_count=0

  [ -f "${skill_dir}evals/trigger.jsonl" ] && has_trigger="${GREEN}✓${NC}" && trigger_count=$(wc -l < "${skill_dir}evals/trigger.jsonl") || has_trigger="${RED}✗${NC}"
  [ -f "${skill_dir}evals/golden.jsonl" ] && has_golden="${GREEN}✓${NC}" && golden_count=$(wc -l < "${skill_dir}evals/golden.jsonl") || has_golden="${YELLOW}−${NC}"
  [ -f "${skill_dir}evals/adversarial.jsonl" ] && has_adversarial="${GREEN}✓${NC}" && adv_count=$(wc -l < "${skill_dir}evals/adversarial.jsonl") || has_adversarial="${YELLOW}−${NC}"

  printf "  %-40s %-10s %-10s %-10s\n" "$skill" "$has_trigger" "$has_golden" "$has_adversarial"

  if [ "$trigger_count" -ge 2 ] && [ "$golden_count" -ge 1 ] && [ "$adv_count" -ge 1 ]; then
    FULL=$((FULL + 1))
  elif [ "$trigger_count" -ge 1 ]; then
    PARTIAL=$((PARTIAL + 1))
  else
    NONE=$((NONE + 1))
  fi
done

echo ""
echo "───"
echo "  ${GREEN}$FULL full coverage${NC} · ${YELLOW}$PARTIAL partial${NC} · ${RED}$NONE none${NC} · ${CYAN}$TOTAL total${NC}"

if [ "$NONE" -gt 0 ]; then
  echo "  ${YELLOW}Skills without trigger evals may bypass trigger validation${NC}"
fi
if [ "$PARTIAL" -gt 0 ]; then
  echo "  ${YELLOW}Partial coverage: missing golden or adversarial datasets${NC}"
fi
exit 0
