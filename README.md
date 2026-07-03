# Another Marketing Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](VERSION)
[![Skills: 8](https://img.shields.io/badge/skills-8%20active-brightgreen)](skills/)
[![Status: Active](https://img.shields.io/badge/status-active-brightgreen)](HEALTH-CHECK.md)
[![CI](https://img.shields.io/github/actions/workflow/status/juandelossantos/another-marketing-skills/ci.yml?branch=main)](https://github.com/juandelossantos/another-marketing-skills/actions)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![OpenCode](https://img.shields.io/badge/OpenCode-first-8A2BE2)](https://opencode.ai)

**You built it. Now promote it.**

AI agent skills that research, create, and distribute promotional content — video, carousel, social posts, email sequences, and launch plans — with the same mechanical discipline that [another-agent-skills](https://github.com/juandelossantos/another-agent-skills) brings to software engineering.

> Designed for [**OpenCode**](https://opencode.ai) first. Portable to Claude Code, Cursor, Codex CLI, Gemini CLI, and any agent via AGENTS.md.

---

## Quick Start

```bash
# Clone + install
git clone https://github.com/juandelossantos/another-marketing-skills.git
cd another-marketing-skills
bash install.sh --agent all

# Set up product context (required before any generation)
# Ask your agent: "set up product context for my project"
```

Your agent reads `AGENTS.md` and discovers skills automatically via symlinks at `.opencode/skills/`, `.agents/skills/`, and `.claude/skills/`.

### Windows

```powershell
git clone https://github.com/juandelossantos/another-marketing-skills.git
cd another-marketing-skills
.\install.ps1 -Agent all
```

> **Note:** On Windows, clone with `git clone -c core.symlinks=true` for symlink support.

---

## Skills

### All Active

| Skill | Status | What It Does |
|-------|--------|-------------|
| `product-marketing` | ✅ v1.0 (active) | Creates `.agents/product-marketing.md` — shared context for all skills |
| `customer-research` | ✅ v1.0 (active) | VOC extraction, competitive analysis, persona generation, confidence-scored research |
| `showcase` | ✅ v1.0 (active) | 5-format generator: video, carousel, reel, social post, ad copy. Mechanical quality gates |
| `social-copy` | ✅ v1.0 (active) | Platform-optimized social content for 7 platforms, hooks, content calendars |
| `email-drip` | ✅ v1.0 (active) | Complete email sequences with subject lines, preview text, CTAs, timing |
| `launch-plan` | ✅ v1.0 (active) | Go-to-market launch plans with timeline, channel strategy, content calendar |
| `marketing-plan` | ✅ v1.0 (active) | Comprehensive 12-month marketing plans using AARRR framework |
| `seo-foundation` | ✅ v1.0 (active) | SEO-optimized meta tags, structured data (JSON-LD), OG images, blog content |

```mermaid
flowchart TD
    PM[product-marketing] --> CR[customer-research]
    PM --> SC[showcase]
    PM --> SOC[social-copy]
    PM --> EM[email-drip]
    PM --> LP[launch-plan]
    PM --> SEO[seo-foundation]
    CR --> SOC & EM
    SOC & EM --> MP[marketing-plan]
```

---

## Mechanical Enforcement

Every skill has a corresponding gate script that blocks the agent from proceeding without user input and quality verification:

| Gate | Blocks | What it enforces |
|------|--------|-----------------|
| `research-gate.sh` | Extraction | User must answer 4 questions before research |
| `showcase-gate.sh` | Generation | User must answer 7 questions before creating |
| `social-gate.sh` | Generation | User must answer 5 questions before social copy |
| `plan-gate.sh` | Generation | User must answer 5 questions before marketing plan |
| `seo-gate.sh` | Generation | User must answer 4 questions before SEO generation |
| `commit-gate.sh` | Commit | Blocks commit if any gate interviews incomplete |
| `content-lint.sh` | Distribution | Output must pass banned words, CTA, length, audio, SEO checks |
| `voice-lint.sh` | Distribution | Output must match brand voice from product-marketing.md |

---

## How It Works

```mermaid
flowchart LR
    subgraph Context
        C[product-marketing<br/>one-time setup]
    end
    subgraph Research
        R[customer-research<br/>VOC + competitive]
    end
    subgraph Generate
        SC[showcase<br/>5 formats]
        SOC[social-copy<br/>7 platforms]
        EM[email-drip<br/>5 sequences]
        LP[launch-plan<br/>GTM + timeline]
        MP[marketing-plan<br/>12-month AARRR]
        SEO[seo-foundation<br/>meta + schema]
    end
    subgraph Gates
        G1[content-lint<br/>voice-lint<br/>commit-gate]
    end
    subgraph Distribute
        D[share-copy.txt<br/>or Buffer API]
    end

    C --> R
    C --> SC & SOC & EM & LP & MP & SEO
    R --> SOC & EM
    SC & SOC & EM & LP & MP & SEO --> G1 --> D
```

**The Promotion Flywheel:** Research → Create → Distribute → Measure → Iterate

---

## Agent Compatibility

| Feature | OpenCode | Claude Code | Codex CLI | Any Agent |
|---------|----------|-------------|-----------|-----------|
| SKILL.md discovery | ✅ native | ✅ symlink | ✅ symlink | ⚠️ manual |
| Mechanical gates | ✅ full | ✅ full | ✅ partial | ✅ partial |

---

## Project Structure

```
another-marketing-skills/
├── AGENTS.md                   # Agent instructions (universal)
├── install.sh / install.ps1    # Cross-platform installers
├── scripts/
│   ├── content-lint.sh         # Banned words, CTA, platform limits, audio, SEO
│   ├── voice-lint.sh           # Brand voice compliance
│   ├── showcase-gate.sh        # Mandatory 7-question interview
│   ├── research-gate.sh        # Mandatory 4-question interview
│   ├── social-gate.sh          # Mandatory 5-question interview
│   ├── plan-gate.sh            # Mandatory 5-question interview for marketing plan
│   ├── seo-gate.sh             # Mandatory 4-question interview for SEO
│   ├── commit-gate.sh          # Blocks commit if interviews incomplete
│   ├── skill-gate.sh           # Skill consultation marker
│   ├── eval/                   # Eval runners (trigger, golden, adversarial)
│   └── ...                     # Guard, lint, hook scripts
├── skills/
│   ├── product-marketing/      # Foundation context
│   ├── customer-research/      # VOC extraction + analysis
│   ├── showcase/               # Multi-format generator
│   ├── social-copy/            # Social media content (7 platforms)
│   ├── email-drip/             # Email sequences (5 types)
│   ├── launch-plan/            # Go-to-market launch plans
│   ├── marketing-plan/         # 12-month AARRR marketing plans
│   └── seo-foundation/         # Meta, JSON-LD, OG, blog content
└── development/                # Dev artifacts (gitignored)
```

## Status

- **Version:** 0.1.0
- **Skills shipped:** 8 (all active) across 4 fases
- **Mechanical gates:** 8 scripts enforcing user interaction + quality
- **Eval tests:** 32/32 pass, full coverage all 8 skills
- **Install:** install.sh (Linux/macOS) + install.ps1 (Windows)

---

## License

MIT © 2026 juandelossantos

Built on [another-agent-skills](https://github.com/juandelossantos/another-agent-skills).
