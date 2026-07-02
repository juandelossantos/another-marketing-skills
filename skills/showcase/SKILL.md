---
name: showcase
description: "Generate promotional content in multiple formats from one product description. Use when the user says 'showcase', 'promote', 'make a video', 'social post', 'carousel', 'ad', or wants to generate launch content. For copy-only tasks see social-copy. For email sequences see email-drip. Requires `.agents/product-marketing.md` — run product-marketing skill first if missing."
tier: active
---

# Showcase

Generates promotional assets across 5 formats from one product input. Multi-format from a single source of truth.

## When to Use

- User wants to promote a product or project
- User says "showcase", "make a video", "social post", "carousel", "ad", "launch content"
- After `product-marketing` context has been set up
- User has a product URL, directory, or description

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md`. If missing, run `product-marketing` skill first (offer auto-draft from codebase).

### Step 2: Interview — MANDATORY Questions

Ask ALL questions below. DO NOT assume defaults. Record answers. If user says "surprise me" or "you decide", pick and state your choice with justification.

| Question | Options | Applies to |
|----------|---------|------------|
| **Format?** | social, ad, video, carousel, reel, or ALL | All |
| **Tone?** | default, polished, chaotic, deadpan, cinematic, app-store, warm | All |
| **Duration?** | 15s, 18s, 20s, 25s | Video, Reel |
| **Music?** | CC0 bed, none | Video, Reel |
| **Voiceover?** | TTS (Kokoro), none | Video, Reel |
| **Sound effects?** | transitions, emphasis, none | Video, Reel |
| **Distribute?** | auto (Buffer), manual (share-copy.txt) | All |

Format reference:

| Format | Output | Dependencies | Fallback |
|--------|--------|-------------|----------|
| Social Post | Copy (LinkedIn, Twitter, IG) | None | — |
| Ad Copy | Headline + body + CTA | None | — |
| Video | Composition + MP4 | hyperframes CLI (npx) | Output script only |
| Carousel | Slides + copy | CANVA_API_KEY | Output outline only |
| Reel | Vertical composition + MP4 | hyperframes CLI (npx) | Output script only |

### Step 3: Pre-Generation Gate (MECHANICAL — BLOCKING)

After collecting answers, save them:

```bash
bash scripts/showcase-gate.sh --save
# Then edit .showcase/interview.json with the user's answers
```

Before generating, run the gate:

```bash
bash scripts/showcase-gate.sh
```

**If exit code ≠ 0:** STOP. Answers are missing. Go back to Step 2.

**Only proceed when exit code = 0.**

### Step 4: Generate

Output goes to `showcase-output/<date>/`. Input assets (logos, screenshots, music) go in `showcase-input/`.

```
showcase-output/
└── 2026-07-02/
    ├── video.mp4              ← Rendered video
    ├── carousel.mp4           ← Rendered carousel
    ├── reel.mp4               ← Rendered reel
    ├── social-post.md         ← LinkedIn + Twitter + IG
    ├── ad-copy.md             ← Google + LinkedIn Ads
    ├── carousel-outline.md    ← Slide text outline
    └── share-copy.txt         ← All copy ready to paste

showcase-input/
├── images/                    ← Logos, screenshots, hero images
├── music/                     ← Custom music tracks
└── videos/                    ← Existing footage / B-roll
```

Read the format-specific reference guide:

- `references/format-social-post.md` — per-platform copy templates
- `references/format-ad-copy.md` — headline formulas + persuasion frameworks
- `references/format-video.md` — Hyperframes pipeline
- `references/format-carousel.md` — slide deck structure
- `references/format-reel.md` — short-form vertical video

Apply brand voice from `product-marketing.md` Section 10.
Apply tone from `references/tone-system.md`.

Use hyperframes CLI for video/reel rendering: `npx hyperframes lint <dir>` then `npx hyperframes render <dir> --out showcase-output/<date>/video.mp4`.

### Step 5: Quality Gate (MANDATORY)

Run `bash scripts/content-lint.sh --file <output>` and `bash scripts/voice-lint.sh --file <output>`.

If either fails (exit 1) → FIX violations. Do NOT distribute until both pass.

See `references/quality-gates.md` for per-format rubrics.

### Step 6: Distribute

Auto (Buffer API if BUFFER_API_KEY set, must confirm with user) or Manual (write `share-copy.txt`).

See `references/distribution.md`.

## Tone System

| Tone | Energy | Best for |
|------|--------|----------|
| default | Clean, postable | General launches |
| polished | Elegant, serious | B2B / enterprise |
| chaotic | Fast, loud | Consumer / fun |
| deadpan | Dry, understated | Anti-hype |
| cinematic | Dramatic | Big announcements |
| app-store | Feature-clean | Product updates |
| warm | Friendly, personal | Community / email |

Full definitions: `references/tone-system.md`

## Verification Checklist

- [ ] `.agents/product-marketing.md` exists and was read
- [ ] PRE-GENERATION GATE: All 7 questions answered (format, tone, duration, music, VO, SFX, distribute)
- [ ] User explicitly confirmed each choice (not assumed)
- [ ] Output file(s) generated per format spec
- [ ] Brand voice compliance checked (no vocabulary drift)
- [ ] Character/resolution/duration limits respected
- [ ] CTA present in all generated content
- [ ] Generic SaaS language check passed
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS
- [ ] share-copy.txt written (manual mode) or Buffer scheduled (auto mode, user confirmed)

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — set up context before showcase |
| social-copy | For text-only social posts without other formats |
| email-drip | For email sequences instead of one-off posts |
| customer-research | If you need audience insights before creating |
