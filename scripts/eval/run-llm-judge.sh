#!/usr/bin/env bash
# run-llm-judge.sh — LLM-as-Judge evaluation pattern
# Uses a peer model to evaluate skill output quality against a rubric.
# Generates structured judge prompts with position swapping.
#
# Usage:
#   bash scripts/eval/run-llm-judge.sh --skill <name> --case <case_id>
#   bash scripts/eval/run-llm-judge.sh --input <file> --rubric <file>
#   bash scripts/eval/run-llm-judge.sh --help
#
# Position swapping: runs with rubric criteria in order A->B and B->A,
# averages scores to eliminate ordering bias (per whitepaper §4).

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILLS_DIR="${SKILLS_DIR:-skills}"

usage() {
  echo "Usage:"
  echo "  $0 --skill <name> --case <case_id>   # From golden.jsonl"
  echo "  $0 --input <file> --rubric <file>    # Raw files"
  echo "  $0 --help                            # This message"
  echo ""
  echo "Outputs a structured judge prompt ready for LLM evaluation."
  echo "Run twice automatically with swapped rubric order (A→B and B→A)."
  exit 0
}

MODE=""; SKILL=""; CASE_ID=""; INPUT_FILE=""; RUBRIC_FILE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --skill) MODE="skill"; SKILL="$2"; shift 2 ;;
    --case) CASE_ID="$2"; shift 2 ;;
    --input) MODE="raw"; INPUT_FILE="$2"; shift 2 ;;
    --rubric) RUBRIC_FILE="$2"; shift 2 ;;
    --help) usage ;;
    *) echo "Unknown: $1"; usage ;;
  esac
done

# ── Extract data ──────────────────────────────────────────

INPUT_TEXT=""
RUBRIC_ITEMS=()

if [ "$MODE" = "skill" ]; then
  [ -z "$SKILL" ] && { echo "Error: --skill required"; exit 1; }
  [ -z "$CASE_ID" ] && { echo "Error: --case required"; exit 1; }

  GOLDEN_FILE="$SKILLS_DIR/$SKILL/evals/golden.jsonl"
  [ ! -f "$GOLDEN_FILE" ] && { echo "Error: $GOLDEN_FILE not found"; exit 1; }

  # Find the case
  CASE_DATA=$(jq -r --arg cid "$CASE_ID" 'select(.case_id == $cid)' "$GOLDEN_FILE" 2>/dev/null || true)
  if [ -z "$CASE_DATA" ]; then
    echo "Error: case '$CASE_ID' not found in $GOLDEN_FILE"
    echo "Available cases:"
    jq -r '.case_id' "$GOLDEN_FILE" 2>/dev/null
    exit 1
  fi

  INPUT_TEXT=$(echo "$CASE_DATA" | jq -r '.input')
  readarray -t RUBRIC_ITEMS < <(echo "$CASE_DATA" | jq -r '.rubric[]')
  SKILL_DESC=$(head -20 "$SKILLS_DIR/$SKILL/SKILL.md" | grep "^description:" | sed 's/^description: *//')

elif [ "$MODE" = "raw" ]; then
  [ -z "$INPUT_FILE" ] && { echo "Error: --input required"; exit 1; }
  [ -z "$RUBRIC_FILE" ] && { echo "Error: --rubric required"; exit 1; }
  [ ! -f "$INPUT_FILE" ] && { echo "Error: $INPUT_FILE not found"; exit 1; }
  [ ! -f "$RUBRIC_FILE" ] && { echo "Error: $RUBRIC_FILE not found"; exit 1; }
  INPUT_TEXT=$(cat "$INPUT_FILE")
  readarray -t RUBRIC_ITEMS < "$RUBRIC_FILE"
  SKILL_DESC="(provided directly)"
else
  usage
fi

# ── Generate judge prompt ────────────────────────────────

generate_prompt() {
  local order_desc="$1"  # "original" or "reversed"
  local rubric_order=()
  local rubric_nums=()

  if [ "$order_desc" = "original" ]; then
    for i in "${!RUBRIC_ITEMS[@]}"; do
      rubric_order[$i]="${RUBRIC_ITEMS[$i]}"
      rubric_nums[$i]=$((i + 1))
    done
  else
    # Reversed
    local last=$((${#RUBRIC_ITEMS[@]} - 1))
    for i in "${!RUBRIC_ITEMS[@]}"; do
      rubric_order[$i]="${RUBRIC_ITEMS[$last - $i]}"
      rubric_nums[$i]=$((last - i + 1))
    done
  fi

  cat << PROMPT
## Evaluation Task

You are evaluating the output of an AI agent skill against quality criteria.

### Skill Context
${SKILL_DESC}

### Input Provided to the Skill
${INPUT_TEXT}

### Evaluation Criteria (${order_desc} order)
$(for i in "${!rubric_order[@]}"; do echo "${rubric_nums[$i]}. ${rubric_order[$i]}"; done)

### Instructions
For each criterion, score 0-5:
- 0: Not addressed at all
- 1: Minimal mention, incorrect
- 2: Partially addressed, major gaps
- 3: Adequately addressed, minor gaps
- 4: Well addressed, meets expectations
- 5: Fully addressed, exceeds expectations

### Output Format
Return a JSON object with scores and brief justifications:
{
  "scores": [
    {"criterion": "...", "score": 0, "justification": "..."}
  ],
  "overall": 0,
  "strengths": ["..."],
  "weaknesses": ["..."]
}
PROMPT
}

# ── Generate both orders ─────────────────────────────────

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  LLM-as-JUDGE — Output Quality Evaluation            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "  ${CYAN}Skill:${NC} $SKILL"
echo "  ${CYAN}Case:${NC} ${CASE_ID:-"(direct input)"}"
echo "  ${CYAN}Rubric criteria:${NC} ${#RUBRIC_ITEMS[@]}"
echo ""

JUDGE_DIR=".judge-results"
mkdir -p "$JUDGE_DIR"
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)

# Order A
echo "  ${YELLOW}━━━ Order A (original) ━━━${NC}"
generate_prompt "original" > "$JUDGE_DIR/${TIMESTAMP}_orderA_prompt.txt"
echo "  Prompt saved to: $JUDGE_DIR/${TIMESTAMP}_orderA_prompt.txt"
echo "  ${GREEN}✓${NC} Rubric order: ${RUBRIC_ITEMS[*]}"
echo ""

# Order B (swapped)
echo "  ${YELLOW}━━━ Order B (swapped) ━━━${NC}"
generate_prompt "reversed" > "$JUDGE_DIR/${TIMESTAMP}_orderB_prompt.txt"
echo "  Prompt saved to: $JUDGE_DIR/${TIMESTAMP}_orderB_prompt.txt"
echo "  ${GREEN}✓${NC} Rubric order: "
for i in "${!RUBRIC_ITEMS[@]}"; do
  rev_idx=$((${#RUBRIC_ITEMS[@]} - 1 - i))
  echo "    ${i}. ${RUBRIC_ITEMS[$rev_idx]}"
done
echo ""

echo "  ${CYAN}━━━ Usage ━━━${NC}"
echo "  Pipe each prompt to your LLM:"
echo "  \$ cat $JUDGE_DIR/${TIMESTAMP}_orderA_prompt.txt | your-llm-cli"
echo "  \$ cat $JUDGE_DIR/${TIMESTAMP}_orderB_prompt.txt | your-llm-cli"
echo ""
echo "  Then average scores from both runs to eliminate ordering bias."
echo "  Update EVAL-GUIDE.md with results."
