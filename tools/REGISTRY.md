# Tool Registry

Index of all 8 skills with dependencies, APIs, integrations, and CLI tools.

## Skills Overview

| Skill | External Deps | API Key Needed | CLI Tools | MCP Available |
|-------|--------------|----------------|-----------|---------------|
| product-marketing | None | No | — | — |
| customer-research | None | No | — | — |
| social-copy | Buffer (optional) | BUFFER_API_KEY | — | Buffer MCP |
| email-drip | None (v1) | — | — | — |
| launch-plan | None | No | — | — |
| marketing-plan | None | No | — | — |
| seo-foundation | None | No | — | — |
| showcase | hyperframes CLI | No (local render) | build-composition.sh | Hyperframes MCP |

## Per-Skill Detail

### product-marketing
- **Dependencies:** None
- **API keys:** None
- **Output:** `.agents/product-marketing.md`
- **Gate:** None (reads context, no generation)

### customer-research
- **Dependencies:** None
- **API keys:** None
- **Output:** Synthesis report, VOC quote bank, persona document
- **Gate:** `research-gate.sh` — 4 questions
- **Sources:** Reddit, G2, HN, App Store, LinkedIn (via web_fetch)

### social-copy
- **Dependencies:** Buffer API (optional, for auto-publish)
- **API keys:** `BUFFER_API_KEY`
- **Output:** Content package per platform
- **Gate:** `social-gate.sh` — 5 questions
- **Platforms:** LinkedIn, Twitter/X, Instagram, TikTok, Dev.to, Facebook

### email-drip
- **Dependencies:** None (v1 — plain text output)
- **API keys:** None (v1)
- **Output:** Email sequence (subject, preview, body, CTA, timing)
- **Gate:** None (sequence type is the only input)
- **Sequence types:** Welcome, Nurture, Onboarding, Re-engagement, Post-purchase

### launch-plan
- **Dependencies:** None
- **API keys:** None
- **Output:** GTM launch plan (pre/launch/post phases)
- **Gate:** None (launch type is the only input)
- **Framework:** ORB (Owned, Rented, Borrowed channels)

### marketing-plan
- **Dependencies:** None
- **API keys:** None
- **Output:** 13-section AARRR marketing plan
- **Gate:** `plan-gate.sh` — 5 questions
- **Framework:** AARRR (Acquisition, Activation, Retention, Referral, Revenue)

### seo-foundation
- **Dependencies:** None
- **API keys:** None (Google Search Console optional for monitoring)
- **Output:** Meta tags, JSON-LD, OG image spec, blog intro
- **Gate:** `seo-gate.sh` — 4 questions
- **References:** Meta tags, Structured data, OG images, AEO/GEO

### showcase
- **Dependencies:** hyperframes CLI (`npx hyperframes`)
- **API keys:** None (renders locally via Chrome + FFmpeg)
- **System req:** Node.js 22+, FFmpeg, Chrome
- **CLI tools:** `skills/showcase/scripts/build-composition.sh`
- **Output:** Video MP4, Carousel MP4, Reel MP4, Social copy, Ad copy
- **Gate:** `showcase-gate.sh` — 7 questions
- **Formats:** Video (16:9), Carousel (16:9), Reel (9:16), Social post, Ad copy
- **Music:** CC0 from Pixabay (optional, user-provided)

## Cross-Skill Gate Scripts

| Script | Enforces | Skills |
|--------|----------|--------|
| `content-lint.sh` | Quality: banned words, CTA, length, audio, SEO | All output |
| `voice-lint.sh` | Brand voice compliance | All output |
| `commit-gate.sh` | Interview completion at commit time | All skills |
