# HEALTH-CHECK: another-marketing-skills

> **Version:** 2.0 | **Date:** 2026-07-02 | **Status:** BUILD — Fase 0 Complete, Fase 1 in Progress
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
| product-marketing | ✅ v0.1 (draft) | 116 líneas ✓ | 2 (brand-voice, customer-language) | trigger + golden + adversarial | Ninguno | 4 trigger ✓ full coverage |
| showcase | ❌ No creado | — | — | — | Hyperframes, Buffer, Canva | — |
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
| `.opencode/skills/` | ✅ product-marketing | Symlink relativo |
| `.agents/skills/` | ✅ product-marketing | Symlink relativo |
| `.claude/skills/` | ✅ product-marketing | Symlink relativo |
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

**Run:** `bash scripts/eval/run-evals.sh --all` (4 trigger tests, 1 skill)

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
| Context budget (60/25/15) | Rule 8 | ✅ | Monitor message count, compact at >20 |
| Mutation approval (Rule 12) | enforcement.md | ✅ | DECISION POINT before every commit |

---

## Fase 0 Status (✅ Complete)

- [x] User approval of MASTER_PLAN.md
- [x] SPEC.md creation (10 sections)
- [x] DESIGN.md + DESIGN-LOCK.md creation
- [x] .gitignore creation (75 lines)
- [x] Git init + first commit
- [x] README.md (Mermaid diagrams, install, agent compat)
- [x] STACK_CONFIG.md configured for CI
- [x] VERSION set to 0.1.0 (propia)
- [x] install.sh + install.ps1 (cross-platform)
- [x] scripts/eval/ (9 scripts + schema)
- [x] Multi-agent symlinks (.opencode, .agents, .claude)
- [x] `product-marketing` skill (tier: draft, 116 lines)
- [x] Eval system: 4 trigger tests pass, full coverage

## Next Up (Fase 1)

- [ ] `showcase` skill (multi-format generator)
- [ ] `customer-research` skill
- [ ] `social-copy` skill
- [ ] `email-drip` skill
- [ ] `launch-plan` skill
- [ ] `marketing-plan` skill
- [ ] `seo-foundation` skill
- [ ] `tools/REGISTRY.md` scaffold
- [ ] Landing page (`docs/`) — deferred until 2+ skills

---

*Run `project-health-check` skill for full audit. Update this file after each Fase completion.*
