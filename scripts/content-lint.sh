#!/usr/bin/env bash
# content-lint.sh — Mechanical quality gate for generated marketing content
# Scans copy and video output for brand voice, platform rules, persuasion,
# readability, and AI slop violations.
#
# Usage:
#   bash scripts/content-lint.sh --file share-copy.txt    # Check copy output
#   bash scripts/content-lint.sh --file video.mp4         # Check video output
#   bash scripts/content-lint.sh --skill showcase         # Check all showcase output
#   bash scripts/content-lint.sh --list-banned            # Show banned words
#
# Exit codes: 0 = pass, 1 = fail, 2 = warn (check manually)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BANNED_FILE="${BANNED_FILE:-$SCRIPT_DIR/banned-words.txt}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail()  { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }
warn()  { echo -e "  ${YELLOW}⚠${NC} $*"; WARN=$((WARN+1)); }

usage() {
    echo "Usage: bash $0 [--file <path> | --skill <name> | --list-banned]"
    echo ""
    echo "  --file <path>    Check a single file (copy or video)"
    echo "  --skill <name>   Check all output from a skill"
    echo "  --list-banned    Show banned words list"
    exit 1
}

load_banned_words() {
    if [ ! -f "$BANNED_FILE" ]; then
        warn "No banned words file at $BANNED_FILE"
        echo ""
        return
    fi
    grep -v '^#' "$BANNED_FILE" | grep -v '^$' || true
}

check_banned_words() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null) || { fail "Cannot read $file"; return; }

    local found=0
    while IFS= read -r word; do
        [ -z "$word" ] && continue
        if echo "$content" | grep -iq "$word"; then
            fail "Banned word found: '$word'"
            found=$((found+1))
        fi
    done < <(load_banned_words)

    [ "$found" -eq 0 ] && ok "No banned words detected"
}

check_cta_presence() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null) || return

    # CTA patterns: imperative verbs, links, actionable phrases
    local cta_patterns=(
        "get started" "sign up" "try it" "download" "learn more"
        "clone" "install" "github.com" "follow" "subscribe"
        "buy" "order" "register" "join" "share"
    )

    for pattern in "${cta_patterns[@]}"; do
        if echo "$content" | grep -iq "$pattern"; then
            ok "CTA found: '$pattern'"
            return
        fi
    done
    fail "No CTA detected — add a specific call to action"
}

check_platform_limits() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null) || return

    if echo "$content" | grep -q "LinkedIn"; then
        local linkedin_lines
        linkedin_lines=$(echo "$content" | sed -n '/LinkedIn/,/Twitter\|Ad Copy\|^$/p' | wc -l)
        [ "$linkedin_lines" -lt 200 ] && ok "LinkedIn post: reasonable length" || warn "LinkedIn post may be too long ($linkedin_lines lines)"
    fi

    if echo "$content" | grep -q "Twitter"; then
        while IFS= read -r line; do
            local len=${#line}
            [ "$len" -gt 280 ] && warn "Twitter line exceeds 280 chars ($len chars): ${line:0:50}..."
        done < <(echo "$content" | grep -E '^[0-9]+/')
        ok "Twitter thread: line length checked"
    fi

    if echo "$content" | grep -q "Headline"; then
        local headline
        headline=$(echo "$content" | grep "Headline" | head -1)
        local hlen=${#headline}
        [ "$hlen" -le 40 ] && ok "Ad headline: $hlen chars (limit 40)" || warn "Ad headline: $hlen chars (limit 40)"
    fi

    if echo "$content" | grep -q "Body"; then
        local body
        body=$(echo "$content" | grep "Body" | head -1)
        local blen=${#body}
        [ "$blen" -le 125 ] && ok "Ad body: $blen chars (limit 125)" || warn "Ad body: $blen chars (limit 125)"
    fi
}

check_video_duration() {
    local file="$1"
    if ! command -v ffprobe &>/dev/null; then
        warn "ffprobe not found — cannot check video"
        return
    fi

    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$file" 2>/dev/null) || {
        fail "Cannot probe video file"
        return
    }

    local dur_int=${duration%.*}
    if [ "$dur_int" -ge 15 ] && [ "$dur_int" -le 25 ]; then
        ok "Video duration: ${dur_int}s (target 15-25s)"
    elif [ "$dur_int" -lt 15 ]; then
        warn "Video too short: ${dur_int}s (target 15-25s)"
    else
        warn "Video too long: ${dur_int}s (target 15-25s)"
    fi

    local resolution
    resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$file" 2>/dev/null)
    if echo "$resolution" | grep -q "1920"; then
        ok "Video resolution: $resolution"
    else
        warn "Video resolution: $resolution (recommend 1920x1080)"
    fi

    # Check audio presence and quality
    local audio_count
    audio_count=$(ffprobe -v error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$file" 2>/dev/null | grep -c "audio" || true)
    if [ "$audio_count" -gt 0 ]; then
        local audio_info
        audio_info=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels -of csv=p=0 "$file" 2>/dev/null | head -1)
        local audio_bitrate
        audio_bitrate=$(ffprobe -v error -show_entries format=bit_rate -of csv=p=0 "$file" 2>/dev/null | head -1)
        local bitrate_kbps=$((audio_bitrate / 1000))
        ok "Audio present: $audio_info"
        if [ "$bitrate_kbps" -ge 100 ]; then
            ok "Audio bitrate: ${bitrate_kbps}kb/s (quality threshold: 100kb/s)"
        else
            warn "Audio bitrate low: ${bitrate_kbps}kb/s — may be a test tone, consider real music"
        fi
    else
        warn "No audio stream in video — consider adding music or voiceover"
    fi
}

check_scannability() {
    local file="$1"
    local content
    content=$(cat "$file" 2>/dev/null) || return

    # Check for line breaks between paragraphs (scannability)
    local paragraphs
    paragraphs=$(echo "$content" | grep -c '^$')
    if [ "$paragraphs" -ge 3 ]; then
        ok "Content is scannable ($paragraphs paragraph breaks)"
    else
        warn "Low scannability — add paragraph breaks (found $paragraphs)"
    fi
}

check_file() {
    local file="$1"
    echo ""
    echo "  ${CYAN}━━━ Checking: $file${NC}"

    if [ ! -f "$file" ]; then
        fail "File not found: $file"
        return
    fi

    local ext="${file##*.}"

    case "$ext" in
        mp4|mov|webm)
            check_video_duration "$file"
            ;;
        md|txt|jsonl)
            check_banned_words "$file"
            check_cta_presence "$file"
            check_platform_limits "$file"
            check_scannability "$file"
            ;;
        *)
            check_banned_words "$file"
            check_cta_presence "$file"
            ;;
    esac
}

check_skill_output() {
    local skill="$1"
    local output_dir="$PROJECT_ROOT/showcase-output"

    if [ -d "$output_dir" ]; then
        find "$output_dir" -type f | while read -r f; do
            check_file "$f"
        done
    fi

    local share_copy="$PROJECT_ROOT/share-copy.txt"
    [ -f "$share_copy" ] && check_file "$share_copy"
}

list_banned() {
    echo "Banned words (${CYAN}$(load_banned_words | wc -l)${NC} terms):"
    echo ""
    load_banned_words | while IFS= read -r word; do
        echo "  • $word"
    done
}

# ─────────────────────────────────────────
# Main
# ─────────────────────────────────────────

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  CONTENT LINT — Marketing Quality Gate   ║"
echo "╚════════════════════════════════════════════╝"

MODE=""; TARGET=""
while [ $# -gt 0 ]; do
    case "$1" in
        --file) MODE="file"; TARGET="$2"; shift 2 ;;
        --skill) MODE="skill"; TARGET="$2"; shift 2 ;;
        --list-banned) MODE="list-banned"; shift ;;
        *) usage ;;
    esac
done

case "$MODE" in
    file) check_file "$TARGET" ;;
    skill) check_skill_output "$TARGET" ;;
    list-banned) list_banned; exit 0 ;;
    *) echo "  ${YELLOW}No target specified. Use --file, --skill, or --list-banned${NC}"; exit 0 ;;
esac

echo ""
echo "───"
if [ "$FAIL" -gt 0 ]; then
    echo "  ${RED}$FAIL failed, $WARN warnings, $PASS passed${NC}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo "  ${YELLOW}0 failed, $WARN warnings, $PASS passed — review warnings${NC}"
    exit 0
else
    echo "  ${GREEN}All checks passed ($PASS)${NC}"
    exit 0
fi
