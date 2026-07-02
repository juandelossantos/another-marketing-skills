#!/usr/bin/env bash
# voice-lint.sh — Brand voice compliance checker
# Reads `.agents/product-marketing.md` Section 10 (Brand Voice) and checks
# generated output against voice dimensions, vocabulary guardrails, and
# banned words.
#
# Usage:
#   bash scripts/voice-lint.sh --file share-copy.txt
#   bash scripts/voice-lint.sh --skill showcase
#
# Exit codes: 0 = pass, 1 = fail, 2 = no context file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTEXT_FILE="$PROJECT_ROOT/.agents/product-marketing.md"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail()  { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }
warn()  { echo -e "  ${YELLOW}⚠${NC} $*"; WARN=$((WARN+1)); }

usage() {
    echo "Usage: bash $0 --file <path>"
    echo "  --file <path>    Check a file against brand voice"
    echo "  --skill <name>   Check all output from a skill"
    exit 1
}

extract_voice_dimensions() {
    # Extract Brand Voice section from context file
    if [ ! -f "$CONTEXT_FILE" ]; then
        echo ""
        return
    fi

    # Extract tone, style, personality, words to use/avoid
    local in_voice=0
    while IFS= read -r line; do
        if echo "$line" | grep -q "^## Brand Voice"; then
            in_voice=1
            continue
        fi
        if [ "$in_voice" -eq 1 ] && echo "$line" | grep -q "^## "; then
            break
        fi
        [ "$in_voice" -eq 1 ] && echo "$line"
    done < "$CONTEXT_FILE"
}

check_voice_compliance() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null) || { fail "Cannot read $file"; return; }

    # Extract brand voice from context
    local tone style personality
    tone=$(extract_voice_dimensions | grep -i "tone" | head -1 | sed 's/.*: *//' | sed 's/\*//g')
    style=$(extract_voice_dimensions | grep -i "style" | head -1 | sed 's/.*: *//' | sed 's/\*//g')
    personality=$(extract_voice_dimensions | grep -i "personality" | head -1 | sed 's/.*: *//' | sed 's/\*//g')

    if [ -z "$tone" ] && [ -z "$style" ]; then
        warn "Brand Voice section incomplete in $CONTEXT_FILE"
        warn "Add tone, style, and personality to enable voice compliance checks"
        return
    fi

    [ -n "$tone" ] && ok "Brand tone: $tone"
    [ -n "$style" ] && ok "Brand style: $style"

    # Check words to avoid from context
    local in_avoid=0
    while IFS= read -r line; do
        if echo "$line" | grep -qi "words to avoid"; then
            in_avoid=1
            continue
        fi
        if [ "$in_avoid" -eq 1 ] && echo "$line" | grep -qE "^\|"; then
            # Table row — extract words
            local avoid_word
            avoid_word=$(echo "$line" | sed 's/.*| *//' | sed 's/ *|.*//' | tr ',' '\n' | sed 's/^ *//')
            if echo "$content" | grep -qi "$avoid_word"; then
                fail "Voice violation: '$avoid_word' is in words-to-avoid list"
            fi
        fi
        [ "$in_avoid" -eq 1 ] && echo "$line" | grep -q "^##" && in_avoid=0
    done < "$CONTEXT_FILE"

    # Check personality adjectives are reflected in content
    if [ -n "$personality" ]; then
        local adj
        adj=$(echo "$personality" | grep -oE '[a-z]+' | head -1)
        if [ -n "$adj" ] && echo "$content" | grep -qi "$adj"; then
            ok "Content reflects brand personality: '$adj'"
        fi
    fi
}

check_file() {
    local file="$1"
    echo ""
    echo "  ${CYAN}━━━ Voice check: $file${NC}"

    if [ ! -f "$file" ]; then
        fail "File not found: $file"
        return
    fi

    check_voice_compliance "$file"
}

check_skill_output() {
    local skill="$1"
    local output_dir="$PROJECT_ROOT/showcase-output"
    [ -d "$output_dir" ] && find "$output_dir" -type f | while read -r f; do check_file "$f"; done
    local share_copy="$PROJECT_ROOT/share-copy.txt"
    [ -f "$share_copy" ] && check_file "$share_copy"
}

# ─────────────────────────────────────────
# Main
# ─────────────────────────────────────────

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  VOICE LINT — Brand Voice Compliance     ║"
echo "╚════════════════════════════════════════════╝"

if [ ! -f "$CONTEXT_FILE" ]; then
    echo "  ${YELLOW}No product-marketing context found.${NC}"
    echo "  Run the product-marketing skill first to create .agents/product-marketing.md"
    exit 2
fi
info "Context: $CONTEXT_FILE"
echo "  $(head -3 "$CONTEXT_FILE" | grep -E "^## Product|^\*\*One-liner" | tr -d '\n')"
echo ""

MODE=""; TARGET=""
while [ $# -gt 0 ]; do
    case "$1" in
        --file) MODE="file"; TARGET="$2"; shift 2 ;;
        --skill) MODE="skill"; TARGET="$2"; shift 2 ;;
        *) usage ;;
    esac
done

case "$MODE" in
    file) check_file "$TARGET" ;;
    skill) check_skill_output "$TARGET" ;;
    *) echo "  ${YELLOW}No target specified${NC}"; exit 0 ;;
esac

echo ""
echo "───"
if [ "$FAIL" -gt 0 ]; then
    echo "  ${RED}$FAIL failed, $WARN warnings, $PASS passed${NC}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo "  ${YELLOW}0 failed, $WARN warnings, $PASS passed${NC}"
    exit 0
else
    echo "  ${GREEN}All voice checks passed ($PASS)${NC}"
    exit 0
fi
