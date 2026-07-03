---
name: marketing-plan
description: "Generate comprehensive 12-month marketing plans using AARRR framework. Use when user says 'marketing plan', 'growth plan', 'AARRR plan', '90-day marketing roadmap', '12-month plan'. Coordinates product-marketing, customer-research, showcase, social-copy, email-drip, and launch-plan into a single strategic roadmap."
tier: active
---

# Marketing Plan

Generate 12-month marketing plans using AARRR (Acquisition, Activation, Retention, Referral, Revenue) — focused on the promotion flywheel.

## When to Use

- User mentions marketing plan, growth plan, AARRR, 90-day roadmap
- User wants to consolidate scattered marketing work into one plan
- Before starting a quarter or year of marketing activities

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md` and customer-research findings. Load launch-plan if available.

### Step 2: Intake — MANDATORY Questions

Ask ALL questions. Record answers. DO NOT assume.

| Question | Purpose |
|----------|---------|
| **Monthly budget?** | Shapes channel selection |
| **Team size?** | Determines execution capacity |
| **Current channels?** | What's working, what's not |
| **Funding stage?** | Pre-seed, seed, series A |
| **Biggest gap?** | Single most important fix |

After collecting, save and verify:

```bash
bash scripts/plan-gate.sh --save
bash scripts/plan-gate.sh
```

**If exit ≠ 0:** STOP. Go back to questions.

### Step 3: Generate Plan

Use AARRR framework adapted to promotion flywheel:

| Stage | Focus | Skills involved |
|-------|-------|----------------|
| Acquisition | Content, SEO, social, community | social-copy, showcase |
| Activation | Onboarding, first value | email-drip |
| Retention | Email sequences, re-engagement | email-drip |
| Referral | Word-of-mouth, community | social-copy |
| Revenue | Pricing, packaging, upsell | launch-plan |

Plan structure:

```markdown
## 1. Executive Summary (3 big bets, 90-day priorities)
## 2. Strategic Frame (positioning, ICP, brand voice)
## 3. Current State (team, budget, channels, gaps)
## 4. Acquisition Plan (channels, calendar, targets)
## 5. Activation Plan (onboarding, first value)
## 6. Retention Plan (sequences, re-engagement)
## 7. Referral Plan (word-of-mouth mechanics)
## 8. Revenue Plan (pricing, packaging, upsell)
## 9. 90-Day Roadmap (weeks 1-12, owner-assigned)
## 10. 12-Month Outlook (quarterly milestones)
## 11. Content Calendar (monthly by channel)
## 12. KPI Targets (north star, leading indicators)
## 13. Skill Coordination (which skill executes each move)
```

See `references/aarrr-framework.md` for full AARRR detail.
See `references/budget-planning.md` for budget methods.
See `references/content-pillars.md` for pillar-cluster model.
See `references/kpi-framework.md` for north star + indicators.

### Step 4: Quality Gate

```bash
bash scripts/content-lint.sh --file <output>
bash scripts/voice-lint.sh --file <output>
```

### Step 5: Deliver

Output: single markdown plan file + asset briefs for other skills.

## Verification Checklist

- [ ] AARRR framework applied to promotion flywheel
- [ ] Budget based on actual data (not guessed)
- [ ] 90-day roadmap with owners and milestones
- [ ] Content pillars defined with % split
- [ ] KPI targets with specific numbers and timelines
- [ ] Skill coordination: which skill executes each move
- [ ] `bash scripts/content-lint.sh --file <output>` — PASS
- [ ] `bash scripts/voice-lint.sh --file <output>` — PASS

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — positioning + ICP + voice |
| customer-research | Before — audience language for each stage |
| launch-plan | For GTM timing of campaigns |
| social-copy | For acquisition content execution |
| email-drip | For activation + retention sequences |
| showcase | For promotional assets in campaigns |
