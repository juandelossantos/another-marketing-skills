#!/usr/bin/env bash
# install.sh — Another Marketing Skills installer (Linux/macOS)
# Creates symlinks for agent discovery. Works from any clone location.
#
# Usage:
#   bash install.sh                        # Detect agent, create symlinks
#   bash install.sh --agent opencode       # Force OpenCode mode
#   bash install.sh --agent claude         # Force Claude Code mode
#   bash install.sh --agent codex          # Force Codex CLI mode
#   bash install.sh --agent all            # Create all agent symlinks
#   bash install.sh --list                 # List installed symlinks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

AGENT_MODE="auto"

usage() {
    echo "Usage: bash install.sh [--agent opencode|claude|codex|all] [--list]"
    echo ""
    echo "  --agent <type>   Force agent type (default: auto-detect)"
    echo "  --list           List installed symlinks"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --agent) AGENT_MODE="$2"; shift 2 ;;
        --list) AGENT_MODE="list"; shift ;;
        *) usage ;;
    esac
done

detect_agent() {
    # Check for common agent config files in the project
    if [ -f "$SCRIPT_DIR/.opencode/AGENTS.md" ] || [ -d "$SCRIPT_DIR/.opencode/skills" ]; then
        echo "opencode"
    elif [ -f "$SCRIPT_DIR/.claude/settings.json" ] || [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
        echo "claude"
    elif [ -d "$SCRIPT_DIR/.cursor" ] || [ -f "$SCRIPT_DIR/.cursorrules" ]; then
        echo "cursor"
    else
        echo "universal"
    fi
}

create_symlink() {
    local target="$1"
    local link_name="$2"
    local dir
    dir="$(dirname "$link_name")"

    mkdir -p "$dir"

    if [ -L "$link_name" ]; then
        local current
        current="$(readlink "$link_name")"
        if [ "$current" = "$target" ]; then
            ok "Symlink exists: $link_name → $target"
            return 0
        fi
        warn "Replacing symlink: $link_name (was → $current, now → $target)"
        rm "$link_name"
    elif [ -e "$link_name" ]; then
        local backup="${link_name}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up: $link_name → $backup"
        mv "$link_name" "$backup"
    fi

    ln -s "$target" "$link_name"
    ok "Created: $link_name → $target"
}

install_skill_symlinks() {
    local agent_dir="$1"

    for skill_dir in "$SKILLS_SOURCE"/*/; do
        [ ! -d "$skill_dir" ] && continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        [ ! -f "${skill_dir}SKILL.md" ] && continue

        # Relative path from agent_dir to skills source
        local rel_path
        rel_path="$(python3 -c "import os.path; print(os.path.relpath('$SKILLS_SOURCE/$skill_name', '$agent_dir'))" 2>/dev/null || echo "../../skills/$skill_name")"

        local link_path="$agent_dir/$skill_name"
        create_symlink "$rel_path" "$link_path"
    done
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  Another Marketing Skills — Installer     ║"
echo "╚════════════════════════════════════════════╝"
echo ""

if [ "$AGENT_MODE" = "list" ]; then
    echo "Installed symlinks:"
    find "$SCRIPT_DIR/.opencode/skills" "$SCRIPT_DIR/.agents/skills" "$SCRIPT_DIR/.claude/skills" -maxdepth 2 -type l 2>/dev/null | while read -r link; do
        echo "  $link → $(readlink "$link")"
    done
    exit 0
fi

# Resolve agent
if [ "$AGENT_MODE" = "auto" ]; then
    AGENT_MODE="$(detect_agent)"
    info "Detected agent: $AGENT_MODE"
fi

case "$AGENT_MODE" in
    all)
        install_skill_symlinks "$SCRIPT_DIR/.opencode/skills"
        install_skill_symlinks "$SCRIPT_DIR/.agents/skills"
        install_skill_symlinks "$SCRIPT_DIR/.claude/skills"
        ;;
    opencode)
        install_skill_symlinks "$SCRIPT_DIR/.opencode/skills"
        ;;
    claude)
        install_skill_symlinks "$SCRIPT_DIR/.claude/skills"
        ;;
    codex|universal)
        install_skill_symlinks "$SCRIPT_DIR/.agents/skills"
        ;;
    cursor)
        warn "Cursor uses .cursorrules — create symlinks manually or use --agent opencode"
        install_skill_symlinks "$SCRIPT_DIR/.opencode/skills"
        ;;
    *)
        error "Unknown agent: $AGENT_MODE"
        exit 1
        ;;
esac

echo ""
info "Verifying installation..."
bash scripts/skill-lint.sh skills/*/ 2>&1 | tail -1
echo ""

echo "╔════════════════════════════════════════════╗"
echo "║  Install complete                          ║"
echo "╠════════════════════════════════════════════╣"
echo "║  Skills: $SKILLS_SOURCE"
echo "║  Agent:  $AGENT_MODE"
echo "║  Symlinks created in: .opencode/skills/    ║"
echo "║                       .agents/skills/      ║"
echo "║                       .claude/skills/      ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Next, configure your product context:"
echo "  Ask your agent: 'set up product context for my project'"
echo ""
echo "Windows users: run install.ps1 instead (PowerShell)."
echo "On Windows, clone with: git clone -c core.symlinks=true ..."
