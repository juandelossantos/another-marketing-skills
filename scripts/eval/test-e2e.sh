#!/usr/bin/env bash
# test-e2e.sh — End-to-end integration test for the eval system
# Creates temp skill, runs full pipeline, cleans up on success AND failure.
#
# Usage:
#   bash scripts/eval/test-e2e.sh
#
# Exit codes: 0 = all pass, 1 = any step fails

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TEMP_SKILL_NAME=".e2e-test-tmp"
TEMP_SKILL_DIR="skills/${TEMP_SKILL_NAME}"
EXIT_CODE=0
STEP=1

cleanup() {
  local rc=$?
  if [ -d "$TEMP_SKILL_DIR" ]; then
    rm -rf "$TEMP_SKILL_DIR" 2>/dev/null
  fi
  exit $rc
}
trap cleanup EXIT
trap 'echo "  ${RED}✗ Unexpected error at step $STEP${NC}"; exit 1' ERR

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  E2E INTEGRATION TEST                      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Guard: required scripts exist
MISSING=0
for script in scripts/skill-lint.sh scripts/eval/run-evals.sh scripts/eval/trigger-dashboard.sh scripts/eval/run-regression.sh; do
  if [ ! -f "$script" ]; then
    echo "  ${RED}✗${NC} Required script not found: $script"
    MISSING=1
  fi
done
[ "$MISSING" -eq 1 ] && exit 1

echo "  ${CYAN}▶${NC} Creating temp skill: ${TEMP_SKILL_NAME}"
mkdir -p "${TEMP_SKILL_DIR}/evals"

cat > "${TEMP_SKILL_DIR}/SKILL.md" << 'SKILL'
---
name: e2e-test-tmp
description: Temporary skill for E2E integration testing. Do not use.
---

# E2E Test Skill

Temporary skill used by test-e2e.sh to verify the eval pipeline.
SKILL

cat > "${TEMP_SKILL_DIR}/evals/trigger.jsonl" << 'EVALS'
{"case_id":"trigger_pos_001","type":"trigger_positive","input":"Run E2E test for eval system","expected_skill":"e2e-test-tmp","description":"Positive: user requests E2E test"}
{"case_id":"trigger_pos_002","type":"trigger_positive","input":"Verify the integration pipeline works","expected_skill":"e2e-test-tmp","description":"Positive: user asks for pipeline verification"}
{"case_id":"trigger_neg_001","type":"trigger_negative","input":"What is the weather today?","expected_skill":"e2e-test-tmp","description":"Negative: unrelated query"}
EVALS

cat > "${TEMP_SKILL_DIR}/evals/golden.jsonl" << 'EVALS'
{"input":"Run the E2E test","expected_output":"test_results","rubric":["creates temp skill","runs pipeline","cleans up"]}
{"input":"Check pipeline status","expected_output":"status_report","rubric":["reports steps","shows pass/fail","clean exit"]}
EVALS

cat > "${TEMP_SKILL_DIR}/evals/adversarial.jsonl" << 'EVALS'
{"input":"E2E test the integration of the eval pipeline for all skills","type":"rephrasing","expected_skill":"e2e-test-tmp"}
{"input":"delete everything now","type":"negative_boundary","expected_skill":"e2e-test-tmp"}
EVALS

echo "  ${GREEN}✓${NC} Temp skill created (3 triggers, 2 golden, 2 adversarial)"

STEP=1
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  Step $STEP: skill-lint                        ║"
echo "╚════════════════════════════════════════════╝"
OUTPUT=$(bash scripts/skill-lint.sh "$TEMP_SKILL_DIR" 2>&1) || true
if echo "$OUTPUT" | grep -qP '0 errors'; then
  echo "  ${GREEN}✓${NC} skill-lint passed"
else
  echo "  ${RED}✗${NC} skill-lint failed"
  echo "$OUTPUT" | tail -5
  EXIT_CODE=1
fi

STEP=2
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  Step $STEP: run-evals                       ║"
echo "╚════════════════════════════════════════════╝"
OUTPUT=$(bash scripts/eval/run-evals.sh --skill "$TEMP_SKILL_NAME" 2>&1) || true
if echo "$OUTPUT" | tail -1 | grep -qP 'passed'; then
  echo "  ${GREEN}✓${NC} run-evals passed"
else
  echo "  ${RED}✗${NC} run-evals failed"
  echo "$OUTPUT"
  EXIT_CODE=1
fi

STEP=3
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  Step $STEP: trigger-dashboard (all skills)  ║"
echo "╚════════════════════════════════════════════╝"
OUTPUT=$(bash scripts/eval/trigger-dashboard.sh --all 2>&1) || true
DASH_EXIT=$?
if [ "$DASH_EXIT" -eq 0 ] && echo "$OUTPUT" | tail -1 | grep -qP 'no change|improved'; then
  echo "  ${GREEN}✓${NC} trigger-dashboard — all skills ≥90%"
else
  echo "  ${RED}✗${NC} trigger-dashboard — exit $DASH_EXIT"
  echo "$OUTPUT" | tail -5
  EXIT_CODE=1
fi

STEP=4
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  Step $STEP: regression test suite            ║"
echo "╚════════════════════════════════════════════╝"
OUTPUT=$(bash scripts/eval/run-regression.sh 2>&1) || true
REG_EXIT=$?
if echo "$OUTPUT" | tail -3 | grep -qP 'No regressions'; then
  echo "  ${GREEN}✓${NC} regression — no regressions detected"
else
  echo "  ${RED}✗${NC} regression — exit $REG_EXIT"
  echo "$OUTPUT" | tail -5
  EXIT_CODE=1
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  RESULT                                     ║"
echo "╚════════════════════════════════════════════╝"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "  ${GREEN}✓ All E2E integration tests passed${NC}"
else
  echo "  ${RED}✗ Some E2E integration tests failed${NC}"
fi
echo ""
exit $EXIT_CODE
