#!/usr/bin/env bash
# seo-gate.sh — Mechanical enforcement for seo-foundation
# BLOCKS generation unless user context questions answered.
# Usage: bash scripts/seo-gate.sh [--save|--show]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INTERVIEW_FILE="$PROJECT_ROOT/.seo/interview.json"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; FAIL=0
ok() { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }
REQUIRED_FIELDS=("url" "topic" "audience" "pillars")

save_interview() {
    mkdir -p "$PROJECT_ROOT/.seo"
    cat > "$INTERVIEW_FILE" << 'EOF'
{"url":"","topic":"","audience":"","pillars":"","recorded_at":""}
EOF
    echo "  ${YELLOW}Edit .seo/interview.json with answers, then run: bash scripts/seo-gate.sh${NC}"
}

check_interview() {
    if [ ! -f "$INTERVIEW_FILE" ]; then echo "  ${RED}✗ No interview. Run: bash scripts/seo-gate.sh --save${NC}"; exit 2; fi
    local m=0
    for f in "${REQUIRED_FIELDS[@]}"; do
        local v=$(python3 -c "import json;print(json.load(open('$INTERVIEW_FILE')).get('$f',''))" 2>/dev/null)
        [ -z "$v" ] && fail "Missing: $f" && m=$((m+1)) || ok "$f: $v"
    done
    [ "$m" -gt 0 ] && echo -e "\n  ${RED}$m unanswered.${NC}" && exit 1
    echo -e "\n  ${GREEN}All answered. Proceed.${NC}" && exit 0
}

echo -e "\n╔════════════════════════════════════════════╗\n║  SEO GATE — User Context Enforcement    ║\n╚════════════════════════════════════════════╝"
case "${1:-check}" in --save) save_interview;; --show) [ -f "$INTERVIEW_FILE" ] && python3 -m json.tool "$INTERVIEW_FILE" || echo "No interview";; *) check_interview;; esac
