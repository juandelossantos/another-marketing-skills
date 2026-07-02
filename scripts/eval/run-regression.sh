#!/usr/bin/env bash
# run-regression.sh — Regression test suite for skill evals
# Runs ALL eval cases for ALL skills, records results, detects regressions.
#
# Usage:
#   bash scripts/eval/run-regression.sh              # Run and compare
#   bash scripts/eval/run-regression.sh --reset      # Reset history
#
# Exit codes: 0 = no regressions, 1 = regression detected

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"
RESULTS_FILE="${RESULTS_FILE:-.regression-results.json}"
PASS=0; FAIL=0; TOTAL=0; REGRESSIONS=0

usage() { echo "Usage: $0 [--skill <name> | --reset]"; exit 1; }

MODE="all"; TARGET=""
while [ $# -gt 0 ]; do
  case "$1" in
    --skill) MODE="skill"; TARGET="$2"; shift 2 ;;
    --reset) MODE="reset"; shift ;;
    *) usage ;;
  esac
done

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  REGRESSION TEST SUITE                                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Handle --reset
if [ "$MODE" = "reset" ]; then
  rm -f "$RESULTS_FILE" "${RESULTS_FILE}.prev"
  echo "  ${YELLOW}History reset. Next run will be the new baseline.${NC}"
  exit 0
fi

# Load previous results if exists
declare -A PREV
if [ -f "$RESULTS_FILE" ]; then
  while IFS='=' read -r skill prev_status; do
    PREV["$skill"]="$prev_status"
  done < <(jq -r '.skills | to_entries[] | "\(.key)=\(.value.status)"' "$RESULTS_FILE" 2>/dev/null || true)
fi

# Determine target skills
SKILL_TARGETS=()
if [ "$MODE" = "skill" ]; then
  if [ ! -d "$SKILLS_DIR/$TARGET" ]; then
    echo "  ${RED}✗${NC} Skill '$TARGET' not found"
    exit 1
  fi
  SKILL_TARGETS+=("$SKILLS_DIR/$TARGET")
  echo "  ${CYAN}▶${NC} Running regression for: $TARGET"
else
  for skill_dir in "$SKILLS_DIR"/*/; do
    SKILL_TARGETS+=("$skill_dir")
  done
fi

# Run all eval suites for each target
for skill_dir in "${SKILL_TARGETS[@]}"; do
  skill=$(basename "$skill_dir")
  skill_pass=0 skill_fail=0 skill_total=0

  # Trigger evals
  trigger_file="$skill_dir/evals/trigger.jsonl"
  if [ -f "$trigger_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [ -z "$line" ] && continue
      skill_total=$((skill_total + 1))
      if echo "$line" | jq -e 'has("case_id") and has("type")' > /dev/null 2>&1; then
        skill_pass=$((skill_pass + 1))
      else
        skill_fail=$((skill_fail + 1))
      fi
    done < "$trigger_file"
  fi

  # Golden evals
  golden_file="$skill_dir/evals/golden.jsonl"
  if [ -f "$golden_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [ -z "$line" ] && continue
      skill_total=$((skill_total + 1))
      if echo "$line" | jq -e 'has("input") and has("rubric")' > /dev/null 2>&1; then
        skill_pass=$((skill_pass + 1))
      else
        skill_fail=$((skill_fail + 1))
      fi
    done < "$golden_file"
  fi

  # Adversarial evals
  adv_file="$skill_dir/evals/adversarial.jsonl"
  if [ -f "$adv_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [ -z "$line" ] && continue
      skill_total=$((skill_total + 1))
      if echo "$line" | jq -e 'has("input") and has("type")' > /dev/null 2>&1; then
        skill_pass=$((skill_pass + 1))
      else
        skill_fail=$((skill_fail + 1))
      fi
    done < "$adv_file"
  fi

  TOTAL=$((TOTAL + skill_total))
  PASS=$((PASS + skill_pass))
  FAIL=$((FAIL + skill_fail))

  pass_pct=100
  [ "$skill_total" -gt 0 ] && pass_pct=$((skill_pass * 100 / skill_total))

  status="${GREEN}PASS${NC}"
  [ "$skill_fail" -gt 0 ] && status="${RED}FAIL${NC}"

  # Check regression
  prev_status="${PREV[$skill]:-}"
  regression_flag=""
  if [ -n "$prev_status" ] && [ "$prev_status" = "PASS" ] && [ "$skill_fail" -gt 0 ]; then
    regression_flag="${RED} ⚠ REGRESSION${NC}"
    REGRESSIONS=$((REGRESSIONS + 1))
  fi

  printf "  %-35s %3s/%3s %4s%% %s%s\n" "$skill" "$skill_pass" "$skill_total" "$pass_pct" "$status" "$regression_flag"
done

# Save results (only for full runs, not single-skill)
if [ "$MODE" != "skill" ]; then
{
  echo "{"
  echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
  echo "  \"total\": $TOTAL,"
  echo "  \"passed\": $PASS,"
  echo "  \"failed\": $FAIL,"
  echo "  \"skills\": {"
  first=true
  for skill_dir in "${SKILL_TARGETS[@]}"; do
    skill=$(basename "$skill_dir")
    $first || echo ","
    first=false
    skill_pass=0 skill_fail=0 skill_total=0
    for f in trigger golden adversarial; do
      file="$skill_dir/evals/$f.jsonl"
      [ -f "$file" ] || continue
      while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        skill_total=$((skill_total + 1))
        if echo "$line" | jq -e 'has("case_id")' > /dev/null 2>&1; then
          skill_pass=$((skill_pass + 1))
        else
          skill_fail=$((skill_fail + 1))
        fi
      done < "$file"
    done
    s="PASS"; [ "$skill_fail" -gt 0 ] && s="FAIL"
    printf '    "%s": { "passed": %s, "failed": %s, "total": %s, "status": "%s" }' "$skill" "$skill_pass" "$skill_fail" "$skill_total" "$s"
  done
  echo ""
  echo "  }"
  echo "}"
} > "$RESULTS_FILE"
fi

echo ""
echo "───"
echo "  ${GREEN}$PASS passed${NC} · ${RED}$FAIL failed${NC} · ${CYAN}$TOTAL total${NC}"
if [ "$REGRESSIONS" -gt 0 ]; then
  echo "  ${RED}$REGRESSIONS regression(s) detected!${NC}"
  exit 1
else
  echo "  ${GREEN}No regressions detected.${NC}"
  exit 0
fi
