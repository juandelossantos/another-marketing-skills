---
name: social-copy
description: "Generate platform-optimized social media content across 7 platforms. Use when user wants 'social posts', 'content calendar', 'LinkedIn post', 'Twitter thread', 'Instagram carousel', 'TikTok video', or 'Dev.to article'. For one-off promotional assets see showcase. For research-informed copy, run customer-research first."
tier: active
---

# Social Copy

Generate full content packages — not single posts. Batching, planning, scheduling across 7 platforms with engagement strategy.

## When to Use

- User wants ongoing social media content (not one-off)
- User mentions specific platforms (LinkedIn, Twitter, Instagram, TikTok, Dev.to)
- User wants a content calendar or posting schedule
- User has existing content to repurpose (blog posts, videos)

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md`. If customer-research output exists, load themes and quotes.

### Step 2: Interview — MANDATORY Questions

Ask ALL questions. Record answers. DO NOT assume.

| Question | Options |
|----------|---------|
| **Platforms?** | LinkedIn, Twitter/X, Instagram, TikTok, Dev.to, Facebook |
| **Goal?** | awareness, engagement, traffic, community, thought leadership |
| **Content pillars?** | 3-5 topics (industry, behind-scenes, educational, personal, promo) |
| **Existing content?** | blog posts, videos, podcasts, newsletter, none |
| **Frequency?** | daily, 3-5x/week, weekly, biweekly |

After collecting, save and verify:

```bash
bash scripts/social-gate.sh --save
bash scripts/social-gate.sh
```

**If exit ≠ 0:** STOP. Go back to questions.

### Step 3: Generate Content Package

For each platform, read the platform reference guide:

- `references/platform-linkedin.md` — carousels, storytelling, PDPS
- `references/platform-twitter.md` — threads, hot takes
- `references/platform-instagram.md` — reels, carousels, stories
- `references/platform-tiktok.md` — short-form video hooks
- `references/platform-devto.md` — long-form articles, code snippets
- `references/hook-formulas.md` — 25+ proven hook patterns

Apply brand voice from `product-marketing.md`. Apply tone from showcase `references/tone-system.md`.

### Step 4: Quality Gate

```bash
bash scripts/content-lint.sh --file share-copy.txt
bash scripts/voice-lint.sh --file share-copy.txt
```

If either fails → FIX before distributing.

### Step 5: Distribute

Manual (`share-copy.txt`) or Auto (Buffer API if `BUFFER_API_KEY` set).

## Verification Checklist

- [ ] SOCIAL GATE: All 5 questions answered
- [ ] Content pillars defined (3-5, with % split)
- [ ] Each platform post adapted (not copied)
- [ ] Brand voice applied (no vocabulary drift)
- [ ] Hook present in first line
- [ ] CTA present in each post
- [ ] Platform limits respected
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS

## Related Skills

| Skill | When to use |
|-------|-------------|
| customer-research | First — get themes and language to inform copy |
| showcase | For one-off promotional assets (video, carousel, ad) |
| product-marketing | For brand voice and positioning context |
