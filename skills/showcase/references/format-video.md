# Video Format (Hyperframes)

Script + Hyperframes composition. Renders locally via CLI — no API key needed.

## Structure (15-25s)

```
Hook (2-3s) → Reveal (2-4s) → Highlights (5-12s) → Outro (2-4s)
```

## Pipeline

1. Write storyboard with scene descriptions, text overlays, timing
2. Build HTML composition per Hyperframes spec (self-contained index.html + assets)
3. Preview: `npx hyperframes preview` (opens studio at localhost:3002)
4. Lint: `npx hyperframes lint`
5. Render: `npx hyperframes render --output showcase-output/video.mp4`
6. Verify: `npx hyperframes inspect showcase-output/video.mp4`

## Tone → Video mapping

| Tone | Pacing | Typography | Transitions |
|------|--------|------------|-------------|
| default | Moderate | Sans-serif, clean | Crossfade |
| polished | Slow | Serif, elegant | Fade to black |
| chaotic | Fast | Bold, heavy | Quick cuts |
| cinematic | Dramatic | Large, centered | Slow zoom |

## Audio

After storyboarding, decide on audio:
- **Music bed:** CC0 from Pixabay or YouTube Audio Library
- **Voiceover:** Kokoro TTS (local, open source) or ElevenLabs API
- **SFX:** Kenney.nl or Freesound

See `references/audio.md` for the Hyperframes `<audio>` API and mixing guide.

## Quality gates

- [ ] Duration 15-25s
- [ ] Hook in first 2s
- [ ] Text readable (0.3s/word minimum)
- [ ] Shows actual product UI/copy
- [ ] No generic SaaS language
- [ ] hyperframes lint passes
- [ ] Audio files referenced exist (if audio selected)
