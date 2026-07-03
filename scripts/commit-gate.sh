#!/usr/bin/env bash
# commit-gate.sh — Mechanical enforcement at commit time
# BLOCKS commits if interview files exist but have unanswered fields.
# Called by pre-commit hook. Runs on every commit.
# Exit codes: 0 = pass, 1 = fail (incomplete interviews)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
BLOCKED=0

check_interview() {
    local skill_name="$1"
    local interview_file="$REPO_ROOT/$2"
    local label="$3"
    shift 3
    local required_fields=("$@")

    if [ ! -f "$interview_file" ]; then
        return 0  # No interview file = skill was never used
    fi

    local size
    size=$(wc -c < "$interview_file" 2>/dev/null || echo 0)
    if [ "$size" -lt 20 ]; then
        echo "  ${RED}✗${NC} $label: interview file is empty"
        BLOCKED=1
        return
    fi

    local missing=0
    for field in "${required_fields[@]}"; do
        local value
        value=$(python3 -c "import json; f=open('$interview_file'); d=json.load(f); print(d.get('$field',''))" 2>/dev/null || echo "")
        if [ -z "$value" ]; then
            echo "  ${RED}✗${NC} $label: '$field' unanswered in interview"
            missing=$((missing+1))
        fi
    done

    if [ "$missing" -gt 0 ]; then
        echo "  ${YELLOW}  Run: $(dirname "$0")/../scripts/${skill_name}-gate.sh${NC}"
        BLOCKED=1
    fi
}

echo ""
echo "  ${YELLOW}━━━ Interview Gate Check ━━━${NC}"

check_interview "showcase" ".showcase/interview.json" "showcase" format tone duration music voiceover sfx distribute
check_interview "customer-research" ".customer-research/interview.json" "customer-research" goal existing_assets target_segment deliverable
check_interview "social" ".social/interview.json" "social-copy" platforms goal pillars existing_content frequency

if [ "$BLOCKED" -gt 0 ]; then
    echo ""
    echo "  ${RED}✗ $BLOCKED skill(s) have incomplete interviews.${NC}"
    echo "  ${YELLOW}Either complete the interview or remove the interview file.${NC}"
    exit 1
fi
echo "  ${GREEN}✓${NC} All skill interviews verified"
exit 0
