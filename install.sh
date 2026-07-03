#!/usr/bin/env bash
# install.sh — Another Marketing Skills installer (Linux/macOS)
# Usage:
#   bash install.sh                        # Create skill symlinks in current project
#   bash install.sh --global               # Install globally + create init-marketing
#   bash install.sh --agent opencode       # Force agent type
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
    echo "Usage: bash install.sh [--global] [--agent opencode|claude|codex|all] [--list]"
    echo ""
    echo "  --global         Install globally + create init-marketing command"
    echo "  --agent <type>   Force agent type (default: auto-detect)"
    echo "  --list           List installed symlinks"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --global) AGENT_MODE="global"; shift ;;
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

# ─────────────────────────────────────────
# Global install
# ─────────────────────────────────────────
if [ "$AGENT_MODE" = "global" ]; then
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  Global Install                           ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""

    LOCAL_BIN="${HOME}/.local/bin"
    GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
    mkdir -p "$LOCAL_BIN" "$GLOBAL_SKILLS_DIR"

    # Copy skills to global directory
    for skill_dir in "$SKILLS_SOURCE"/*/; do
        [ ! -d "$skill_dir" ] && continue
        skill_name="$(basename "$skill_dir")"
        [ ! -f "${skill_dir}SKILL.md" ] && continue

        if [ -d "$GLOBAL_SKILLS_DIR/$skill_name" ]; then
            warn "Skill $skill_name already exists globally — skipping"
        else
            cp -r "$skill_dir" "$GLOBAL_SKILLS_DIR/$skill_name"
            ok "Installed globally: $skill_name"
        fi
    done

    # Copy scripts to global directory
    mkdir -p "${HOME}/.config/opencode/scripts"
    cp "$SCRIPT_DIR/scripts/content-lint.sh" "$SCRIPT_DIR/scripts/voice-lint.sh" \
       "$SCRIPT_DIR/scripts/commit-gate.sh" "$SCRIPT_DIR/scripts/showcase-gate.sh" \
       "$SCRIPT_DIR/scripts/research-gate.sh" "$SCRIPT_DIR/scripts/social-gate.sh" \
       "$SCRIPT_DIR/scripts/plan-gate.sh" "$SCRIPT_DIR/scripts/seo-gate.sh" \
       "${HOME}/.config/opencode/scripts/" 2>/dev/null || true
    ok "Scripts installed to ~/.config/opencode/scripts/"

    # Create init-marketing command
    cat > "$LOCAL_BIN/init-marketing" << 'INITEOF'
#!/usr/bin/env bash
# init-marketing — Activate marketing skills in current project
# Detects agent type, creates symlinks, installs commit-gate hook.
# Does NOT overwrite another-agent-skills hooks.

set -euo pipefail
GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
PROJECT_DIR="${PWD}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  init-marketing                           ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Only link our marketing skills (not all global skills)
MARKETING_SKILLS="product-marketing customer-research social-copy email-drip launch-plan marketing-plan seo-foundation showcase"

for agent_dir in ".opencode/skills" ".agents/skills" ".claude/skills"; do
    mkdir -p "$PROJECT_DIR/$agent_dir"
    for skill_name in $MARKETING_SKILLS; do
        skill_dir="$GLOBAL_SKILLS_DIR/$skill_name"
        [ ! -d "$skill_dir" ] && warn "Skill $skill_name not found globally — run install.sh --global first" && continue
        [ ! -f "${skill_dir}/SKILL.md" ] && continue

        link_path="$PROJECT_DIR/$agent_dir/$skill_name"
        rel_path="$(python3 -c "import os.path; print(os.path.relpath('$skill_dir', '$PROJECT_DIR/$agent_dir'))" 2>/dev/null || echo "../$skill_name")"

        if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$rel_path" ]; then
            continue  # Already correct
        fi
        [ -e "$link_path" ] && [ ! -L "$link_path" ] && mv "$link_path" "${link_path}.bak"
        ln -s "$rel_path" "$link_path" 2>/dev/null && ok "Linked $skill_name → $agent_dir/"
    done
done

# Install commit-gate hook (merge with existing, don't overwrite)
HOOK_FILE="$PROJECT_DIR/.git/hooks/pre-commit"
if [ -f "$HOOK_FILE" ]; then
    if grep -q "commit-gate.sh" "$HOOK_FILE" 2>/dev/null; then
        ok "commit-gate already in pre-commit hook"
    else
        echo -e "\nbash scripts/commit-gate.sh 2>&1 || exit 1" >> "$HOOK_FILE"
        ok "Added commit-gate to existing pre-commit hook"
    fi
else
    mkdir -p "$(dirname "$HOOK_FILE")"
    cat > "$HOOK_FILE" << 'HOOKEOF'
#!/usr/bin/env bash
# pre-commit — installed by init-marketing
bash scripts/commit-gate.sh 2>&1 || exit 1
HOOKEOF
    chmod +x "$HOOK_FILE"
    ok "Created pre-commit hook with commit-gate"
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  init-marketing complete                  ║"
echo "║  Skills linked to this project            ║"
echo "║  Commit-gate hook installed               ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Next, configure your product context:"
echo "  Ask your agent: 'set up product context for my project'"
INITEOF
    chmod +x "$LOCAL_BIN/init-marketing"
    ok "Created ~/.local/bin/init-marketing"

    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  Global install complete                  ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║  Skills: $GLOBAL_SKILLS_DIR"
    echo "║  Scripts: ~/.config/opencode/scripts/     ║"
    echo "║  Command: init-marketing (in any project) ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    echo "Usage:"
    echo "  cd your-project"
    echo "  init-marketing"
    echo ""
    echo "This coexists with another-agent-skills:"
    echo "  init-agents      → engineering hooks"
    echo "  init-marketing   → marketing skills + commit-gate"
    exit 0
fi

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
