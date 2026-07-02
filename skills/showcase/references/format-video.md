# Video Format (Hyperframes)

Script + Hyperframes composition. Requires HEYGEN_API_KEY for rendering.

## Structure (15-25s)

```
Hook (2-3s) → Reveal (2-4s) → Highlights (5-12s) → Outro (2-4s)
```

## Pipeline

1. Write storyboard with scene descriptions, text overlays, timing
2. Build HTML composition per Hyperframes spec (self-contained index.html + assets)
3. Upload zip to HeyGen Assets API
4. POST /v3/hyperframes/renders with project + variables
5. Poll until completed
6. Download video_url

## Tone → Video mapping

| Tone | Pacing | Typography | Transitions |
|------|--------|------------|-------------|
| default | Moderate | Sans-serif, clean | Crossfade |
| polished | Slow | Serif, elegant | Fade to black |
| chaotic | Fast | Bold, heavy | Quick cuts |
| cinematic | Dramatic | Large, centered | Slow zoom |

## Quality gates

- [ ] Duration 15-25s
- [ ] Hook in first 2s
- [ ] Text readable (0.3s/word minimum)
- [ ] Shows actual product UI/copy
- [ ] No generic SaaS language
- [ ] hyperframes lint passes
