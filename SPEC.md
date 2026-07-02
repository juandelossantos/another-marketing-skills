# Spec: another-marketing-skills

## Objective

Open-source AI agent skill system that turns any agent into a senior marketing specialist — researching, planning, creating, and distributing promotional content across formats and platforms with mechanical discipline. For developers, founders, and creators who build with AI agents but struggle to promote what they ship.

## Research Context

- **Domain insight:** 66% of marketers use AI, 68% report positive ROI (HubSpot 2025). 35% cite fragmented tools as their top barrier. The market needs unified, agent-native promotion — not more disconnected tools.
- **Pattern reference:** `latent-spaces/brag` proves single-format agent skill works (video). `coreyhaines31/marketingskills` proves 45-skill ecosystem with evals and tool registry. Our extension: multi-format from one input + distribution layer.
- **Risks identified:** API changes (Hyperframes, Buffer, Canva), user lacks FFmpeg/Node, Canva API requires Enterprise, brand voice extraction is subjective, AI copy sounds generic.

## Architecture Decisions

- **Chosen:** Modular monolith with capability layers + tool registry. Each skill follows `another-agent-skills` pattern: SKILL.md + references/ + evals/ + scripts/. Shared `product-marketing.md` as foundation context consumed by all skills.
- **Rejected:** Monolithic engine (too coupled, violates lazy-loading). Plugin registry (over-engineered for v1).
- **Trade-offs accepted:** Multi-format showcase is complex but the core differentiator. Distribution requires external API keys (Buffer, Hyperframes). Context budget (SKILL.md <250 lines) limits detail in main file but forces lazy-loaded references.

## Tech Stack

- **Landing page:** Vite 8.0.14 + React 19.2.6 + Tailwind CSS 4.3.0 + react-i18next + react-router-dom (HashRouter)
- **Skills:** Markdown-based SKILL.md (no compile step), optional Node.js CLI wrappers in tools/clis/
- **Testing:** Eval system (trigger.jsonl, golden.jsonl, adversarial.jsonl) per skill, run via `bash scripts/eval/run-evals.sh`
- **CI/CD:** GitHub Actions (build + deploy to gh-pages)
- **Hosting:** GitHub Pages
- **External APIs:** Hyperframes (video), Buffer (distribution), Canva (design), ElevenLabs (voice), Pixabay (media)

## Commands

```bash
# Skill lint (validate skill structure)
bash scripts/skill-lint.sh skills/<name>/

# Run evals for all skills
bash scripts/eval/run-evals.sh --all

# Run evals for specific skill
bash scripts/eval/run-evals.sh --skill <name>

# Pre-flight check
bash scripts/pre-flight.sh

# Task manifest check
bash scripts/task-manifest.sh check

# Skill gate registration
bash scripts/skill-gate.sh mark <skill-name>

# Landing page dev (docs/)
cd docs && npm run dev

# Landing page build
cd docs && npm run build
```

## Project Structure

```
another-marketing-skills/
├── AGENTS.md              # Agent instructions
├── AGENTS-EXTENDED.md     # Extended rules reference
├── SOUL.md                # Project identity
├── SPEC.md                # This file
├── DESIGN.md              # Landing page design
├── HEALTH-CHECK.md        # Project state
├── VERSION                # Project version
├── VERSIONS.md            # Per-skill changelog
├── README.md              # Quick start + install
├── CONTRIBUTING.md        # How to add skills
├── LICENSE                # MIT
├── install.sh             # Auto-installer
├── .gitignore
├── scripts/               # Mechanical enforcement
│   ├── skill-lint.sh
│   ├── skill-gate.sh
│   ├── edit-guard.sh
│   ├── design-gate.sh
│   ├── commit-approval.sh
│   ├── pre-flight.sh
│   ├── task-manifest.sh
│   └── pr-review-checklist.sh
├── skills/                # Marketing skills (Fase 1-3)
│   ├── product-marketing/
│   ├── showcase/
│   ├── customer-research/
│   ├── social-copy/
│   ├── email-drip/
│   ├── launch-plan/
│   ├── marketing-plan/
│   └── seo-foundation/
├── tools/
│   ├── REGISTRY.md
│   ├── clis/
│   └── integrations/
├── docs/                  # Landing page (Vite 8 + React 19 + Tailwind 4)
├── rules/                 # Enforcement rules
├── state/                 # Project state (current_stage, etc.)
└── development/           # Dev artifacts (gitignored)
```

## Code Style

- SKILL.md: YAML frontmatter, <250 lines, "When to Use" + "Verification Checklist" sections, cross-reference table at end
- Scripts: Bash with error handling, POSIX-compatible where possible
- CLI tools (Node.js): Zero-dependency, `--dry-run` flag, colored output, exit codes
- Language: English (skills), bilingual EN/ES (landing page)
- No commented-out code. No speculative abstractions. Surgical changes only.

## Testing Strategy

- **Eval system** per skill: trigger.jsonl (2+ positive, 1+ negative), golden.jsonl (2+ cases with rubric), adversarial.jsonl (rephrase + boundary + edge)
- **Skill lint:** `bash scripts/skill-lint.sh` validates structure, frontmatter, line count
- **Quality audit:** 5 marketing dimensions (Brand Voice, Platform Rules, Persuasion, Readability, AI Slop) scored P0-P3
- **Manual verification:** Each skill tested with example product before marking complete

## Acceptance Criteria

- [ ] Fase 0: .gitignore, SPEC.md, DESIGN.md exist, git repo initialized with first commit
- [ ] Fase 1: `product-marketing` and `showcase` skills generated via skill-creator, evals pass, audit clean
- [ ] Fase 1b: Landing page deployed to GitHub Pages with dark/light mode, EN/ES i18n, all sections rendering
- [ ] Fase 2: `customer-research`, `social-copy`, `email-drip` skills created with guides and evals
- [ ] Fase 3: `launch-plan`, `marketing-plan`, `seo-foundation` skills created
- [ ] Fase 4: All skills lint + eval pass, README + docs complete, v1.0 released
- [ ] All outputs pass 5-dimension marketing quality audit before marking complete
- [ ] No mutation without DECISION POINT (Rule 12 enforced)

## Boundaries

- Out of scope: CRO, ads management, pricing, AB testing, churn prevention, referrals, community marketing, revops, sales enablement, cold email, ASO, public relations
- Phase 2 (future): Analytics-narrative skill (GA4/PostHog)
- Won't do: Replace HubSpot or become a full marketing suite. We build the promotion flywheel only.

## Dependencies

- [ ] User approval of MASTER_PLAN.md (done)
- [ ] Git repository initialized (Fase 0)
- [ ] GitHub remote configured (post-Fase 0)
- [ ] docs/ has GitHub Pages enabled in repo settings

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Hyperframes API changes | Medium | High | Abstract behind wrapper script, pin version |
| Buffer API rate limits | Low | Medium | Queue + retry, cache auth tokens |
| User lacks FFmpeg/Node | High | High | `skill-deps.sh` checks and guides install before create |
| Canva API requires Enterprise | High | Medium | Fallback: HTML→Puppeteer→PNG |
| Brand voice extraction subjective | Medium | Medium | Structured rubric + human review gate |
| AI copy sounds generic | Medium | High | Brand voice chart + competitor analysis + VoC extraction before generation |

## Timeline

- **Fase 0 (Week 0):** .gitignore, SPEC.md, DESIGN.md, git init
- **Fase 1 (Weeks 1-2):** product-marketing + showcase skills + evals
- **Fase 1b (Weeks 2-3):** Landing page (Vite + React + Tailwind + GH Pages)
- **Fase 2 (Weeks 3-5):** customer-research, social-copy, email-drip
- **Fase 3 (Weeks 5-7):** launch-plan, marketing-plan, seo-foundation
- **Fase 4 (Weeks 7-8):** Polish, README, release v1.0

## Notes

Reference: `development/MASTER_PLAN.md` for full research, competitive analysis, and detailed per-skill blueprints. This spec is the contract — MASTER_PLAN.md is the context.
