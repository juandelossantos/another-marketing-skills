---
name: launch-plan
description: "Generate complete go-to-market launch plans with timeline, channel strategy, content calendar, and success metrics. Use when user says 'launch plan', 'go-to-market', 'GTM', 'product launch', 'release strategy', 'launch timeline'. Coordinates showcase, social-copy, and email-drip around a unified launch moment."
tier: active
---

# Launch Plan

Generate complete GTM launch plans — pre-launch through post-launch — with channel strategy, content calendar, and asset briefs for other skills.

## When to Use

- User mentions launch, GTM, release strategy, go-to-market
- User has a product or feature ready to announce
- Before generating showcase, social-copy, or email-drip assets for a launch

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md`. Load customer-research themes if available.

### Step 2: Choose Launch Type

| Type | Timeline | Channels | Intensity |
|------|----------|----------|-----------|
| Major launch | 4-6 weeks pre | All ORB | Full campaign |
| Feature release | 2-3 weeks pre | Email + social | Medium |
| Minor update | 1 week pre | Social + changelog | Light |

### Step 3: Generate Launch Plan

Use the ORB framework (Owned, Rented, Borrowed):

**Owned:** Email list, blog, community — compound over time
**Rented:** Social media, app stores, Reddit — algorithm-dependent
**Borrowed:** Podcasts, guest posts, influencer collabs — instant credibility

Structure output:

```markdown
## Launch Plan: [Product/Feature]
Type: [Major/Feature/Minor]
Timeline: [Date range]

### Phase 1: Pre-Launch (Weeks -4 to -1)
[Weekly breakdown of tasks per channel]

### Phase 2: Launch Day
[Hourly breakdown — email, blog, social, PH, in-app]

### Phase 3: Post-Launch (Weeks +1 to +4)
[Onboarding, follow-ups, comparison pages]

### Asset Briefs (for other skills)
- showcase: [1 video, 1 carousel, 1 ad]
- social-copy: [5 LinkedIn, 3 Twitter threads, 1 Dev.to]
- email-drip: [welcome + nurture sequences]

### Success Metrics
[KPI targets: signups, traffic, engagement, revenue]
```

See `references/gtm-frameworks.md` for ORB details.
See `references/timeline-template.md` for weekly planner.
See `references/channel-strategy.md` for per-channel tactics.
See `references/launch-checklist.md` for 30+ verification items.

### Step 4: Quality Gate

```bash
bash scripts/content-lint.sh --file <output>
bash scripts/voice-lint.sh --file <output>
```

### Step 5: Hand Off

Generate asset briefs for showcase, social-copy, and email-drip.

## Verification Checklist

- [ ] Launch type selected (major, feature, minor)
- [ ] ORB framework applied (owned, rented, borrowed)
- [ ] 5-phase approach structured (pre → launch → post)
- [ ] Asset briefs generated for other skills
- [ ] Success metrics defined with targets
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — positioning for launch messaging |
| customer-research | Before launch — audience language for copy |
| showcase | Generate launch video, carousel, ad assets |
| social-copy | Generate launch day social content |
| email-drip | Generate launch + onboarding email sequences |
