# Skill Rules

> Skill execution, intent mapping, lifecycle.

---

## Rule 1: Skills First

For EVERY request:
1. Determine if any skill applies (even 1% chance)
2. If yes → Invoke it using the `skill` tool
3. NEVER implement directly if a skill applies
4. ALWAYS follow the skill exactly

**Skill Hierarchy:** Foundation → Frontend → Backend → DevOps → Process → Quality → Metrics. See AGENTS-EXTENDED.md for full table.

Platform skills are built on `engineering-fundamentals`. Never invoke `engineering-fundamentals` directly.

---

## Rule 2: Intent Mapping

**Detect platform/skill BEFORE acting:**

| User says... | Skill / Guide |
|---|---|
| "web", "landing", "React", "Vue" | `frontend-web` |
| "PWA", "offline", "Capacitor" | `frontend-pwa` |
| "mobile app", "React Native", "Flutter" | `frontend-mobile` |
| "desktop", "Tauri", "Electron" | `frontend-desktop` |
| "CLI", "terminal", "command line" | `cli-tools` |
| "multi-agent", "orchestrate", "parallel tasks" | `multi-agent-orchestration` |

**If platform unclear** → Ask: "Web, PWA, mobile, desktop, or CLI?"

**If user has profile** → Use `preferences.primary_platform` to default skill.

## Multi-Agent Routing

**Trigger:** >2 agents, multi-file refactor, or user says "parallel"/"split the work".

Load `multi-agent-orchestration` before delegating.

### Orchestrator Protocol

1. **Detect** — Check file overlap. Overlap? → sequential. Clear? → parallel.
2. **Decompose** — Non-overlapping sub-tasks, explicit file assignments.
3. **Prepare** — Each subagent gets: file paths, interface contracts, relevant skill only.
4. **Delegate** — `task` tool: `general` (coder) or `explore` (researcher).
5. **Collect** — Verify each result independently.
6. **Integrate** — Merge. Build. Test.
7. **Commit** — Only Orchestrator (Rule 12). Subagents never touch git.

See `skills/multi-agent-orchestration/GUIDE.md` for examples, error recovery, and boundaries.

---

## Rule 3: Lifecycle

```
DEFINE  → project-health-check (if existing code)
        → spec-driven-development (always)
        → architecture-analysis (if non-trivial)
        → backend-api-mastery (if API needed)
        → frontend-[platform] (if UI needed)
        → git-init-and-versioning (once, after contracts locked)

PLAN    → planning-and-task-breakdown

BUILD   → incremental-implementation
        → test-driven-development
        → code-review-and-quality (pre-commit checklist)
        → git-workflow-and-versioning

VERIFY  → debugging-and-error-recovery

REVIEW  → code-review-and-quality

SHIP    → shipping-[platform]
```

**Project shortcuts:** See AGENTS-EXTENDED.md for full project-type matrix.

### Purpose-Driven Execution

**When beginning work, check `.sessionrc` or ask: "What are we doing today?"**

| Purpose | Priority Skills |
|---|---|
| **Brainstorming** | `idea-refine`, `architecture-analysis` |
| **Development** | `spec-driven-development`, `test-driven-development`, `incremental-implementation` |
| **Code Review** | `project-health-check`, `code-review-and-quality` |
| **PR Review** | `git-workflow-and-versioning`, `code-review-and-quality` |
| **Debugging** | `debugging-and-error-recovery`, `test-driven-development` |

**How it works:** `init-agents` creates `.sessionrc` with default purpose from user profile. Agent reads `.sessionrc` at session start. Skills weighted by purpose (not filtered — just prioritized).

**`.sessionrc` is NOT git-tracked.**
