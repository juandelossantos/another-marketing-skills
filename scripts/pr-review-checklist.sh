#!/usr/bin/env bash
# pr-review-checklist.sh — Pre-Merge Mechanical Review Gate
# BLOCKING. Run BEFORE any PR merge, squash, or rebase-merge.
# Source: code-review-and-quality + Rule 12 mutation approval
#
# Usage: bash scripts/pr-review-checklist.sh <PR_NUMBER>
#
# Requires: gh CLI, git
# Exit codes: 0 = passed, 1 = blocked, 2 = warnings

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PR_NUMBER="${1:-}"
REPO_ROOT=$(git rev-parse --show-toplevel)
PR_APPROVAL="${REPO_ROOT}/.git/PR_APPROVAL"

PASS=0
WARN=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "ok" ]; then
        echo -e "  ${GREEN}✓${NC} $label"
        PASS=$((PASS + 1))
    elif [ "$result" = "warn" ]; then
        echo -e "  ${YELLOW}⚠${NC} $label"
        WARN=$((WARN + 1))
    else
        echo -e "  ${RED}✗${NC} $label"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  PR REVIEW CHECKLIST — MECHANICAL GATE              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

if [ -z "$PR_NUMBER" ]; then
    echo "${RED}Error: PR number required${NC}"
    echo "Usage: bash scripts/pr-review-checklist.sh <PR_NUMBER>"
    exit 1
fi

# ============================================================
# GATE 1: PR State Verification
# ============================================================
echo "1. PR State Verification"
echo "─────────────────────────────────────────"

PR_STATE=$(gh pr view "$PR_NUMBER" --json state --jq '.state' 2>/dev/null || echo "UNKNOWN")
if [ "$PR_STATE" = "OPEN" ]; then
    check "PR is OPEN" "ok"
elif [ "$PR_STATE" = "MERGED" ]; then
    check "PR is MERGED (skipped mechanical gate - ALREADY MERGED)" "warn"
elif [ "$PR_STATE" = "CLOSED" ]; then
    check "PR is CLOSED" "warn"
else
    check "PR is OPEN (found: $PR_STATE)" "fail"
fi

PR_MERGEABLE=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable' 2>/dev/null || echo "UNKNOWN")
if [ "$PR_STATE" = "MERGED" ] || [ "$PR_STATE" = "CLOSED" ]; then
    check "PR mergeable check (skipped for $PR_STATE)" "warn"
elif [ "$PR_MERGEABLE" = "MERGEABLE" ]; then
    check "PR is mergeable" "ok"
else
    check "PR is mergeable (found: $PR_MERGEABLE)" "fail"
fi

PR_REVIEWS=$(gh pr view "$PR_NUMBER" --json reviews --jq '.reviews | length' 2>/dev/null || echo "0")
if [ "$PR_REVIEWS" -gt 0 ]; then
    check "PR has $PR_REVIEWS review(s)" "ok"
else
    check "PR has reviews (found: $PR_REVIEWS)" "warn"
fi

# ============================================================
# GATE 2: Diff Size Check
# ============================================================
echo ""
echo "2. Diff Size Check"
echo "─────────────────────────────────────────"

PR_CHANGES=$(gh pr view "$PR_NUMBER" --json files --jq '.files | length' 2>/dev/null || echo "UNKNOWN")
if [ "$PR_CHANGES" != "UNKNOWN" ] && [ "$PR_CHANGES" -le 50 ]; then
    check "Files changed: $PR_CHANGES (≤50)" "ok"
elif [ "$PR_CHANGES" != "UNKNOWN" ] && [ "$PR_CHANGES" -le 100 ]; then
    check "Files changed: $PR_CHANGES (≤100, acceptable)" "warn"
else
    check "Files changed: $PR_CHANGES (>100, too large)" "fail"
fi

PR_ADDITIONS=$(gh pr view "$PR_NUMBER" --json additions --jq '.additions' 2>/dev/null || echo "0")
PR_DELETIONS=$(gh pr view "$PR_NUMBER" --json deletions --jq '.deletions' 2>/dev/null || echo "0")
check "Lines added: $PR_ADDITIONS" "ok"
check "Lines deleted: $PR_DELETIONS" "ok"

# ============================================================
# GATE 3: Changed Files Scan
# ============================================================
echo ""
echo "3. Changed Files Scan"
echo "─────────────────────────────────────────"

PR_FILES=$(gh pr view "$PR_NUMBER" --json files --jq '.files.[].path' 2>/dev/null || echo "")

# Check for secrets
SECRETS_FOUND=0
for file in $PR_FILES; do
    case "$file" in
        *.env|*.pem|*.key|*.pem|credentials|*.secret) SECRETS_FOUND=1 ;;
    esac
done
if [ "$SECRETS_FOUND" -eq 0 ]; then
    check "No secret files in diff" "ok"
else
    check "No secret files in diff" "fail"
fi

# Check for test files if code changed
HAS_CODE=0
HAS_TESTS=0
for file in $PR_FILES; do
    case "$file" in
        *.ts|*.js|*.py|*.go|*.java) HAS_CODE=1 ;;
        *_test.go|*_test.ts|*.spec.ts|*.test.ts|test_*.py|tests/*.py) HAS_TESTS=1 ;;
    esac
done
if [ "$HAS_CODE" -eq 1 ]; then
    if [ "$HAS_TESTS" -eq 1 ]; then
        check "Code changed WITH tests" "ok"
    else
        check "Code changed WITHOUT tests" "warn"
    fi
else
    check "No code files changed" "ok"
fi

# Check for skill files compliance
SKILLS_OK=1
for file in $PR_FILES; do
    if [[ "$file" == skills/*/SKILL.md ]]; then
        LINES=$(wc -l < "$file" 2>/dev/null || echo "999")
        if [ "$LINES" -gt 250 ]; then
            echo -e "  ${RED}✗${NC} $file exceeds 250 lines ($LINES)"
            SKILLS_OK=0
        fi
    fi
done
if [ "$SKILLS_OK" -eq 1 ]; then
    check "All SKILL.md files ≤250 lines" "ok"
else
    check "All SKILL.md files ≤250 lines" "fail"
fi

# ============================================================
# GATE 4: Hook Compliance
# ============================================================
echo ""
echo "4. Hook Compliance"
echo "─────────────────────────────────────────"

HOOKS_OK=1
for file in $PR_FILES; do
    case "$file" in
        scripts/git-hooks/pre-commit)
            if ! grep -q "ESCAPE_HATCH\|OVERRIDE" "$file" 2>/dev/null; then
                echo -e "  ${RED}✗${NC} $file missing escape hatch"
                HOOKS_OK=0
            fi
            if ! grep -q "COMMIT_APPROVED" "$file" 2>/dev/null; then
                echo -e "  ${RED}✗${NC} $file missing COMMIT_APPROVED"
                HOOKS_OK=0
            fi
            ;;
        scripts/git-hooks/commit-msg)
            if ! grep -q "sha256" "$file" 2>/dev/null; then
                echo -e "  ${RED}✗${NC} $file missing hash verification"
                HOOKS_OK=0
            fi
            ;;
    esac
done
if [ "$HOOKS_OK" -eq 1 ]; then
    check "Hooks have escape hatch and hash verification" "ok"
else
    check "Hooks have escape hatch and hash verification" "fail"
fi

# ============================================================
# GATE 5: Commit Coherence
# ============================================================
echo ""
echo "5. Commit Coherence"
echo "─────────────────────────────────────────"

PR_COMMITS=$(gh pr view "$PR_NUMBER" --json commits --jq '.commits[].messageHeadline' 2>/dev/null || echo "")
COMMIT_COUNT=$(echo "$PR_COMMITS" | wc -l)
check "Commits in PR: $COMMIT_COUNT" "ok"

# Check commit messages are descriptive
BAD_COMMITS=0
for msg in $PR_COMMITS; do
    case "$msg" in
        "fix bug"|"update"|"fix"|"changes") BAD_COMMITS=1 ;;
    esac
done
if [ "$BAD_COMMITS" -eq 0 ]; then
    check "Commit messages are descriptive" "ok"
else
    check "Commit messages are descriptive" "warn"
fi

# ============================================================
# GATE 6: PR Description Quality
# ============================================================
echo ""
echo "6. PR Description Quality"
echo "─────────────────────────────────────────"

PR_BODY=$(gh pr view "$PR_NUMBER" --json body --jq '.body' 2>/dev/null || echo "")
if [ ${#PR_BODY} -gt 100 ]; then
    check "PR description is detailed (>100 chars)" "ok"
else
    check "PR description is detailed (>100 chars)" "warn"
fi

if echo "$PR_BODY" | grep -qi "test\|verify"; then
    check "PR description mentions testing/verification" "ok"
else
    check "PR description mentions testing/verification" "warn"
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "════════════════════════════════════════════════════════"
echo "  SUMMARY"
echo "════════════════════════════════════════════════════════"
echo ""
echo -e "  ${GREEN}✓${NC} Passed:  $PASS"
echo -e "  ${YELLOW}⚠${NC} Warnings: $WARN"
echo -e "  ${RED}✗${NC} Failed:  $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  BLOCKED: PR has critical issues. Fix before merge.  ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  WARNING: PR has issues. Review carefully before merge.║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 2
else
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  PASSED: All mechanical checks passed.               ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║  Manual review still required for correctness.        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
fi
