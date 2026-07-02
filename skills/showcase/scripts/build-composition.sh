#!/usr/bin/env bash
# build-composition.sh — Generate a Hyperframes video composition from a storyboard
# Usage:
#   bash scripts/build-composition.sh <output-dir> [--template <template>] [--title <text>]
#
# Copies the template, creates assets/, writes index.html, and renders.
# Requires: npx hyperframes lint + render

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$SKILL_DIR/assets/templates/promo-16-9.html"
OUTPUT_DIR="${1:-showcase-output}"

echo "╔════════════════════════════════════════════╗"
echo "║  BUILD COMPOSITION                        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

mkdir -p "$OUTPUT_DIR/composition/assets"

# Copy template
cp "$TEMPLATE" "$OUTPUT_DIR/composition/index.html"
echo "  ✓ Template: promo-16-9.html"

# Copy any music assets
if [ -d "$SKILL_DIR/assets/music" ]; then
    cp "$SKILL_DIR/assets/music/"*.wav "$OUTPUT_DIR/composition/assets/" 2>/dev/null || true
    echo "  ✓ Music bundled"
fi

echo "  ────────────────"
echo "  Output: $OUTPUT_DIR/"
echo "  Next:"
echo "    npx hyperframes lint $OUTPUT_DIR/composition"
echo "    npx hyperframes render $OUTPUT_DIR/composition --out $OUTPUT_DIR/video.mp4"
