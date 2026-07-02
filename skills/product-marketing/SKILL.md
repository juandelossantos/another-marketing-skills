---
name: product-marketing
description: "When the user wants to create or update their product marketing context. Use when the user mentions 'product context', 'set up context', 'positioning', 'target audience', 'ICP', 'describe my product', or before using any other marketing skill. Creates `.agents/product-marketing.md` — the shared context file read by ALL generation skills. For brand voice details, see `references/brand-voice.md`. For customer language extraction, see `references/customer-language.md`."
tier: active
---

# Product Marketing Context

Creates and maintains `.agents/product-marketing.md` — the foundational context document that every generation skill reads before producing content. Prevents repeating the same questions across skills.

## When to Use

- Starting a new project before using any generation skill
- User says "product context", "positioning", "target audience", "describe my product"
- Before running `showcase`, `social-copy`, `email-drip`, or `launch-plan`
- User wants to update existing product context

## Workflow

### Step 1: Check for Existing Context

Check `.agents/product-marketing.md`. Also check legacy locations (`.claude/`, root).

**If exists:** Read it. Summarize what's captured. Ask which sections to update.

**If missing:** Offer two options:
1. **[Recommended] Auto-draft from codebase** — read README, package.json, landing pages, existing copy → draft V1. User reviews and corrects.
2. **Start from scratch** — walk through each section conversationally.

### Step 2: Gather Information

Walk through sections one at a time. Never dump all questions at once.

For each section: explain what you're capturing → ask relevant questions → confirm accuracy → move on.

Push for **verbatim customer language** — exact phrases are more valuable than polished descriptions.

### Step 3: Create the Document

Write `.agents/product-marketing.md` with this structure:

```markdown
## Product Overview
**One-liner:** | **What it does:** | **Category:** | **Type:** | **Model:**

## Target Audience
**Companies:** | **Decision-makers:** | **Primary use case:** | **JTBD:** |

## Personas
| Persona | Cares about | Challenge | Value we promise |

## Problems & Pain Points
**Core problem:** | **Why alternatives fall short:** | **Cost:** | **Emotional tension:**

## Competitive Landscape
**Direct:** [who] — falls short because...
**Secondary:** [who] — falls short because...
**Indirect:** [who] — falls short because...

## Differentiation
**Key differentiators:** | **How we do it differently:** | **Why customers choose us:**

## Objections
| Objection | Response | | **Anti-persona:** [who is NOT a good fit]

## Switching Dynamics (JTBD Four Forces)
**Push:** (frustrations) | **Pull:** (attraction) | **Habit:** (stuck) | **Anxiety:** (fear)

## Customer Language
**How they describe the problem:** "[verbatim]" | **How they describe us:** "[verbatim]"
**Words to use:** | **Words to avoid:** | **Glossary:**

## Brand Voice
**Tone:** | **Style:** | **Personality:** (3-5 adjectives)

## Proof Points
**Metrics:** | **Customers/logos:** | **Testimonials:** ">" — [who]
**Value themes:** | Theme | Proof |

## Goals
**Business goal:** | **Conversion action:** | **Current metrics:**
```

### Step 4: Confirm and Save

- Show completed document
- Ask if anything needs adjustment
- Save to `.agents/product-marketing.md`
- Inform: "Other skills will now use this context automatically."

## Tips

- Be specific: ask "What's the #1 frustration?" not "What problem?"
- Capture exact customer words, not polished descriptions
- Validate as you go — summarize each section before moving on
- Skip what doesn't apply (e.g., Personas for B2C)

## Verification Checklist

- [ ] `.agents/product-marketing.md` exists with all 12 sections
- [ ] Each section has at least one data point (not empty)
- [ ] Customer Language contains verbatim quotes (not paraphrased)
- [ ] Proof Points are specific (numbers, names, sources)
- [ ] Objections have concrete responses
- [ ] Brand Voice has 3-5 personality adjectives
- [ ] Switching Dynamics has all four forces (Push/Pull/Habit/Anxiety)
- [ ] Competitive Landscape covers at least 2 competitor types

## Related Skills

| Skill | When to use |
|-------|-------------|
| showcase | After context is set, to generate promotional assets |
| social-copy | For text-only social posts |
| email-drip | For email sequences |
| customer-research | If you need audience research before filling context |
