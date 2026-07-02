---
name: showcase
description: "Generate promotional content in multiple formats from one product description. Use when the user says 'showcase', 'promote', 'make a video', 'social post', 'carousel', 'ad', or wants to generate launch content. For copy-only tasks see social-copy. For email sequences see email-drip. Requires `.agents/product-marketing.md` — run product-marketing skill first if missing."
tier: draft
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

### Step 2: Format Selection

Ask user which format(s) to generate:

| Format | Output | Dependencies | Fallback |
|--------|--------|-------------|----------|
| Social Post | Copy (LinkedIn, Twitter, IG) | None | — |
| Ad Copy | Headline + body + CTA | None | — |
| Video | Script + composition | HEYGEN_API_KEY | Output script only |
| Carousel | Slides + copy | CANVA_API_KEY | Output outline only |
| Reel | Vertical video script | HEYGEN_API_KEY | Output script only |

Options: `--format video,post --tone polished --distribute`

### Step 3: Generate

Read the format-specific reference guide:

- `references/format-social-post.md` — per-platform copy templates
- `references/format-ad-copy.md` — headline formulas + persuasion frameworks
- `references/format-video.md` — Hyperframes pipeline
- `references/format-carousel.md` — slide deck structure
- `references/format-reel.md` — short-form vertical video

Apply brand voice from `product-marketing.md` Section 10.
Apply tone from `references/tone-system.md`.

### Step 4: Quality Gate

Run the per-format verification checklist from `references/quality-gates.md`:

All formats: brand voice compliance, no generic language, CTA present.
Social: character limits per platform. Video: 15-25s duration.
Carousel: N slides match plan. Ad: headline + body + CTA.

### Step 5: Distribute

Auto (Buffer API if BUFFER_API_KEY set) or Manual (write `share-copy.txt`).

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
- [ ] Format selection confirmed by user
- [ ] Output file(s) generated per format spec
- [ ] Brand voice compliance checked (no vocabulary drift)
- [ ] Character/resolution/duration limits respected
- [ ] CTA present in all generated content
- [ ] Generic SaaS language check passed
- [ ] share-copy.txt written (manual mode) or Buffer scheduled (auto mode)

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — set up context before showcase |
| social-copy | For text-only social posts without other formats |
| email-drip | For email sequences instead of one-off posts |
| customer-research | If you need audience insights before creating |
