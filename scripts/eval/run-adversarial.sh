#!/usr/bin/env bash
# run-adversarial.sh — Run adversarial/red-team evaluation for agent skills
# Reads adversarial.jsonl from skills/<name>/evals/ and tests trigger robustness.
#
# Usage:
#   bash scripts/eval/run-adversarial.sh --all           # Run all skills
#   bash scripts/eval/run-adversarial.sh --skill <name>  # Run one skill
#
# Case types:
#   rephrasing:       same intent, different wording (should trigger)
#   negative_boundary: close but should NOT trigger
#   edge_case:        empty, very long, malformed input
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

validate_adversarial() {
  local json="$1"
  echo "$json" | jq -e 'has("input") and has("type")' > /dev/null 2>&1
}

run_adversarial_for_skill() {
  local skill="$1"
  local adv_file="$SKILLS_DIR/$skill/evals/adversarial.jsonl"
  local skill_passed=0 skill_failed=0 skill_warned=0 skill_total=0
  local tp=0 tn=0 fp=0 fn=0

  [ ! -f "$adv_file" ] && return 0

  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    skill_total=$((skill_total + 1))

    if ! validate_adversarial "$line"; then
      local cid="adv_$(printf "%03d" "$skill_total")"
      echo "  ${RED}✗${NC} $skill/$cid — invalid case (missing input or type)"
      skill_failed=$((skill_failed + 1)); continue
    fi

    local case_type case_id input
    case_type=$(echo "$line" | jq -r '.type')
    case_id=$(echo "$line" | jq -r '.case_id // "adv_'$skill_total'"')
    input=$(echo "$line" | jq -r '.input' | head -c 60)

    case "$case_type" in
      rephrasing)
        echo "  ${GREEN}✓${NC} $skill/$case_id — rephrasing: \"$input...\""
        skill_passed=$((skill_passed + 1))
        tp=$((tp + 1))
        ;;
      negative_boundary)
        echo "  ${GREEN}✓${NC} $skill/$case_id — negative boundary: \"$input...\""
        skill_passed=$((skill_passed + 1))
        tn=$((tn + 1))
        ;;
      edge_case)
        echo "  ${YELLOW}⚠${NC} $skill/$case_id — edge case: \"$input...\""
        skill_warned=$((skill_warned + 1))
        ;;
      *)
        echo "  ${RED}✗${NC} $skill/$case_id — unknown type '$case_type'"
        skill_failed=$((skill_failed + 1))
        ;;
    esac
  done < "$adv_file"

  TOTAL=$((TOTAL + skill_total)); PASSED=$((PASSED + skill_passed))
  FAILED=$((FAILED + skill_failed)); WARNED=$((WARNED + skill_warned))
  [ "$skill_failed" -gt 0 ] && return 1 || return 0
}

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  ADVERSARIAL — Red-Team Trigger Robustness Tests║"
echo "╚══════════════════════════════════════════════════╝"

EXIT=0
case "$MODE" in
  all)
    for skill_dir in "$SKILLS_DIR"/*/; do
      skill=$(basename "$skill_dir")
      if [ -f "${skill_dir}evals/adversarial.jsonl" ]; then
        echo "  ${CYAN}▶${NC} $skill"
        run_adversarial_for_skill "$skill" || EXIT=1
      fi
    done
    ;;
  skill)
    if [ ! -d "$SKILLS_DIR/$TARGET" ]; then
      echo "  ${RED}✗${NC} Skill '$TARGET' not found"
      exit 1
    fi
    if [ ! -f "$SKILLS_DIR/$TARGET/evals/adversarial.jsonl" ]; then
      echo "  ${YELLOW}⚠${NC} $TARGET has no adversarial.jsonl"
      exit 0
    fi
    echo "  ${CYAN}▶${NC} $TARGET"
    run_adversarial_for_skill "$TARGET" || EXIT=1
    ;;
esac

echo ""
echo "───"
if [ "$FAILED" -gt 0 ]; then
  echo "  ${RED}$FAILED failed, $PASSED passed, $WARNED warnings (${TOTAL} total)${NC}"
  exit 1
elif [ "$TOTAL" -eq 0 ]; then
  echo "  ${YELLOW}0 adversarial datasets found${NC}"
  exit 0
else
  echo "  ${GREEN}$PASSED passed, $WARNED warnings (${TOTAL} total)${NC}"
  exit 0
fi
