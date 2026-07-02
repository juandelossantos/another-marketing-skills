# HEALTH-CHECK: another-marketing-skills

> **Version:** 3.0 | **Date:** 2026-07-02 | **Status:** BUILD — Fase 0-1 Complete, 2 skills shipped
> **Project:** `another-marketing-skills` — AI agent skill system for product promotion

---

## Project Identity

| Field | Value |
|-------|-------|
| **SOUL.md** | ✅ Propia (no symlink) |
| **AGENTS.md** | ✅ Existente |
| **VERSION** | 0.1.0 (propia — ya no hereda) |
| **MASTER_PLAN.md** | ✅ v2.1, 1448 líneas |
| **Git repo** | ✅ Inicializado + pushed a GitHub (SSH) |
| **SPEC.md** | ✅ Creado (10 secciones) |
| **DESIGN.md** | ✅ Creado (tokens + wireframes + lock) |
| **Stack** | N/A (skills de contenido, no aplicación) |

---

## Skill Inventory

| Skill | Status | SKILL.md | references/ | evals/ | tools/ needed | Eval tests |
|-------|--------|----------|-------------|--------|---------------|------------|
| product-marketing | ✅ v1.0 (active) | 116 lines | 2 guides | trigger + golden + adversarial | None | 4 trigger ✓ full coverage |
| showcase | ✅ v1.0 (active) | 150 lines | 9 guides (audio, tone, quality, distribution, 5 format refs) | trigger + golden + adversarial | hyperframes CLI, Pixabay CC0 | 4 trigger ✓ full coverage |
| customer-research | ❌ No creado | — | — | — | None | — |
| social-copy | ❌ No creado | — | — | — | Buffer | — |
| email-drip | ❌ No creado | — | — | — | SendGrid (v2) | — |
| launch-plan | ❌ No creado | — | — | — | None | — |
| marketing-plan | ❌ No creado | — | — | — | None | — |
| seo-foundation | ❌ No creado | — | — | — | None | — |
| customer-research | ❌ No creado | — | — | — | Ninguno | — |
| social-copy | ❌ No creado | — | — | — | Buffer | — |
| email-drip | ❌ No creado | — | — | — | SendGrid (v2) | — |
| launch-plan | ❌ No creado | — | — | — | Ninguno | — |
| marketing-plan | ❌ No creado | — | — | — | Ninguno | — |
| seo-foundation | ❌ No creado | — | — | — | Ninguno | — |

---

## Infrastructure

| Component | Status | Notes |
|-----------|--------|-------|
| `scripts/skill-lint.sh` | ✅ Existente | Heredado de another-agent-skills |
| `scripts/skill-gate.sh` | ✅ Existente | Heredado |
| `scripts/edit-guard.sh` | ✅ Existente | Heredado |
| `scripts/design-gate.sh` | ✅ Existente | Heredado |
| `scripts/commit-approval.sh` | ✅ Existente | Heredado |
| `scripts/pre-flight.sh` | ✅ Existente | Heredado |
| `scripts/task-manifest.sh` | ✅ Existente | Heredado |
| `scripts/pr-review-checklist.sh` | ✅ Existente | Heredado |
| `scripts/eval/` | ✅ 9 scripts | Copiado de another-agent-skills |
| `install.sh` | ✅ Linux/macOS | Cross-platform, relative symlinks |
| `install.ps1` | ✅ Windows | PowerShell, directory junctions |
| `.opencode/skills/` | ✅ product-marketing, showcase | Symlinks |
| `.agents/skills/` | ✅ product-marketing, showcase | Symlinks |
| `.claude/skills/` | ✅ product-marketing, showcase | Symlinks |
| `scripts/content-lint.sh` | ✅ 271 lines | Banned words, CTA, platform limits, audio bitrate, scannability |
| `scripts/voice-lint.sh` | ✅ 168 lines | Brand voice compliance against product-marketing.md |
| `scripts/showcase-gate.sh` | ✅ 103 lines | Blocks generation unless all 7 interview questions answered |
| `scripts/banned-words.txt` | ✅ 41 terms | Streamline, elevate, seamless, etc. |
| `tools/REGISTRY.md` | ❌ No creado | Necesario para Fase 1 |
| `tools/clis/` | ❌ No creado | CLI wrappers para APIs |
| `tools/integrations/` | ❌ No creado | Guías por API |
| `.claude-plugin/` | ❌ No creado | Necesario antes de release |
| Landing page (`docs/`) | ❌ No creado | Necesario para Fase 1b |

---

## Meta-Skills: Skill Creation & Improvement (PRIMARY)

| Meta-Skill | Status | Location | Applies When |
|------------|--------|----------|--------------|
| **`skill-creator`** | ✅ Global (Claude plugin cache) | `skills/skill-creator/` | **Generate each marketing skill**: describe workflow → SKILL.md + 7 eval cases (trigger.jsonl, golden.jsonl, adversarial.jsonl). Always sets tier=draft |
| **`skill-improver`** | ✅ Global (GitHub) | `skills/skill-improver/` | **Improve existing skills**: diagnose eval failures → classify 6 patterns → propose diffs. Never auto-applies |

**Flow for every marketing skill:**
```
skill-creator → customize → run-evals → skill-improver → human approve
```

## Eval System (4 Failure Modes)

| Mode | File | Tests |
|------|------|-------|
| Trigger | `evals/trigger.jsonl` | 2+ positive + 1+ negative activation tests |
| Execution | `evals/golden.jsonl` | 2+ cases with quality rubric |
| Token Budget | `skill-lint.sh` | SKILL.md < 5000 tokens (automated) |
| Regression | `evals/adversarial.jsonl` | Rephrasing + boundary + edge cases |

**Run:** `bash scripts/eval/run-evals.sh --all` (8 trigger tests, 2 skills)

## Design Review Toolchain (POST-CREATION)

| Skill | Status | Phase | Applies When |
|-------|--------|-------|--------------|
| `audit-skill` | ✅ Global | Post-build audit | Score 5 marketing dimensions P0-P3 on generated output |
| `critique-skill` | ✅ Global | Post-build review | Heuristic eval + AI slop on generated content |
| `hard-skill` | ✅ Global | Post-audit fix | P0/P1 mechanical fixes from audit |
| `polish-skill` | ✅ Global | Post-audit fix | Visual consistency, token compliance |
| `typeset-skill` | ✅ Global | Post-creation | Typography/reading rhythm |
| `clarify-skill` | ✅ Global | Post-creation | Copy clarity and UX |
| `code-review-and-quality` | ✅ Global | Pre-merge | Review each SKILL.md |
| `code-simplification` | ✅ Global | Post-build | Reduce unnecessary complexity |
| `output-skill` | ✅ Global | All phases | Prevent truncated output |
| `doubt-driven-development` | ✅ Global | All decisions | Adversarial review |

**Note:** Audit/critique skills adapted for marketing via 5 dimensions: Brand Voice, Platform Rules, Persuasion Structure, Readability, AI Slop.

## Guardrails Verification

| Guard | File | Status | How to Verify |
|-------|------|--------|---------------|
| Pre-flight | `scripts/pre-flight.sh` | ✅ | `bash scripts/pre-flight.sh` |
| Skill gate | `scripts/skill-gate.sh` | ✅ | `bash scripts/skill-gate.sh check` |
| Edit guard | `scripts/edit-guard.sh` | ✅ | `bash scripts/edit-guard.sh preflight` |
| Design gate | `scripts/design-gate.sh` | ✅ | `bash scripts/design-gate.sh` (before visual work) |
| Commit approval | `scripts/commit-approval.sh` | ✅ | `bash scripts/commit-approval.sh <msg>` |
| PR review | `scripts/pr-review-checklist.sh` | ✅ | `bash scripts/pr-review-checklist.sh <PR>` |
| Task manifest | `scripts/task-manifest.sh` | ✅ | `bash scripts/task-manifest.sh check` |
| Skill lint | `scripts/skill-lint.sh` | ✅ | `bash scripts/skill-lint.sh skills/<name>` |
| Content lint | `scripts/content-lint.sh` | ✅ | `bash scripts/content-lint.sh --file <output>` |
| Voice lint | `scripts/voice-lint.sh` | ✅ | `bash scripts/voice-lint.sh --file <output>` |
| Showcase gate | `scripts/showcase-gate.sh` | ✅ | `bash scripts/showcase-gate.sh` (blocks if unanswered) |
| Context budget (60/25/15) | Rule 8 | ✅ | Monitor message count, compact at >20 |
| Mutation approval (Rule 12) | enforcement.md | ✅ | DECISION POINT before every commit |

---

## Fase 0-1 Status (✅ Complete)

### Fase 0: Foundation
- [x] SPEC.md, DESIGN.md, .gitignore, README.md
- [x] Git repo + GitHub, 6 commits pushed
- [x] VERSION 0.1.0 (own, not inherited)
- [x] install.sh + install.ps1 (cross-platform)
- [x] scripts/eval/ — 9 scripts, full eval pipeline
- [x] Multi-agent symlinks (opencode, agents, claude)
- [x] CI configured (skill-lint on every push)

### Fase 1: Foundation Skills
- [x] `product-marketing` skill (tier: active, 116 lines)
  - 2 reference guides, 3 eval files, 4 trigger tests pass
- [x] `showcase` skill (tier: active, 150 lines)
  - 9 reference guides, 3 eval files, 4 trigger tests pass
  - 5 formats: video, carousel, reel, social post, ad copy
  - Mechanical interview gate (7 mandatory questions)
  - Content quality gate (content-lint.sh)
  - Brand voice gate (voice-lint.sh)
  - 41 banned terms enforced
  - CC0 music sources documented
  - HTML template for Hyperframes compositions
  - Build helper script

## Next Up (Fase 2: Content Skills)

- [ ] `customer-research` skill — VoC extraction, audience research
- [ ] `social-copy` skill — dedicated multi-platform copy tool
- [ ] `email-drip` skill — email sequences
- [ ] `launch-plan` skill — GTM timeline + content calendar
- [ ] `marketing-plan` skill — AARRR campaign planning
- [ ] `seo-foundation` skill — meta, structured data, AEO/GEO
- [ ] `tools/REGISTRY.md` scaffold
- [ ] Landing page (`docs/`) — deferred until 4+ skills

---

*Run `project-health-check` skill for full audit. Update this file after each Fase completion.*
