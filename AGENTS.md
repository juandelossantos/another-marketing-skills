# AGENTS.md

> Version: see [VERSION](VERSION)
> Identity: see [SOUL.md](SOUL.md) — who we are, what we believe, what we never do.
> Rules: see `rules/common/` — behavioral, enforcement, context, skills, project.

## Skill-Driven Execution Model

**Always check skills first. Never implement directly if a skill applies.**

---

## Session Start Protocol (MANDATORY)

**Before ANY action or tool execution:**

1. Read AGENTS.md Rules 0 through 12
2. Check Git state: `git status && git fetch --dry-run && git branch --show-current`
3. **Skill Discovery (MANDATORY):**
   - Load `using-agent-skills` skill (OpenCode: `skill()` tool) or read `skills/using-agent-skills/SKILL.md` directly (other agents)
   - Identify which skill applies to the current task
   - Load the applicable skill
   - Run `bash scripts/skill-gate.sh mark <skill-name>` to register consultation
4. Present Guardian Pattern acknowledgment:

```
SESSION START [timestamp]
Branch: [current]
Skills: [loaded skill names]
Guardian Pattern: ACTIVE — Decision Points REQUIRED before any mutation
Protocol: Read AGENTS.md, skills loaded, no mutations without approval
→ Ready.
```

5. **DO NOT execute any tool without completing this protocol.**

**Failure is a Rule 1 + Rule 12 violation.** All mutations blocked without explicit user approval. Skills are not optional — they are the execution model.

---

## Rules Index

| Rule | File | Summary |
|---|---|---|
| 0, 0b, 0c, 0g, 0k | `rules/common/behavioral.md` | User profile, context persistence, behavioral principles, mayéutic challenge, universal first |
| 0d, 12, 12b | `rules/common/enforcement.md` | Pre-action checklist, mutation approval, PR review gate |
| 0e, 0f, 6, 8 | `rules/common/context.md` | Context compression, plugin architecture, lazy loading, context budget |
| 1, 2, 3 | `rules/common/skills.md` | Skills first, intent mapping, lifecycle |
| 4, 5, 7, 9, 10, 11 | `rules/common/project.md` | Turbo mode, stack agnosticism, no code before contract, verification, language, artifacts |

**Load rules on-demand per phase.** Always-loaded: this file (orchestrator) + SOUL.md (identity). Rules loaded when agent reaches that phase.

---

## Rule Summary (Quick Reference)

### Behavioral (→ `rules/common/behavioral.md`)
- **Rule 0:** Check user profile before any skill
- **Rule 0b:** Auto-recover context on project re-entry
- **Rule 0c:** Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven
- **Rule 0g:** Mayéutic Challenge — challenge non-trivial decisions, say "no" when justified
- **Rule 0h:** TOOL_GAP — When verification tools can't reach the world, report "ship status unknown" and STOP. Never fake a win on a gap.
- **Rule 0i:** Continuation Over Recap — After context loss, resume from last verified state. Don't recap everything. Ask "Where were we?" not "Let me summarize."
- **Rule 0j:** Task Manifest — Before executing any non-trivial task, write .git/TASK_MANIFEST with: files affected, edge cases, alternatives, risks. Run `bash scripts/task-manifest.sh check` to verify.

### Enforcement (→ `rules/common/enforcement.md`)
- **Rule 0d:** Pre-flight → branch interview → edit guard → commit barrier
- **Rule 12:** Guardian Pattern — DECISION POINT before every mutation. Invalid: "ok", "mmhm", silence
- **Rule 12b:** PR review gate — `pr-review-checklist.sh` before merge

### Context (→ `rules/common/context.md`)
- **Rule 0e:** Evict at 70%, compress history, never evict active work
- **Rule 0f:** Native plugin hooks for mechanical enforcement
- **Rule 6:** Skills as ~250-line indexes, guides on-demand
- **Rule 8:** 60/25/15 context budget, compaction at >20 messages

### Skills (→ `rules/common/skills.md`)
- **Rule 1:** Always check skills first. Skill hierarchy: Foundation → Frontend → Backend → DevOps → Process → Quality
- **Rule 2:** Intent mapping — detect platform before acting
- **Rule 3:** Lifecycle — DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP

### Project (→ `rules/common/project.md`)
- **Rule 4:** Turbo Mode — reduces scope, never discipline
- **Rule 5:** Stack Agnosticism — defaults with user override
- **Rule 7:** No code before SPEC.md, DESIGN.md, .gitignore
- **Rule 9:** Verification checklist before marking complete
- **Rule 10:** Language compliance — never mix languages
- **Rule 11:** Development artifacts go in `development/`

---

## Anti-Rationalization

See AGENTS-EXTENDED.md for full table (25+ common rationalizations and why they're wrong).

**Key reminders:**
- "I understand what they want." → You have 1% confidence. Skills force 95%.
- "Turbo mode means skip everything." → No. Skip OPTIONAL phases, not mandatory ones.
- "The user already said yes before." → Every commit is a separate decision.

---

## Skill Discovery

Skills loaded from:
- Project: `.opencode/skills/<name>/SKILL.md` (OpenCode) or `skills/<name>/SKILL.md` (universal)
- Global: `~/.config/opencode/skills/<name>/SKILL.md` (or `$AGENT_SKILLS_DIR/skills/<name>/SKILL.md`)
- Claude-compatible: `.claude/skills/<name>/SKILL.md`

**For full rules, anti-rationalization table, skill hierarchy, and guide list → See AGENTS-EXTENDED.md**

---

# >>> another-agent-skills-rules
# The following rules are from Another Agent Skills (github.com/juandelossantos/another-agent-skills)
# These rules ADD TO your existing workflow, they do not replace it.
# If there are conflicts between your existing rules and ours, follow BOTH:
# - Your project-specific rules take priority for project details
# - Our skill-driven rules take priority for workflow and quality
# <<< another-agent-skills-rules
