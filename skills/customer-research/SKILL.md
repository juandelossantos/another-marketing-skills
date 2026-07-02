---
name: customer-research
description: "Extract what customers actually think, feel, say, and struggle with. Use when the user mentions 'customer research', 'talk to customers', 'analyze transcripts', 'voice of customer', 'VOC', 'build personas', 'JTBD', 'Reddit mining', 'G2 reviews', 'review mining', 'digital watering holes', or 'find out why customers churn'. Reads product-marketing.md for context. For copy informed by research, see showcase or social-copy."
tier: active
---

# Customer Research

Uncover what customers actually think and say — so positioning, copy, and product decisions are grounded in evidence, not assumptions.

## When to Use

- User mentions customer research, personas, VOC, JTBD
- Before creating any copy or content — to avoid generic output
- User has transcripts, surveys, support tickets, or reviews to analyze
- User wants to mine Reddit, G2, HN, or forums for customer language

## Workflow

### Step 1: Load Context

Read `.agents/product-marketing.md`. If missing, run `product-marketing` first.

### Step 2: Interview — MANDATORY Questions

Ask the user ALL questions below. Record answers. DO NOT assume.

| Question | Options |
|----------|---------|
| **Goal?** | improve messaging, build personas, find product gaps, understand churn |
| **Existing assets?** | transcripts, surveys, tickets, G2 reviews, nothing |
| **Target segment?** | all customers, specific tier, churned users, prospects |
| **Deliverable?** | synthesis, VOC quotes, persona, JTBD map, competitive intel, gap analysis |

After collecting answers, save them:

```bash
bash scripts/research-gate.sh --save
```

Before extracting, run the gate:

```bash
bash scripts/research-gate.sh
```

**If exit code ≠ 0:** STOP. Go back to questions.

### Step 3: Choose Mode

**Mode 1 — Analyze Existing Assets:** User provides transcripts, surveys, tickets, reviews, NPS data.

**Mode 2 — Digital Watering Holes:** Agent finds research from online sources (Reddit, G2, HN, forums, App Store).

### Step 4: Extract

For each source, extract:

| Field | What to capture |
|-------|----------------|
| Job to be done | Functional + emotional + social outcome |
| Pain points | Frustrations with current approach |
| Trigger event | What changed that made them seek a solution |
| Desired outcome | Success in their words |
| Language | Exact phrases — not paraphrases |
| Alternatives | What else they considered or tried |

### Step 4: Synthesize

1. Cluster by theme across sources
2. Score frequency × intensity
3. Segment by customer profile
4. Identify 5-10 money quotes per theme
5. Flag contradictions

Label every insight with confidence:

| Confidence | Criteria |
|------------|----------|
| High | 3+ independent sources, unprompted, consistent |
| Medium | 2 sources, or prompted, or limited segment |
| Low | Single source, may be outlier |

### Step 6: Deliver

Ask user which format:

1. **Synthesis report** — themes, quotes, patterns, implications
2. **VOC quote bank** — verbatim quotes by theme for copy
3. **Persona document** — 1-3 personas (min 5 data points each)
4. **JTBD map** — functional, emotional, social jobs by segment
5. **Competitive intel** — what customers say about competitors
6. **Gap analysis** — what you still don't know

### Step 7: Update Context

Write key findings into `.agents/product-marketing.md` Section 6 (Competitive Landscape) and Section 9 (Customer Language).

## Persona Rules

- Minimum 5 data points from consistent segment before building
- Include: profile, JTBD, triggers, pains, outcomes, objections, vocabulary
- Anti-patterns: cute names, averaging across segments, invented details
- Revisit quarterly

## Verification Checklist

- [ ] `.agents/product-marketing.md` read (or created)
- [ ] RESEARCH GATE: All 4 questions answered (goal, assets, segment, deliverable)
- [ ] User explicitly confirmed each choice (not assumed)
- [ ] Mode selected (analyze existing or digital watering holes)
- [ ] Extraction done: JTBD, pains, triggers, language, alternatives
- [ ] Synthesis complete: clustered, scored, confidence-labeled
- [ ] Minimum 5 data points per persona (if personas created)
- [ ] Money quotes captured verbatim (not paraphrased)
- [ ] Findings written into product-marketing.md Sections 6 and 9

## Related Skills

| Skill | When to use |
|-------|-------------|
| product-marketing | First — set up context before research |
| showcase | After research — generate assets informed by findings |
| social-copy | For copy specifically informed by customer language |
| email-drip | For email sequences using research-backed messaging |
