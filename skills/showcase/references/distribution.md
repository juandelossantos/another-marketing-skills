# Distribution

Two modes: Auto (API) or Manual (copy-paste).

## Mode A — Auto (Buffer API)

Requires `BUFFER_API_KEY` in environment.

```bash
# Schedule post
curl -X POST "https://api.buffer.com/1/updates/create.json" \
  -d "access_token=$BUFFER_API_KEY" \
  -d "text=Post body" \
  -d "profile_ids[]=PROFILE_ID" \
  -d "scheduled_at=2026-07-05"
```

**Flow:** Generate → ask "Post to which platforms?" → user confirms → Buffer API → report link.

## Mode B — Manual (share-copy.txt)

Write `share-copy.txt` with all generated content ready to copy-paste:

```markdown
# Share Copy — another-marketing-skills

## LinkedIn Post
[copy here — ready to paste]

## Twitter Thread
1/ [tweet]
2/ [tweet]

## Video
Rendered at: showcase-output/video.mp4
Caption: [copy]
```

Also write tool-specific instructions:
- "Paste this JSON into Canva"
- "Import this script into HeyGen"
- "Post this on LinkedIn manually"

## Quality gate (MANDATORY)

Before distributing, run content-lint and voice-lint on generated output:

```bash
bash scripts/content-lint.sh --file share-copy.txt
bash scripts/voice-lint.sh --file share-copy.txt
```

**If content-lint fails (exit 1):** Fix violations before distributing. Do not bypass.

**If voice-lint fails (exit 1):** Brand voice violation — fix vocabulary to match `.agents/product-marketing.md`.

## Quality checks

- [ ] share-copy.txt written (manual mode)
- [ ] Each piece has platform label
- [ ] No API keys leaked in output
- [ ] User confirmed before any automatic publish
- [ ] `bash scripts/content-lint.sh --file share-copy.txt` — PASS
- [ ] `bash scripts/voice-lint.sh --file share-copy.txt` — PASS
