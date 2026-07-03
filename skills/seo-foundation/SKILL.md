---
name: seo-foundation
description: "Generate SEO-optimized meta tags, structured data (JSON-LD), OG images, and blog content. Use when user says 'meta tags', 'structured data', 'JSON-LD', 'schema markup', 'OG image', 'SEO title', 'meta description', 'search optimization'. For SEO site audits see seo-audit."
tier: active
---

# SEO Foundation

Generate search-optimized assets — meta tags, structured data, OG images, and blog content — optimized for both traditional and AI search (AEO/GEO).

## When to Use

- User mentions meta tags, structured data, JSON-LD, schema, OG image
- User is publishing a new page or blog post
- Before launching a new product or feature

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md` for product name, description, and brand voice.

### Step 2: Select Output Type

| Output | What it produces | Use case |
|--------|-----------------|----------|
| Meta tags | Title (50-60c) + Description (150-160c) | Every page |
| Structured data | JSON-LD (SoftwareApp, Article, Organization, FAQ, Breadcrumb) | Rich results |
| OG image | Image spec (1200x630) + text overlay | Social sharing |
| Blog intro | H1 + meta + first 100 words | Blog posts |

### Step 3: Generate

**Meta tags:**
- Title: 50-60 chars, primary keyword near start, brand at end
- Description: 150-160 chars, includes keyword + value prop + CTA
- Verify: no duplication, no keyword stuffing

**Structured data (JSON-LD):**
- Use Schema.org types: SoftwareApplication, Article, Organization, FAQPage, BreadcrumbList
- Include: name, description, url, author, offers, aggregateRating
- Validate: https://search.google.com/test/rich-results

**OG images:**
- Dimensions: 1200x630px (1.91:1 ratio)
- Text: title (48px+) + brand name
- Background: use brand colors from DESIGN.md
- Avoid text clutter — 3-5 words maximum

**Blog intro (SEO-optimized):**
- H1 with primary keyword
- First 100 words contain primary keyword
- Related keywords in subheadings (H2, H3)
- AEO/GEO: answer direct questions, use natural language

See `references/meta-tags.md` for tag guidelines.
See `references/structured-data.md` for JSON-LD templates.
See `references/og-images.md` for image specs.
See `references/aego-guide.md` for AI search optimization.

### Step 4: Quality Gate

```bash
bash scripts/content-lint.sh --file <output>
bash scripts/voice-lint.sh --file <output>
```

## Verification Checklist

- [ ] Output type selected (meta, structured data, OG, blog)
- [ ] Title: 50-60 chars, keyword near start
- [ ] Description: 150-160 chars, keyword + value + CTA
- [ ] JSON-LD: valid Schema.org type, all required fields
- [ ] OG image: 1200x630, readable text, brand colors
- [ ] AEO/GEO: natural language, answers direct questions
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — product name and voice for meta |
| showcase | For promotional assets linking to SEO pages |
| social-copy | For social posts about new content |
