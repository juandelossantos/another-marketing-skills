---
name: email-drip
description: "Generate complete email sequences with subject lines, preview text, body copy, CTAs, and timing. Use when user wants 'email sequence', 'welcome emails', 'nurture campaign', 'onboarding emails', 're-engagement emails', or 'drip campaign'. For one-off promotional assets see showcase. For social content see social-copy."
tier: active
---

# Email Drip

Generate full email sequences — not single emails. Timed, segmented, tracked, and consistent with brand voice.

## When to Use

- User wants welcome, nurture, onboarding, re-engagement, or post-purchase sequences
- User mentions email automation, drip campaigns, lifecycle emails
- After customer-research (to inform messaging with real pain points)

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md`. If customer-research output exists, load pain points and language.

### Step 2: Choose Sequence Type

| Type | Length | Timing | Goal |
|------|--------|--------|------|
| Welcome | 5-7 emails | 12-14 days | Activate + convert |
| Nurture | 6-8 emails | 2-3 weeks | Build trust + demo expertise |
| Onboarding | 5-7 emails | 14 days | Drive to aha moment |
| Re-engagement | 3-4 emails | 2 weeks | Win back or clean list |
| Post-purchase | 3-5 emails | 10 days | Upsell + referral |

### Step 3: Generate Sequence

For each email, follow this structure:

```
Subject: [40-60 chars, first 25 chars critical]
Preview: [90-140 chars, extends subject]
---
Hook: First line grabs attention
Context: Why this matters to them (1-2 paragraphs)
Value: The useful content (150-300 words)
CTA: One clear action (button preferred)
Sign-off: Human, warm, consistent
```

Apply brand voice from `product-marketing.md`. Apply subject line formulas from `references/subject-lines.md`.

Sequence timing:
- Welcome email: Immediately
- Early sequence: 1-2 days apart
- Nurture: 2-4 days apart
- Long-term: Weekly or bi-weekly
- B2B: Avoid weekends

### Step 4: Quality Gate

```bash
bash scripts/content-lint.sh --file <output>
bash scripts/voice-lint.sh --file <output>
```

### Step 5: Deliver

Output: sequence overview + per-email copy + metrics plan.

## Subject Line Guidelines

- Clear > Clever. Specific > Vague.
- 40-60 characters ideal
- First 25 chars most critical on mobile
- Personalization in first 25 chars → ~40% lift
- 1 exclamation max, avoid ALL CAPS
- Emojis: neutral B2B, slight lift B2C

See `references/subject-lines.md` for 15 proven formulas.

## Verification Checklist

- [ ] Sequence type selected (welcome, nurture, onboarding, re-engagement, post-purchase)
- [ ] Brand voice applied consistently across all emails
- [ ] Subject line under 60 chars, first 25 contain key message
- [ ] Preview text extends subject (doesn't repeat)
- [ ] One CTA per email (not multiple)
- [ ] Timing/delay defined per email
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS

## Related Skills

| Skill | When to use |
|-------|-------------|
| customer-research | First — get pain points and language for messaging |
| product-marketing | For brand voice and positioning context |
| social-copy | For social media content (complementary) |
| showcase | For one-off promotional assets |
