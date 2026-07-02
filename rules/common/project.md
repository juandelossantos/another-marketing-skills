# Project Rules

> Project-level rules — turbo mode, stack agnosticism, no code before contract, verification, language compliance, development artifacts.

---

## Rule 4: Turbo Mode

**For trivial/prototype work. Reduces scope, NOT discipline.**

**Activate when:** User says "prototype", "MVP", "just sketch it", or project is < 1 day.

**Reduces:** Research phase, extended discovery (10+ → 3 core questions), architecture analysis, Design Asset Lock (tokens only).

**Never reduces:** SPEC.md (minimal but complete), `.gitignore`, anti-slop rules, build verification, pre-commit checklist, no secrets committed.

---

## Rule 5: Stack Agnosticism

**Default:** React/Next.js/Tailwind (web), React Native/Expo (mobile), Tauri/Rust (desktop).

**Adapt when user specifies otherwise:** Read SPEC.md Tech Stack → adapt examples → create `STACK_CONFIG.md`.

---

## Rule 7: No Code Before Contract

**No file created until:**
- `SPEC.md` exists (for new features)
- `DESIGN.md` exists or confirmed as one-off (for UI)
- `API-DESIGN.md` exists or confirmed as simple CRUD (for backend)
- `.gitignore` exists

**Turbo exception:** Minimal SPEC.md (2-3 lines), minimal `.gitignore` (stack template).

---

## Rule 9: Verification

Before marking complete:
- [ ] Skill was invoked and followed completely
- [ ] Required artifacts (specs, plans, tests) exist
- [ ] User confirmed at each gate (or Turbo Mode)
- [ ] `.gitignore` covers stack
- [ ] No `.env` or secrets committed
- [ ] Build passes
- [ ] No hardcoded tokens outside design system

---

## Rule 10: Language Compliance

Detect language from user's prompt:
- Spanish keywords ("haz", "diseña", "crea") → **Spanish**
- English keywords ("build", "design", "create") → **English**
- Other → That language, fallback to English

**Never mix languages.**

---

## Rule 11: Development Artifacts Convention

When working on this repository (`another-agent-skills`):

**ALL draft, analysis, review, simulation, audit, roadmap, and refinement files MUST be created in `development/`.**

Examples: `SESSION_CONTEXT.md`, `SIMULATION.md`, `AUDIT_*.md`, `REVIEW_*.md`, `ROADMAP_*.md`

**Never** create these in the repo root or `skills/` folders.

**`.gitignore`**: `development/` is ignored globally.
