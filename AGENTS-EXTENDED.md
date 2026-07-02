# AGENTS-EXTENDED.md

> **What this is:** Extended reference for rules, tables, and details removed from AGENTS.md for context efficiency.  
> **When to load:** When agent needs full detail on a specific rule, or user asks "what are all the rules?"  
> **How to use:** Reference from AGENTS.md core. Load on-demand only.

---

## Rule 0c: Behavioral Principles (Extended)

**P1 Think Before Coding** — State assumptions. Don't guess. Push back if simpler. Ask when confused. → `interview-me`, `spec-driven-development`

**P2 Simplicity First** — Minimum code. No speculative abstractions, flexibility, or error handling for impossible scenarios. "Would a senior call this overcomplicated?" → `engineering-fundamentals`, `code-simplification`

**P3 Surgical Changes** — Touch only what you must. Don't improve adjacent code. Match existing style. Remove only what YOUR changes made unused. → `git-workflow-and-versioning`

**P4 Goal-Driven Execution** — "Fix bug" → "Reproduce with test, then fix." Define pass criteria. Verify each step. → `test-driven-development`, `incremental-implementation`

---

## Rule 1: Skill Hierarchy (Full Table)

| Layer | Skills | Purpose |
|---|---|---|---|
| **Foundation** | `engineering-fundamentals` | Discovery, contracts, anti-slop, quality gates |
| **Frontend** | `frontend-web`, `frontend-pwa`, `frontend-mobile`, `frontend-desktop` | Web, PWA, native mobile, desktop |
| **Backend** | `backend-api-mastery` | API, DB, auth |
| **DevOps** | `fullstack-shipping` | CI/CD, deploy |
| **Process** | `spec-driven-development`, `architecture-analysis`, `planning-and-task-breakdown` | Planning, analysis |
| **Quality** | `project-health-check`, `code-review-and-quality`, `dev-environment-audit` | Auditing, review |
| **Design Review** | `critique-skill`, `audit-skill`, `clarify-skill`, `hard-skill`, `polish-skill`, `typeset-skill`, `adapt-skill`, `optimize-skill`, `delight-skill` | Heuristic review → audit → fix → delight |
| **Metrics** | `project-metrics` | Quality logging (background) |
| **Git** | `git-init-and-versioning`, `git-workflow-and-versioning` | Setup, workflow |
| **Debug** | `debugging-and-error-recovery` | Root cause analysis |
| **Ideation** | `idea-refine`, `interview-me` | Brainstorming, requirements |
| **Design Skins** | `industrial-brutalist-ui`, `minimalist-ui`, `soft-premium-ui`, `output-skill`, `redesign-skill` | Visual direction and output enforcement |

### Skill Gate Enforcement (MECHANICAL)

**Rule 1 is enforced mechanically, not just behaviorally.**

The `skill-gate.sh` script provides filesystem-level verification that skills were consulted:

```bash
# Check if skills were loaded (used by pre-commit hook)
bash scripts/skill-gate.sh check

# Mark that skills were consulted (agent runs this after loading skills)
bash scripts/skill-gate.sh mark <skill-name>

# Reset for new session
bash scripts/skill-gate.sh reset
```

**How it works:**
1. Agent loads skills via `skill()` tool during session start
2. Agent runs `skill-gate.sh mark <skill-name>` to register consultation
3. Pre-commit hook runs `skill-gate.sh check` before allowing commits
4. If no skills were consulted → commit is BLOCKED

**Why this is mechanical, not behavioral:**
- The `skill` tool loads skills into conversation context (invisible to shell)
- `skill-gate.sh` creates a filesystem marker (visible to shell)
- The pre-commit hook checks the marker (enforced by git)
- The agent cannot bypass the pre-commit hook without user approval

**Incident evidence:** This was created after INCIDENT_004/004b/004c where the agent bypassed Rule 1 and implemented code without loading skills. The behavioral rule alone was insufficient — mechanical enforcement was required.

---

## Rule 3: Project-Type Matrix (Full)

| Project | Required | Optional | Skipped |
|---|---|---|---|
| Landing page | spec, git-init, frontend-web | architecture (light) | backend-api |
| Web app | ALL | — | — |
| Mobile app | spec, git-init, frontend-mobile, backend (if API) | architecture (if complex) | — |
| API only | spec, git-init, architecture, backend, dev-env, shipping | — | frontend-* |
| Existing fix | health-check, spec, debugging | — | architecture, backend |
| Design system | spec, git-init, frontend, dev-env, shipping | architecture | backend-api |
| MVP/prototype | spec (turbo), git-init, frontend | — | architecture, backend (if no API) |
| Database migration | spec, backend, git-init, dev-env | testing | frontend-* |
| CLI tool | spec, git-init, dev-env, shipping | architecture | frontend-* |
| Open source lib | spec, git-init, dev-env, shipping, code-review | — | — |

---

## Multi-Agent Orchestration (Full Reference)

See `multi-agent-orchestration` SKILL.md + GUIDE.md for complete patterns.

### Agent Roles Summary

| Role | Subagent Type | Tool | Max | Description |
|---|---|---|---|---|
| Planner | `general` | `task` | 1 | Break down work, sequence, review |
| Coder | `general` | `task` | 3-5 | Parallel implementation |
| Researcher | `explore` | `task` | 2-3 | Codebase exploration |
| Reviewer | `general` | `task` | 1 | Post-build review |
| Auditor | `explore` | `task` | 1 | Pre-commit audit |

### Orchestration Patterns

| Pattern | Structure | When |
|---|---|---|
| Sequential | A → B → C | B depends on A output |
| Pipeline | Spec → Impl → Test → Review | Phase-gated flow |
| Parallel | A + B + C concurrently | Independent modules |
| Swarm | A\|B\|C same problem | Competitive exploration |

### Permission Boundaries

- Subagents can write/edit ASSIGNED files only. Files listed in prompt.
- Subagents never commit (Rule 12). Only Orchestrator.
- Subagents receive relevant skill SKILL.md + GUIDE.md only — never full AGENTS.md.
- Orchestrator verifies output BEFORE integration.

### Error Recovery

- Subagent failure → Orchestrator retries with corrected context
- Timeout → Split task smaller, re-launch
- Merge conflict → Orchestrator resolves, re-runs tests

---

## Rule 0d: Edit Guard Protocol (Full Reference)

### Before EVERY file edit (edit/write/create tool):

```
□ bash scripts/edit-guard.sh preflight <file> <marker> [marker...]
   — Verifies file exists and known structural markers are present.
   — REQUIRED markers for HTML files: at least 3 class/id markers from that file.
   — FAIL → File is corrupted. STOP. Recover from git or ask user.
□ bash scripts/edit-guard.sh count <file> "<exact oldString>"
   — Verifies oldString appears exactly once (edit tool will fail otherwise).
   — FAIL (0) → String not found. Read file to find actual text.
   — FAIL (>1) → Not unique. Add more context to oldString.
□ Read the file section to be edited (at minimum the target lines, ideally the full file).
□ wc -l <file> → record line count.
```

### AFTER each edit (immediately, before next tool call):

```
□ wc -l <file> → compare to pre-edit count. Difference > 20% → BLOCKING.
□ bash scripts/edit-guard.sh verify <file>
   — Compares line count with pre-flight baseline.
   — FAIL → Edit truncated/expanded file unexpectedly. STOP.
□ grep -Fc "<oldString>" <file> = 0 (old text removed)
□ grep -Fc "<newString>" <file> > 0 (new text present)
□ bash scripts/edit-guard.sh check <file> <same markers as preflight>
   — All structural markers still present. FAIL → sections were deleted. STOP.
□ If >50 lines changed: self-review every changed line.
```

### Design gate

`bash scripts/design-gate.sh` — BLOCKING if change touches design or visual assets (web, mobile, desktop, or any UI). Checks for DESIGN.md, design/DESIGN-LOCK.md, and `.opencode/.design-skill-loaded` BEFORE visual work starts.

---

## Rule 0d: Edit-to-Commit Barrier (Full Reference)

### Batch-Mode Prevention

This barrier exists specifically to prevent "batch-mode commits" — where multiple file edits flow naturally into a commit because the agent doesn't pause between editing and versioning.

**Common failure mode:** User says "fix these 5 things" → agent edits 5 files → agent commits all 5 as one batch without asking. The fix: after the last edit, STOP. Present manifest. Only commit after explicit approval. The edits were approved. The commit is not.

```
VALID:                             INVALID (batch-mode):
  msg: "Edits done. Manifest:"       msg: "Edits done."
  block: COMMIT MANIFEST             bash: token + git add + git commit
  bash: printf '...' | sha256sum
  user: "sí"
  bash: git add && git commit
```

Token generation (`sha256sum > .git/COMMIT_APPROVED`) and `git commit` MUST be in separate bash calls. Never in the same bash call.

---

## Rule 12b: PR Review Checklist (Full Reference)

The script `scripts/pr-review-checklist.sh` verifies:

- PR state (OPEN, mergeable, has reviews)
- Diff size (files changed ≤50 preferred)
- No secret files in diff
- Code WITH tests (warn if without)
- All SKILL.md files ≤250 lines
- Hooks have escape hatch and hash verification
- Commit messages are descriptive
- PR description is detailed

**Exit codes:** 0 = PASS, 1 = FAIL (fix before merge), 2 = WARN (review manually)

---

## Rule 6: Lazy Loading (Guide Reference)

**Guides by phase:** DISCOVERY → P1 | PROTOCOL → P3 | AUTH → P5 | ANIMATION → Animation | TESTING → Test | CICD → CI/CD | DEPLOY → Deploy | LAUNCH-CHECKLIST → Ship | EXAMPLES → Troubleshooting | BUILD-INTEGRATION → Git

**Rules:** Every skill < 250 lines | ≥ 2 guides per skill | Guides are separate files | No skill-guide duplication | `engineering-fundamentals` NOT duplicated in platform skills

---

## Rule 12: Mutation Approval Gate (Extended)

### What Requires Approval (Summary)

**ALL git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.

**No approval needed:** status, log, diff, show, branch (list), stash list, remote -v, config --list.

### User Override (Full)

User can disable this gate by saying:
- "Enable auto commit mode"
- "Don't ask me for commits"
- "Auto-push after commit"
- "I trust you with commits"
- "Allow all git operations"

**If user overrides:**
- Log metric: `LOG METRIC: override` — type: `mutation_approval_gate`
- Document in user profile: `workflow.mutation_approval = "auto_present"` or `"full_auto"`
- Still present mutations, but accept "ok" and "mmhm" as approval
- User can re-enable with: "Require approval again" or "Strict mode"

### Why Absolute by Default

| Without Gate | With Gate |
|---|---|
| "I assumed you wanted to commit" | "You explicitly approved every change" |
| 5 broken commits in a session | 1 clean commit with your knowledge |
| "Why is this in my repo?" | "You saw it before it was committed" |

### Plan and Commit are ALWAYS Separate

**The plan is about WHAT to do. The commit is about WHETHER to save it.** These are fundamentally different decisions.

| Decision | What it means | How to approve |
|---|---|---|
| **Plan** | "Yes, make these changes" | User says "yes" in chat |
| **Commit** | "Yes, save these changes to git" | User says "yes commit" in chat |
| **Push** | "Yes, send to remote" | User says "yes push" in chat |

**Never bundle plan + commit as one decision.** Even if the user approved the plan, the commit requires "yes commit".

**Keywords:**
- `yes` alone = plan approval only (no git operations)
- `yes commit` = commit approval (agent runs commit-approval.sh and commits)
- `yes push` = push approval (agent pushes to origin)

**Correct flow:**
1. Agent presents plan → user says "yes"
2. Agent executes plan
3. Agent presents Commit Manifest → user says "yes commit"
4. Agent runs `bash scripts/commit-approval.sh "msg"` (no prompt — approval is in chat)
5. Agent commits

**NEVER:** Agent commits without "yes commit" in chat. Chat history is the audit trail.

**Incorrect flow (violates Rule 12):**
1. Agent presents "I'll fix X and commit" → user says "yes"
2. Agent commits without "yes commit"
| Force-pushed lost history | History protected, every mutation approved |

**Anti-rationalization:** "The user seems impatient" → The user will be MORE impatient debugging changes they never approved.

---

## Anti-Rationalization (Full Table)

| Wrong Thought | Why It's Wrong |
|---|---|
| "This is too small for a skill." | Skills exist for structured thinking. |
| "I can just quickly implement this." | Check skills first. |
| "I'll gather context first." | Invoke the skill. It tells you what context to gather. |
| "The user didn't ask for a spec." | The skill decides what the project needs. |
| "I understand what they want." | You have 1% confidence. The skill forces 95%. |
| "Turbo mode means skip everything." | No. Skip OPTIONAL phases, not mandatory ones. |
| "The user chose a different stack, I can't help." | Principles are universal. Examples are specific. |
| "I'll add [quality] later." | Quality is a gate, not an afterthought. Add it now. |
| "The user is impatient, I'll skip [phase]." | The user will be more impatient when the result doesn't match expectations. |
| "I remember the design, I don't need to read files again." | Agent context drifts. Files are ground truth. |
| "I should just pick one interpretation and go." | Silent assumptions cause costly rewrites. State them. |
| "More code = more value." | No. More code = more maintenance, more bugs, more confusion. |
| "I'll improve this adjacent code while I'm here." | Scope creep in diffs. Touch only what the user asked. |
| "Make it work is enough." | Make it work, make it right, make it fast — in that order. |
| "The user already said yes before." | Every commit is a separate decision. Approval does not transfer. |
| "It's just a docs change." | Process violations have no size minimum. One unapproved line = violation. |
| "The user wants the fix fast." | Speed without consent is arrogance, not efficiency. |
| "We're iterating the same fix." | Each iteration modifies the repo. Each modification needs approval. |
| "It's too small to bother asking." | The Commit Manifest IS the process. Skipping it IS the violation. |
| "The user trusts me now." | Trust is verified per-commit. Previous trust does not waive the gate. |
| "I already showed the manifest once this session." | Previous approvals do not transfer. Every commit is a separate decision. |
| "I'm fixing bugs, not adding features — it's fine." | Process violations have no type minimum. A fix without approval is still a violation. |
| "I'll generate the token and commit, then tell the user." | Post-hoc notification is not approval. Present first, commit after. |
| "The user said 'continue' / 'sigamos' / 'dale'." | These are INVALID for commits. Only "yes", "sí", "commit", "proceed" are valid. |
| "I'm in flow, stopping would break momentum." | Speed without consent is arrogance, not efficiency. The gate exists for this exact moment. |
| "Critique is for designers, not devs." | Design quality affects every user. A 10-minute critique run prevents days of redesign. |
| "I'll ship first, audit later." | Post-ship findings rarely get fixed. Run audit before ship, not after. |
| "The UI works fine, it doesn't need delight." | Micro-interactions are not decoration — they communicate state changes. Missing feedback confuses users. |
| "I already know the design direction, I don't need to load a skill." | Knowledge drifts. The skill enforces a documented process with gates. If you skip loading it, there's no record that design was ever considered. |
| "I'll create DESIGN.md myself, I don't need the visual skill." | DESIGN.md written without the skill's discovery phase and anti-slop rules is just guesswork. The skill prevents the generic output you're trying to avoid. |
| "The design gate is just a script, I can skip it." | Skipping the design gate means shipping visual work without design approval. That's exactly the slop this project exists to prevent. The gate is your discipline. |

---

## Rule 12: Commit Manifest Protocol (MANDATORY)

**This is not optional. This is mechanical enforcement of Rule 12.**

### Before EVERY git commit, the agent MUST:

1. **STOP all action.** Do not type any git command yet.
2. **Output the Commit Manifest block exactly as shown below.**
3. **Wait for user's explicit typed approval.**
4. **Only then commit. Push is a SEPARATE decision after commit.**

### Commit Manifest Block

```
╔════════════════════════════════════════════════════════════╗
║  COMMIT MANIFEST — APPROVAL REQUIRED                     ║
╠════════════════════════════════════════════════════════════╣
║  Files changed: [list every file]                        ║
║  Lines changed: +X / -Y                                  ║
║  Commit message: "..."                                   ║
╠════════════════════════════════════════════════════════════╣
║  RULE 12 CHECKLIST:                                      ║
║  □ User's last message is "yes", "sí", or "commit"     ║
║  □ Previous approval does NOT transfer to this commit  ║
║  □ This is a SEPARATE decision from any previous commit  ║
╠════════════════════════════════════════════════════════════╣
║  USER MUST EXPLICITLY APPROVE THIS SPECIFIC COMMIT       ║
║  Valid responses: "yes" / "sí" / "commit" / "proceed"   ║
║  INVALID (do NOT accept): "ok" / "sigamos" / "continue" ║
║  / "dale" / silence / emoji reactions                    ║
╚════════════════════════════════════════════════════════════╝
```

### Session-Level Lock

**After ANY user approval, reset to "unapproved" state immediately.**

| User says | What is approved | Next commit requires |
|---|---|---|---|
| "yes" | ONE commit ONLY | New "yes" |
| "commit" | ONE commit ONLY | New "yes" |
| "proceed" | ONE commit ONLY | New "yes" |
| "ok" / "sigamos" / silence | NOTHING — INVALID | Explicit "yes" |

**There is NO session-level "approved mode." Every commit is a separate decision.**

### If Agent Commits Without Manifest

This is a **process violation** regardless of content quality.

**Agent must immediately:**
1. Stop all further commits
2. Report violation to user
3. Do NOT commit again until user explicitly confirms understanding
4. Log in `development/SESSION_CONTEXT.md` compliance log with ❌
5. User decides whether to revert, keep, or modify the commit

### Why Mechanical Enforcement

| Approach | Failure Rate | Why |
|---|---|---|
| "Remember Rule 12" | High | Memory fades after 20+ messages |
| "Check the checklist" | Medium | Agent checks mentally but doesn't verbalize |
| **Commit Manifest block** | **Low** | Visible, unskippable, user sees it |

**The manifest block is a speed bump. It is harder to ignore than a remembered rule.**

### Self-Check Before Manifest

Before manifest, agent MUST self-check: docs only? → NOT exempt. Fix only? → NOT exempt. Iteration? → NOT exempt. Already approved? → Does not transfer. <3 lines? → NOT exempt. Trust? → Does not waive gate. **No commit is exempt.**

### Time-Window Approval

**The agent writes approval AFTER user says "yes commit" in chat.** The flow:

1. Agent presents Commit Manifest + test results + diff
2. User says "yes commit" in chat
3. Agent runs `bash scripts/commit-approval.sh "msg" "file1.ts" "file2.ts"`
4. Script writes `.git/COMMIT_APPROVED` with timestamp
5. Agent commits
6. `commit-msg` hook verifies: file exists? <5 min old? message matches? → allows
7. File deleted after commit (no reuse)

**Why this works:**
| Without "yes commit" | With "yes commit" |
|---|---|
| Agent writes nothing (Rule 12 violation) | Agent writes COMMIT_APPROVED |
| Commit is blocked by hook | Commit proceeds |
| Chat history shows no approval | Chat history shows "yes commit" |

**Audit trail:** The conversation history is the primary audit trail. The time-window (5 min) prevents the agent from reusing old approvals. The escape hatch (`OVERRIDE: reason`) logs bypasses.

### Post-Commit Verification

### Push Decision (After Commit, Not Before)

Push is a **separate decision** from commit. After commit completes:

```
✅ Commit: abc1234
→ Push to origin/main? (yes / no / later)
```

- **yes**: push now
- **no / later**: commit stays local. Can accumulate multiple commits then push with explicit "push now"
- Push can be approved for multiple pending commits: "push all" or "push yes"

**Never push without asking.** The only exception is if user previously said "push now" for a pending commit.
