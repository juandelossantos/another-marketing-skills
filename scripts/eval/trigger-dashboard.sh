#!/usr/bin/env bash
# trigger-dashboard.sh — Trigger accuracy dashboard for agent skills
# Reads trigger.jsonl from skills/<name>/evals/ and reports per-skill accuracy.
# Tracks history in .trigger-stats.json for trend comparison.
#
# Usage:
#   bash scripts/eval/trigger-dashboard.sh --all          # Full report
#   bash scripts/eval/trigger-dashboard.sh --skill <name> # One skill
#
# Accuracy formula: (positive_cases * weight + negative_cases * weight) / target
# Threshold: 90% — skills below are flagged
#
# Exit codes: 0 = all skills ≥90%, 1 = any skill below threshold

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"
STATS_FILE="${STATS_FILE:-.trigger-stats.json}"
TARGET_POSITIVE=2
TARGET_NEGATIVE=1
THRESHOLD=90

TOTAL=0; PASS=0; WARN=0; FAIL=0

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

calc_accuracy() {
  local pos="$1" neg="$2"
  # Cap at targets
  [ "$pos" -gt "$TARGET_POSITIVE" ] && pos=$TARGET_POSITIVE
  [ "$neg" -gt "$TARGET_NEGATIVE" ] && neg=$TARGET_NEGATIVE
  local max=$((TARGET_POSITIVE + TARGET_NEGATIVE))
  local total=$((pos + neg))
  echo $((total * 100 / max))
}

run_for_skill() {
  local skill="$1"
  local trigger_file="$SKILLS_DIR/$skill/evals/trigger.jsonl"
  local pos=0 neg=0 total=0

  [ ! -f "$trigger_file" ] && return 2

  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    total=$((total + 1))
    local case_type
    case_type=$(echo "$line" | jq -r '.type // "unknown"')
    case "$case_type" in
      trigger_positive) pos=$((pos + 1)) ;;
      trigger_negative) neg=$((neg + 1)) ;;
    esac
  done < "$trigger_file"

  echo "$pos|$neg|$total"
}

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  TRIGGER ACCURACY DASHBOARD                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

case "$MODE" in
  all)
    printf "  %-30s %5s %5s %5s %7s %s\n" "Skill" "Pos" "Neg" "Tot" "Acc%" "Status"
    printf "  %-30s %5s %5s %5s %7s %s\n" "-----" "---" "---" "---" "----" "------"

    declare -A results

    for skill_dir in "$SKILLS_DIR"/*/; do
      skill=$(basename "$skill_dir")
      result=$(run_for_skill "$skill")
      rc=$?

      if [ "$rc" -eq 2 ]; then
        printf "  %-30s %5s %5s %5s %7s %s\n" "$skill" "-" "-" "-" "N/A" "${YELLOW}no data${NC}"
        WARN=$((WARN + 1))
        continue
      fi

      IFS='|' read -r pos neg total <<< "$result"
      acc=$(calc_accuracy "$pos" "$neg")
      results["$skill"]="$acc|$pos|$neg|$total"

      if [ "$acc" -ge "$THRESHOLD" ]; then
        printf "  %-30s %5s %5s %5s %5s%% %s\n" "$skill" "$pos" "$neg" "$total" "$acc" "${GREEN}✅${NC}"
        PASS=$((PASS + 1))
      else
        printf "  %-30s %5s %5s %5s %5s%% %s\n" "$skill" "$pos" "$neg" "$total" "$acc" "${RED}❌ <90%${NC}"
        FAIL=$((FAIL + 1))
      fi
      TOTAL=$((TOTAL + 1))
    done

    echo ""
    echo "───"
    echo "  ${GREEN}$PASS passed${NC} · ${RED}$FAIL below threshold${NC} · ${YELLOW}$WARN no data${NC} · $TOTAL total"

    # Save history
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    {
      echo "{"
      echo "  \"timestamp\": \"$TIMESTAMP\","
      echo "  \"threshold\": $THRESHOLD,"
      echo "  \"targets\": { \"positive\": $TARGET_POSITIVE, \"negative\": $TARGET_NEGATIVE },"
      echo "  \"skills\": {"
      first=true
      for skill in "${!results[@]}"; do
        $first && first=false || echo ","
        IFS='|' read -r acc pos neg total <<< "${results[$skill]}"
        printf '    "%s": { "accuracy": %s, "positive": %s, "negative": %s, "total": %s }' "$skill" "$acc" "$pos" "$neg" "$total"
      done
      echo ""
      echo "  }"
      echo "}"
    } > "$STATS_FILE"

    # Compare with previous if exists
    if [ -f "${STATS_FILE}.prev" ]; then
      echo ""
      echo "  ${CYAN}Historical comparison:${NC}"
      prev_total=$(jq -r '.skills | length' "${STATS_FILE}.prev" 2>/dev/null || echo "0")
      prev_pass=$(jq -r '[.skills[] | select(.accuracy >= '"$THRESHOLD"')] | length' "${STATS_FILE}.prev" 2>/dev/null || echo "0")
      echo "  Previous run: ${prev_pass}/$prev_total skills ≥${THRESHOLD}%"
      echo "  Current run:  ${PASS}/$TOTAL skills ≥${THRESHOLD}%"
      acc_trend=$((PASS - prev_pass))
      if [ "$acc_trend" -gt 0 ]; then
        echo "  Trend: ${GREEN}+${acc_trend} skills improved${NC}"
      elif [ "$acc_trend" -lt 0 ]; then
        echo "  Trend: ${RED}${acc_trend} skills regressed${NC}"
      else
        echo "  Trend: no change"
      fi
    fi

    # Rotate history
    cp "$STATS_FILE" "${STATS_FILE}.prev" 2>/dev/null || true
    ;;
esac

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
