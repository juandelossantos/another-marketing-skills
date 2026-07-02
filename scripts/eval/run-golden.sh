#!/usr/bin/env bash
# run-golden.sh — Run golden dataset evaluation for agent skills
# Reads golden.jsonl from skills/<name>/evals/ and validates outputs.
#
# Usage:
#   bash scripts/eval/run-golden.sh --all           # Run all skills
#   bash scripts/eval/run-golden.sh --skill <name>  # Run one skill
#
# Exit codes: 0 = all pass, 1 = any fail

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"
TOTAL=0; PASSED=0; FAILED=0; WARNED=0

usage() { echo "Usage: $0 [--all | --skill <name>]"; exit 1; }

MODE=""; TARGET=""
while [ $# -gt 0 ]; do
  case "$1" in
    --all) MODE="all"; shift ;;
    --skill) MODE="skill"; TARGET="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[ -z "$MODE" ] && usage

validate_golden() {
  local json="$1"
  echo "$json" | jq -e 'has("input") and has("expected_output") and has("rubric")' > /dev/null 2>&1
}

run_golden_for_skill() {
  local skill="$1"
  local golden_file="$SKILLS_DIR/$skill/evals/golden.jsonl"
  local skill_passed=0 skill_failed=0 skill_warned=0 skill_total=0

  [ ! -f "$golden_file" ] && return 0

  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    skill_total=$((skill_total + 1))

    if ! validate_golden "$line"; then
      local cid="case_$(printf "%03d" "$skill_total")"
      echo "  ${RED}✗${NC} $skill/$cid — invalid golden case (missing input, expected_output, or rubric)"
      skill_failed=$((skill_failed + 1)); continue
    fi

    local input rubric_count
    input=$(echo "$line" | jq -r '.input' | head -c 60)
    rubric_count=$(echo "$line" | jq '.rubric | length')

    # For now: structural validation only. Rubric checking requires LLM-as-Judge (Phase 9)
    if [ "$rubric_count" -ge 1 ]; then
      echo "  ${GREEN}✓${NC} $skill — \"$input...\" ($rubric_count rubric criteria)"
      skill_passed=$((skill_passed + 1))
    else
      echo "  ${YELLOW}⚠${NC} $skill — \"$input...\" (no rubric criteria)"
      skill_warned=$((skill_warned + 1))
    fi
  done < "$golden_file"

  TOTAL=$((TOTAL + skill_total)); PASSED=$((PASSED + skill_passed))
  FAILED=$((FAILED + skill_failed)); WARNED=$((WARNED + skill_warned))
  [ "$skill_failed" -gt 0 ] && return 1 || return 0
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  GOLDEN DATASET — Output Validation Tests ║"
echo "╚════════════════════════════════════════════╝"

EXIT=0
case "$MODE" in
  all)
    for skill_dir in "$SKILLS_DIR"/*/; do
      skill=$(basename "$skill_dir")
      if [ -f "${skill_dir}evals/golden.jsonl" ]; then
        echo "  ${CYAN}▶${NC} $skill"
        run_golden_for_skill "$skill" || EXIT=1
      fi
    done
    ;;
  skill)
    if [ ! -d "$SKILLS_DIR/$TARGET" ]; then
      echo "  ${RED}✗${NC} Skill '$TARGET' not found"
      exit 1
    fi
    if [ ! -f "$SKILLS_DIR/$TARGET/evals/golden.jsonl" ]; then
      echo "  ${YELLOW}⚠${NC} $TARGET has no golden.jsonl"
      exit 0
    fi
    echo "  ${CYAN}▶${NC} $TARGET"
    run_golden_for_skill "$TARGET" || EXIT=1
    ;;
esac

echo ""
echo "───"
if [ "$FAILED" -gt 0 ]; then
  echo "  ${RED}$FAILED failed, $PASSED passed, $WARNED warnings (${TOTAL} total)${NC}"
  exit 1
elif [ "$TOTAL" -eq 0 ]; then
  echo "  ${YELLOW}0 golden datasets found${NC}"
  exit 0
else
  echo "  ${GREEN}$PASSED passed, $WARNED warnings (${TOTAL} total)${NC}"
  exit 0
fi
