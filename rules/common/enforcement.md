# Enforcement Rules

> Mechanical enforcement — pre-action checklist, mutation approval, PR review gate.

---

## Rule 0d: Pre-Action Checklist + Branch Interview (MECHANICAL)

**Before ANY edit, creation, or deletion of files — MANDATORY: run pre-flight, then interview the user about branch strategy.**

### Step 1 — Run Pre-Flight

This repo: `bash scripts/pre-flight.sh`
Any repo: `git status && git fetch --dry-run && git branch --show-current`

### Step 2 — Present State & Ask

After pre-flight, PRESENT the state and ASK the user about branch intent:

```
Git state: [branch] [clean/dirty] [up-to-date/behind] [upstream]
→ "You're on [branch]. Stay here, create a feature branch, or switch?"
```

**Decision matrix:**

| Pre-flight result | Agent action |
|---|---|
| Clean + correct branch + up to date | Ask: "Stay on [branch] or create feature branch?" |
| Dirty working tree | Ask: "Commit, stash, or discard changes?" |
| Behind remote | Ask: "Run pull --rebase now?" |
| Wrong branch | Ask: "Switch to [target] or create new branch?" |
| Detached HEAD | Ask: "Create branch from here or checkout main?" |

No assumptions. Always ask. The user knows where they want to be.

### Step 3 — Edit Guard (BLOCKING for every edit)

Run `bash scripts/edit-guard.sh` before and after every file edit. See AGENTS-EXTENDED.md for full preflight/verify/check protocol.

**Design gate:** `bash scripts/design-gate.sh` (BLOCKING if change touches design or visual assets)

### Step 4 — Edit-to-Commit Barrier (BLOCKING)

After completing edits, the agent MUST STOP before any git add/commit. No commit without a Commit Manifest. See AGENTS-EXTENDED.md for full Commit Manifest Protocol, time-window approval, and batch-mode prevention rules.

---

## Rule 12: Mutation Approval Gate (ABSOLUTE)

**No git operation that mutates the repository without explicit user approval.**

### Guardian Pattern — MANDATORY DECISION POINT

Before ANY mutation, present the DECISION POINT block (see AGENTS-EXTENDED.md for template). Wait for explicit "yes" / "sí" / "commit" / "proceed". **Invalid:** "ok", "mmhm", "sigamos", "dale", "continue", silence, emoji reactions.

### Rules:
- **NEVER batch approval.** Previous approval does not transfer. Every mutation is a separate decision.
- **Commit and push are SEPARATE decisions.** Plan approval ≠ commit approval ≠ push approval.
- **All git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.
- **Plan and commit are ALWAYS separate decisions.** Present the plan first → get approval → execute. Then present the commit manifest + test results → get approval → commit.
- **"yes commit" = commit approval.** When user types "yes commit" in chat, agent runs `commit-approval.sh` and commits.
- **"yes push" = push approval.** When user types "yes push" in chat, agent pushes.

### MECHANICAL ENFORCEMENT (time-window based):

A `commit-msg` git hook blocks `git commit` unless a `.git/COMMIT_APPROVED` file exists with a timestamp less than 5 minutes old and a matching commit message. The agent writes this file ONLY after getting explicit "yes commit" from the user in chat.

```
Flow:
1. Agent: presents DECISION POINT (manifest + diff + test results)
2. User: "yes commit" in chat
3. Agent: bash scripts/commit-approval.sh "feat: message" → writes .git/COMMIT_APPROVED
4. Agent: git commit -m "feat: message"
5. Hook: checks file exists, <5 min old, message matches → allows
6. File is deleted after successful commit (no reuse)
```

The hook is a safety net, not the primary enforcement. The primary enforcement is the agent's behavioral compliance with Rule 12. The escape hatch (`OVERRIDE: reason` in commit message body) allows bypassing for emergencies, logged to `.git/OVERRIDE_LOG`.

See AGENTS-EXTENDED.md for full Commit Manifest Protocol and time-window details.

---

## Rule 12b: PR Review Gate (MECHANICAL)

Before any PR merge: run `bash scripts/pr-review-checklist.sh <PR_NUMBER>`. FAIL → fix. WARN → review manually. PASS → proceed. See AGENTS-EXTENDED.md for full checklist contents.
