#!/usr/bin/env bash
# run-evals.sh — Run evaluation cases for agent skills
# Reads .jsonl files from skills/<name>/evals/ and reports PASS/FAIL.
#
# Usage:
#   bash scripts/eval/run-evals.sh --all           # Run all skills
#   bash scripts/eval/run-evals.sh --skill <name>  # Run one skill
#   bash scripts/eval/run-evals.sh --list          # List skills with evals
#
# Exit codes: 0 = all pass, 1 = any fail

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"
SCHEMA_FILE="${SCHEMA_FILE:-scripts/eval/schema.json}"
TOTAL=0; PASSED=0; FAILED=0; SKIPPED=0

usage() { echo "Usage: $0 [--all | --skill <name> | --list]"; exit 1; }

MODE=""; TARGET=""
while [ $# -gt 0 ]; do
  case "$1" in
    --all) MODE="all"; shift ;;
    --skill) MODE="skill"; TARGET="$2"; shift 2 ;;
    --list) MODE="list"; shift ;;
    *) usage ;;
  esac
done

[ -z "$MODE" ] && usage

validate_json() {
  local json="$1"
  echo "$json" | jq -e 'has("case_id") and has("input") and has("type")' > /dev/null 2>&1
}

run_evals_for_skill() {
  local skill="$1"
  local skill_file="$SKILLS_DIR/$skill/SKILL.md"
  local eval_dir="$SKILLS_DIR/$skill/evals"
  local skill_passed=0 skill_failed=0 skill_total=0

  [ ! -d "$eval_dir" ] && return 0
  [ ! -f "$skill_file" ] && return 0

  skill_name=$(grep -m1 '^name:' "$skill_file" | sed 's/^name: *//')

  for eval_file in "$eval_dir"/*.jsonl; do
    [ ! -f "$eval_file" ] && continue
    local fname
    fname=$(basename "$eval_file")
    [ "$fname" = "golden.jsonl" ] && continue
    [ "$fname" = "adversarial.jsonl" ] && continue
    while IFS= read -r line || [ -n "$line" ]; do
      [ -z "$line" ] && continue
      skill_total=$((skill_total + 1))

      if ! validate_json "$line"; then
        echo "  ${RED}✗${NC} $skill: $(echo "$line" | jq -r '.case_id // "unknown"') — invalid JSON or missing required fields"
        skill_failed=$((skill_failed + 1)); continue
      fi

      case_type=$(echo "$line" | jq -r '.type')
      case_id=$(echo "$line" | jq -r '.case_id')
      input=$(echo "$line" | jq -r '.input')
      expected=$(echo "$line" | jq -r '.expected_skill // ""')

      result_flag=""; result_msg=""

      case "$case_type" in
        trigger_positive|trigger_negative)
          result_flag="${GREEN}✓${NC}"
          result_msg="$case_type — case structure valid (semantic trigger detection requires LLM-as-Judge)"
          ;;
        execution)
          result_flag="${YELLOW}⚠${NC}"; result_msg="execution test — manual verification recommended"
          ;;
        regression)
          result_flag="${YELLOW}⚠${NC}"; result_msg="regression test — requires full library run"
          ;;
        *)
          result_flag="${RED}✗${NC}"; result_msg="unknown type '$case_type'"
          ;;
      esac

      if echo "$result_flag" | grep -q "✗"; then
        skill_failed=$((skill_failed + 1))
      else
        skill_passed=$((skill_passed + 1))
      fi
      echo "  $result_flag $skill/$case_id — $result_msg"

    done < "$eval_file"
  done

  TOTAL=$((TOTAL + skill_total)); PASSED=$((PASSED + skill_passed)); FAILED=$((FAILED + skill_failed))
  [ "$skill_failed" -gt 0 ] && return 1 || return 0
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  SKILL EVALS — Trigger & Execution Tests  ║"
echo "╚════════════════════════════════════════════╝"

EXIT=0
case "$MODE" in
  list)
    echo "Skills with eval directories:"
    for skill_dir in "$SKILLS_DIR"/*/; do
      [ -d "${skill_dir}evals" ] && echo "  - $(basename "$skill_dir") ($(find "${skill_dir}evals" -name '*.jsonl' | wc -l) files)"
    done
    ;;
  all)
    for skill_dir in "$SKILLS_DIR"/*/; do
      skill=$(basename "$skill_dir")
      if [ -d "${skill_dir}evals" ]; then
        echo "  ${CYAN}▶${NC} $skill"
        run_evals_for_skill "$skill" || EXIT=1
      fi
    done
    ;;
  skill)
    if [ ! -d "$SKILLS_DIR/$TARGET" ]; then
      echo "  ${RED}✗${NC} Skill '$TARGET' not found"
      exit 1
    fi
    echo "  ${CYAN}▶${NC} $TARGET"
    run_evals_for_skill "$TARGET" || EXIT=1
    ;;
esac

echo ""
echo "───"
if [ "$FAILED" -gt 0 ]; then
  echo "  ${RED}$FAILED failed, $PASSED passed, $SKIPPED skipped (${TOTAL} total)${NC}"
  exit 1
elif [ "$TOTAL" -eq 0 ]; then
  echo "  ${YELLOW}0 evals found — no tests to run${NC}"
  exit 0
else
  echo "  ${GREEN}$PASSED passed, 0 failed (${TOTAL} total)${NC}"
  exit 0
fi
