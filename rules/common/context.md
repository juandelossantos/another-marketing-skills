# Context Rules

> Token and context management — compression, lazy loading, context budget.

---

## Rule 0e: Context Compression & Eviction

**Agent context is finite. Evict before you drown.**

### Eviction Triggers

| Trigger | Action |
|---|---|
| History > 20 messages | Summarize to 3 key points. Remove "ok"/"proceed" confirmations. |
| SESSION_CONTEXT > 50 lines | Archive old entries. Keep only last 3 sessions + current. |
| Files open > 5 | Close oldest. Re-open on-demand if needed. |
| Context > 70% full | Stop loading guides. Reference by name only. |
| AGENTS.md references | If full rule not needed, reference: "See AGENTS-EXTENDED.md" |

### Compression Techniques
- Replace long examples with "See EXAMPLES.md"
- Replace full tables with "See AGENTS-EXTENDED.md"
- Remove successful build outputs (keep pass/fail only)
- Remove repeated confirmations
- Archive: Move old session context to `development/ARCHIVE_YYYY-MM.md`

**Never evict:** Active skill content, user code, errors being debugged, pending decisions.

---

## Rule 0f: Plugin Architecture

**OpenCode native plugin auto-fires enforcement on critical events.**

The `agent-discipline` plugin (`.opencode/plugins/agent-discipline/`) provides mechanical enforcement via event-driven hooks:

| Event | Hook | Purpose |
|---|---|---|
| `file.edited` | edit-guard | Structural integrity, line count delta < 20% |
| `tool.execute.before` | pre-flight | Git state check before risky commands |
| `tui.command.execute` | commit-approval | Mutation gate for commit/push/merge |
| `session.compacted` | anti-slop | Re-inject core principles after context eviction |

Shell scripts in `scripts/` remain as fallback for non-OpenCode agents.

---

## Rule 6: Lazy Loading

**Skills load on-demand, not eagerly.**

1. **Skill as Index** (~250 lines max): When to use, stack lock-in, phase summaries, QA gates.
2. **Guides as Lazy Content**: Loaded only when phase reached. See AGENTS-EXTENDED.md for guide list.
3. **Foundation loaded once**: `engineering-fundamentals` implicit. Not duplicated.

**Verification:** Every skill < 250 lines (micro-skills < 100 exempt from 2-guide rule). Every skill references ≥ 2 guides. No detail duplicated between SKILL.md and guides.

---

## Rule 8: Context Budget

**Agent has limited context. Spend it wisely.**

| Priority | % | Content |
|---|---|---|
| High | 60% | Current code, problem analysis, response to user |
| Medium | 25% | Active skill + AGENTS.md essential |
| Low | 15% | Old history, inactive guides |

**If context > 80%:**
1. Summarize old history in 3 key points
2. Unload guides unused in last 3 interactions
3. Prioritize: code > instructions > history

**Compaction (history > 20 messages):**
- Keep: Errors, architecture decisions, approved design tokens, current code
- Remove: Build outputs (pass/fail only), "ok"/"proceed" messages, repeated instructions
