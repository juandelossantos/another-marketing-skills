# Audio & Music Guide

How to add music, voiceover, and sound effects to generated videos via Hyperframes.

## Ask the User

Before generating a video, ask:
- "Add background music? (free CC0 tracks available)"
- "Add voiceover / narration? (requires TTS or recording)"
- "Add sound effects? (transitions, emphasis)"
- "No audio (silent video)"

## Free Music Sources

| Source | License | Attribution | Type |
|--------|---------|-------------|------|
| [Pixabay Music](https://pixabay.com/music/) | CC0 | Not required | Full tracks, loops, SFX |
| [YouTube Audio Library](https://www.youtube.com/audiolibrary) | YouTube free | Not required | Full tracks, SFX |
| [Freesound](https://freesound.org/) | CC0 / CC BY | Varies | SFX, short clips |
| [Uppbeat](https://uppbeat.io/) | Free tier | Required ("Music from Uppbeat") | Full tracks |
| [Kenney.nl](https://kenney.nl/) | CC0 | Not required | SFX packs |

## Recommended CC0 Tracks for Promo Videos

Search Pixabay Music for:
- "corporate", "tech", "uplifting" — B2B promos
- "ambient", "cinematic" — polished/dramatic tone
- "upbeat", "energetic" — default/chaotic tone
- "calm", "minimal" — deadpan/warm tone

## Hyperframes Audio API

Add an `<audio>` element to the composition:

```html
<!-- Background music — full duration -->
<audio src="assets/bed.mp3" data-start="0" data-duration="18" data-volume="0.6" data-fade="in:0.8,out:1.0"></audio>

<!-- Voiceover — timed with scene -->
<audio src="assets/vo.wav" data-start="1.5" data-duration="4.0" data-volume="1.0" data-fade="in:0.1,out:0.3"></audio>

<!-- Music ducking — lower volume during VO -->
<audio src="assets/bed.mp3" data-start="1.5" data-duration="4.0" data-volume="0.2" data-trim-start="1.5" data-fade="in:0.3,out:0.5"></audio>

<!-- SFX on punchline -->
<audio src="assets/chime.wav" data-start="6.0" data-duration="0.5" data-volume="0.8"></audio>
```

## Voiceover Generation

Local (open source, no API key):
```bash
# Kokoro TTS (installed via pip)
pip install kokoro-onnx soundfile
python -c "from kokoro import KPipeline; p=KPipeline('en'); for r in p('Hello world', voice='af_heart'): r[1].write('vo.wav')"
```

Cloud (API key required):
- ElevenLabs TTS — `ELEVENLABS_API_KEY`
- OpenAI TTS — `OPENAI_API_KEY`

## Quality Gates

- [ ] Audio files exist at referenced paths
- [ ] Audio duration ≤ composition duration
- [ ] Volume levels: music 0.3-0.6, VO 0.8-1.0, SFX 0.6-0.9
- [ ] Music fades in/out (not abrupt)
- [ ] No audio clipping
