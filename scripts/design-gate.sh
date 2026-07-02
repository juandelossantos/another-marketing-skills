#!/usr/bin/env bash
# design-gate — Verifies design process compliance before visual work.
# Prevents the "skip the skill" anti-pattern by blocking design/visual
# edits (web, mobile, desktop, or any UI) unless DESIGN.md, DESIGN-LOCK.md,
# and a skill marker exist.
#
# Part of the Another Agent Skills integrity system.
# Invoked by AGENTS.md Rule 0d Step 3.
#
# Bypass: Not possible. If this blocks, do the design process properly.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

DESIGN_MD="$REPO_ROOT/DESIGN.md"
DESIGN_LOCK="$REPO_ROOT/design/DESIGN-LOCK.md"
SKILL_MARKER="$REPO_ROOT/.opencode/.design-skill-loaded"
SPEC_MD="$REPO_ROOT/SPEC.md"

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  DESIGN GATE                               ║"
echo "╚════════════════════════════════════════════╝"

PASS=true

if [ ! -f "$DESIGN_MD" ]; then
  echo "  ✗ DESIGN.md missing — no visual contract exists."
  echo "    → Load a design direction skill (e.g., minimalist-ui) to create one."
  PASS=false
else
  echo "  ✓ DESIGN.md — visual contract exists"
fi

if [ ! -f "$DESIGN_LOCK" ]; then
  echo "  ✗ design/DESIGN-LOCK.md missing — no approved design snapshot."
  echo "    → Create design/ directory with locked tokens after user approval."
  PASS=false
else
  echo "  ✓ design/DESIGN-LOCK.md — approved snapshot exists"
fi

if [ ! -f "$SKILL_MARKER" ]; then
  echo "  ✗ No design skill marker — no direction skill was loaded."
  echo "    → Load a visual skill (minimalist-ui, industrial-brutalist-ui, etc.) before working on visual files."
  PASS=false
else
  echo "  ✓ Design skill marker found — direction skill was loaded"
fi

if [ ! -f "$SPEC_MD" ]; then
  echo "  ✗ SPEC.md missing — no specification for this work."
  echo "    → Run spec-driven-development first."
  PASS=false
else
  echo "  ✓ SPEC.md — specification exists"
fi

echo ""
if [ "$PASS" = true ]; then
  echo "  ✓ DESIGN GATE PASSED — proceeding with visual work."
else
  echo "  ┌────────────────────────────────────────────────────────────┐"
  echo "  │  DESIGN GATE BLOCKED                                       │"
  echo "  │                                                            │"
  echo "  │  Visual work was attempted without completing the design    │"
  echo "  │  process. Run the missing steps above before creating or    │"
  echo "  │  modifying any HTML, CSS, or visual asset.                  │"
  echo "  │                                                            │"
  echo "  │  Required order:                                            │"
  echo "  │    1. Load a design direction skill                         │"
  echo "  │    2. spec-driven-development → SPEC.md                     │"
  echo "  │    3. Phase 1 Discovery (visual direction questions)        │"
  echo "  │    4. DESIGN.md (visual tokens only)                        │"
  echo "  │    5. Create design/DESIGN-LOCK.md with approved snapshot    │"
  echo "  │    6. planning-and-task-breakdown                           │"
  echo "  │    7. Build with tokens from DESIGN-LOCK.md                 │"
  echo "  └────────────────────────────────────────────────────────────┘"
  exit 1
fi
