# install.ps1 — Another Marketing Skills installer (Windows PowerShell)
# Creates directory junctions for agent discovery.
# Requires: PowerShell 5.1+, Git with core.symlinks=true
#
# Usage:
#   .\install.ps1                        # Create all agent junctions
#   .\install.ps1 -Agent opencode        # Force OpenCode mode
#   .\install.ps1 -Agent claude          # Force Claude Code mode
#   .\install.ps1 -List                  # List installed junctions

param(
    [string]$Agent = "all",
    [switch]$List
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSource = Join-Path $ScriptDir "skills"
$HostUI = (Get-Host).UI

function Write-Info  { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

function New-Junction {
    param([string]$Target, [string]$Link)

    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    if (Test-Path $Link) {
        $item = Get-Item $Link
        if ($item.LinkType -eq "Junction") {
            Write-Ok "Junction exists: $Link → $Target"
            return
        }
        $backup = "$Link.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Warn "Backing up: $Link → $backup"
        Move-Item $Link $backup -Force
    }

    New-Item -ItemType Junction -Path $Link -Target $Target -Force | Out-Null
    Write-Ok "Created: $Link → $Target"
}

function Install-SkillJunctions {
    param([string]$AgentDir)

    Get-ChildItem $SkillsSource -Directory | ForEach-Object {
        $skillName = $_.Name
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (-not (Test-Path $skillFile)) { return }

        $linkPath = Join-Path $AgentDir $skillName
        New-Junction -Target $_.FullName -Link $linkPath
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗"
Write-Host "║  Another Marketing Skills — Installer     ║"
Write-Host "╚════════════════════════════════════════════╝"
Write-Host ""

if ($List) {
    Write-Host "Installed junctions:"
    Get-ChildItem "$ScriptDir\.opencode\skills", "$ScriptDir\.agents\skills", "$ScriptDir\.claude\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.FullName) → $($_.Target)"
    }
    exit 0
}

switch ($Agent.ToLower()) {
    "all" {
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".opencode\skills")
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".agents\skills")
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".claude\skills")
    }
    "opencode" {
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".opencode\skills")
    }
    "claude" {
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".claude\skills")
    }
    "codex" {
        Install-SkillJunctions -AgentDir (Join-Path $ScriptDir ".agents\skills")
    }
    default {
        Write-Error "Unknown agent: $Agent"
        exit 1
    }
}

Write-Host ""
Write-Info "Verifying installation..."
& "$ScriptDir\scripts\skill-lint.sh" (Join-Path $ScriptDir "skills\*") 2>&1 | Select-Object -Last 1
Write-Host ""

Write-Host "╔════════════════════════════════════════════╗"
Write-Host "║  Install complete                          ║"
Write-Host "╠════════════════════════════════════════════╣"
Write-Host "║  Skills: $SkillsSource"
Write-Host "║  Agent:  $Agent"
Write-Host "║  Junctions created in: .opencode/skills/  ║"
Write-Host "║                          .agents/skills/  ║"
Write-Host "║                          .claude/skills/  ║"
Write-Host "╚════════════════════════════════════════════╝"
Write-Host ""
Write-Host "Next, configure your product context:"
Write-Host "  Ask your agent: 'set up product context for my project'"
Write-Host ""
Write-Host "Note: Clone with git clone -c core.symlinks=true <url>"
Write-Host "      for symlink support. If symlinks don't work, junctions"
Write-Host "      are created as directory-based links."
