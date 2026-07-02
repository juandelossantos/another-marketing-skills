#!/usr/bin/env bash
# showcase-gate.sh — Mechanical enforcement for showcase interview questions
# BLOCKS generation unless all 7 mandatory questions were answered.
#
# Usage:
#   bash scripts/showcase-gate.sh          # Check all questions answered
#   bash scripts/showcase-gate.sh --save    # Record interview answers (agent runs after Step 2)
#   bash scripts/showcase-gate.sh --show    # Show recorded answers
#
# Exit codes: 0 = pass, 1 = fail (missing answers), 2 = no interview file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INTERVIEW_FILE="$PROJECT_ROOT/.showcase/interview.json"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
PASS=0; FAIL=0

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail()  { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }

REQUIRED_FIELDS=("format" "tone" "duration" "music" "voiceover" "sfx" "distribute")

save_interview() {
    mkdir -p "$PROJECT_ROOT/.showcase"
    cat > "$INTERVIEW_FILE" << 'EOF'
{
  "format": "",
  "tone": "",
  "duration": "",
  "music": "",
  "voiceover": "",
  "sfx": "",
  "distribute": "",
  "recorded_at": ""
}
EOF
    echo "  ${YELLOW}Edit .showcase/interview.json with the user's answers before running the gate.${NC}"
    echo "  Then run: bash scripts/showcase-gate.sh"
}

check_interview() {
    if [ ! -f "$INTERVIEW_FILE" ]; then
        echo "  ${RED}✗ No interview file found.${NC}"
        echo "  ${YELLOW}Run showcase Step 2 first: answer all 7 questions with the user.${NC}"
        echo "  Then run: bash scripts/showcase-gate.sh --save"
        exit 2
    fi

    local missing=0
    for field in "${REQUIRED_FIELDS[@]}"; do
        local value
        value=$(python3 -c "import json; f=open('$INTERVIEW_FILE'); d=json.load(f); print(d.get('$field',''))" 2>/dev/null || echo "")
        if [ -z "$value" ]; then
            fail "Missing answer: $field"
            missing=$((missing+1))
        else
            ok "$field: $value"
        fi
    done

    echo ""
    if [ "$missing" -gt 0 ]; then
        echo "  ${RED}$missing question(s) unanswered. Complete Step 2 before generating.${NC}"
        exit 1
    else
        echo "  ${GREEN}All 7 questions answered. Proceed to generation.${NC}"
        exit 0
    fi
}

show_answers() {
    if [ ! -f "$INTERVIEW_FILE" ]; then
        echo "  ${YELLOW}No interview file found.${NC}"
        exit 2
    fi
    echo "Recorded interview answers:"
    echo ""
    python3 -m json.tool "$INTERVIEW_FILE" 2>/dev/null || cat "$INTERVIEW_FILE"
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  SHOWCASE GATE — Interview Enforcement    ║"
echo "╚════════════════════════════════════════════╝"

MODE="check"
while [ $# -gt 0 ]; do
    case "$1" in
        --save) MODE="save"; shift ;;
        --show) MODE="show"; shift ;;
        *) MODE="check"; shift ;;
    esac
done

case "$MODE" in
    save) save_interview ;;
    show) show_answers ;;
    check) check_interview ;;
esac
