# Another Marketing Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](VERSION)
[![Skills: 1](https://img.shields.io/badge/skills-1%20%E2%86%92%208%20planned-brightgreen)](skills/)
[![Status: Build](https://img.shields.io/badge/status-building-yellow)](HEALTH-CHECK.md)
[![CI](https://img.shields.io/github/actions/workflow/status/juandelossantos/another-marketing-skills/ci.yml?branch=main)](https://github.com/juandelossantos/another-marketing-skills/actions)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![OpenCode](https://img.shields.io/badge/OpenCode-first-8A2BE2)](https://opencode.ai)

**You built it. Now promote it.**

AI agent skills that research, create, and distribute promotional content — video, carousel, social posts, email sequences, and launch plans — with the same mechanical discipline that [another-agent-skills](https://github.com/juandelossantos/another-agent-skills) brings to software engineering.

> Designed for [**OpenCode**](https://opencode.ai) first. Portable to Claude Code, Cursor, Codex CLI, Gemini CLI, and any agent via AGENTS.md.

---

## Quick Start

```bash
# Clone the skills
git clone https://github.com/juandelossantos/another-marketing-skills.git
cd another-marketing-skills

# Set up product context (required before any generation skill)
# Ask your agent: "set up product context for my project"
```

Your agent reads `AGENTS.md` automatically. The `product-marketing` skill creates `.agents/product-marketing.md` — one source of truth for all generation skills.

### Install as OpenCode Plugin

```
/plugin marketplace add juandelossantos/another-marketing-skills
/plugin install another-marketing-skills
```

### Manual Install (any agent)

```bash
# Symlink skills to agent discovery path
ln -s "$PWD/skills/product-marketing" .opencode/skills/product-marketing   # OpenCode
ln -s "$PWD/skills/product-marketing" .agents/skills/product-marketing      # Codex CLI / universal
ln -s "$PWD/skills/product-marketing" .claude/skills/product-marketing      # Claude Code
```

---

## The Problem

Marketing tools are fragmented. Each platform (LinkedIn, Twitter, email, video) has its own rules, formats, and APIs. Developers who ship great products struggle to promote them because marketing is a different discipline.

```mermaid
flowchart LR
    subgraph Without["Without This System"]
        A[Product Ships] --> B[Where do I post?]
        B --> C[Write copy manually]
        C --> D[Resize for each platform]
        D --> E[Different tone per channel]
        E --> F[Post and hope]
    end

    subgraph With["With This System"]
        G[Product Ships] --> H[Set product context once]
        H --> I[Agent generates 5 formats]
        I --> J[Approve in chat]
        J --> K[Auto-publish via Buffer]
        K --> L[Measure and iterate]
    end

    Without --> |"Fragmented, manual, inconsistent"| M[❌ Low distribution]
    With --> |"Unified, automated, on-brand"| N[✅ High distribution]
```

---

## Skills

### Current

| Skill | Status | What It Does | Depends On |
|-------|--------|-------------|------------|
| `product-marketing` | ✅ v0.1 (draft) | Creates `.agents/product-marketing.md` — shared context for all skills | None |

### Planned (Fase 1-3)

```mermaid
flowchart TD
    PM[product-marketing] --> SC[showcase]
    PM --> SOC[social-copy]
    PM --> EM[email-drip]
    PM --> LP[launch-plan]
    PM --> SEO[seo-foundation]
    PM --> CR[customer-research]
    PM --> MP[marketing-plan]

    SC --> |"video, carousel, post, ad, reel"| F1[Multi-format assets]
    SOC --> |"LinkedIn, Twitter, IG, TikTok"| F2[Platform-optimized copy]
    EM --> |"welcome, nurture, re-engagement"| F3[Email sequences]
    LP --> |"pre-launch → launch → post-launch"| F4[GTM timeline]
```

---

## How It Works

```mermaid
flowchart LR
    subgraph Input
        A[Describe Product]
        B[URL or Repo]
    end

    subgraph Context["Foundation (once)"]
        C[product-marketing<br/>.agents/product-marketing.md]
    end

    subgraph Generate["Generation Skills"]
        D[showcase]
        E[social-copy]
        F[email-drip]
        G[launch-plan]
    end

    subgraph Output
        H[Video / Carousel]
        I[Social Posts]
        J[Email Sequences]
        K[Launch Timeline]
    end

    subgraph Distribute
        L[Auto: Buffer API]
        M[Manual: share-copy.txt]
    end

    A --> C
    B --> C
    C --> D & E & F & G
    D --> H
    E --> I
    F --> J
    G --> K
    H & I & J & K --> L & M
```

### The Promotion Flywheel

```
Research → Create → Distribute → Measure → Iterate
Every skill follows this cycle. The agent does the work. The human approves.
```

---

## Agent Compatibility

| Feature | OpenCode | Claude Code | Codex CLI | Cursor | Gemini CLI | Any Agent |
|---------|----------|-------------|-----------|--------|------------|-----------|
| SKILL.md auto-discovery | ✅ native | ⚠️ symlink | ✅ symlink | ⚠️ custom | ⚠️ custom | ⚠️ manual |
| Guardian Pattern | ✅ full | ✅ full | ✅ partial | ✅ partial | ✅ partial | ✅ partial |
| Skill gates | ✅ native | ⚠️ manual | ⚠️ manual | ⚠️ manual | ⚠️ manual | ⚠️ manual |
| Distribution auto-publish | ✅ via Buffer API | ⚠️ manual | ⚠️ manual | ⚠️ manual | ⚠️ manual | ⚠️ manual |

**Recommended:** OpenCode for full mechanical enforcement. Other agents work via AGENTS.md rules.

---

## Design Philosophy

| Principle | What It Means |
|-----------|---------------|
| **Generation is solved. Distribution is the bottleneck.** | AI can write copy. Getting it to the right platform in the right format is the hard part. |
| **Copy is craft, not prompting.** | Marketing copy requires research, audience understanding, and persuasion psychology — not template-filling. |
| **Multi-format from one input.** | Describe once. Get video, carousel, social post, email, and launch plan. |
| **The agent works. The human decides.** | Never publish without approval. Guardian Pattern applies to marketing too. |
| **Quality over quantity.** | 8 skills that ship beats 45 that advise. Every skill produces a distributable asset. |
| **Mechanical enforcement.** | Brand voice, platform rules, readability, and persuasion structure are checked by gates — not left to judgment. |

Read the full philosophy in [`SOUL.md`](SOUL.md).

---

## What Makes This Different

| Dimension | Generic AI Marketing | marketingskills (45 skills) | **another-marketing-skills** |
|-----------|-------------------|---------------------------|---------------------------|
| **Output** | Advisory text | Advisory ("here's advice") | **Generative (finished assets)** |
| **Formats** | Single per tool | Single per skill | **Multi-format from one input** |
| **Distribution** | None | None | **Auto (Buffer API) + Manual (copy-paste)** |
| **Quality** | No gates | Eval system | **Eval + mechanical gates + brand voice audit** |
| **Context discipline** | None | 600+ line skills | **SKILL.md <250 lines, lazy-loaded references** |
| **Enforcement** | None | Validation scripts | **Full Guardian Pattern + gates** |
| **Audience** | Everyone | Technical marketers | **Developers + non-developers (dual mode)** |

---

## Project Structure

```
another-marketing-skills/
├── AGENTS.md                # Agent instructions (universal)
├── SOUL.md                  # Project identity
├── SPEC.md                  # Project specification
├── DESIGN.md                # Visual design tokens
├── HEALTH-CHECK.md          # Project state tracker
├── .gitignore
├── VERSION
├── scripts/                 # Enforcement scripts (8 gates)
│   ├── skill-lint.sh        # Validate skill structure
│   ├── skill-gate.sh        # Register skill consultation
│   ├── edit-guard.sh        # File integrity protection
│   └── ...
├── skills/                  # Marketing skills
│   └── product-marketing/   # Foundation context skill
├── design/                  # Design lock + tokens
├── rules/                   # Enforcement rules
└── development/             # Dev artifacts (gitignored)
```

---

## Status

- **Current version:** 0.1.0
- **Skills shipped:** 1 (product-marketing, draft)
- **Planned skills:** 8 total across 4 fases
- **Infrastructure:** install.sh + install.ps1, eval system, multi-agent symlinks ✅
- **Landing page:** Deferred until 2+ skills (Fase 1b)
- **Eval tests:** 4/4 trigger pass, full coverage

See [`HEALTH-CHECK.md`](HEALTH-CHECK.md) for full project state.

---

## Contributing

Open an issue or PR. Focus on the promotion flywheel — research, create, distribute, measure, iterate. No CRO, no ads management, no pricing skills.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) (coming) for skill creation guidelines.

---

## License

MIT © 2026 juandelossantos

Built on the mechanical discipline of [another-agent-skills](https://github.com/juandelossantos/another-agent-skills).
