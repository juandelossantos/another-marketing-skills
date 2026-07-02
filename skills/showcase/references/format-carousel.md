# Carousel Format

Slide deck structure. Requires CANVA_API_KEY for auto-design or outputs text outline.

## Structure (N slides)

```
Slide 1: Hook — Bold headline + visual
Slides 2-N-1: Value — One idea per slide
Slide N: CTA — Next step + brand
```

## Outline mode (no API key)

When CANVA_API_KEY is missing, output a markdown slide deck:

```markdown
## Slide 1: [Headline]
**Visual idea:** [description]
**Text:** [copy]

## Slide 2: [Idea]
**Text:** [supporting copy]
```

## Canva API mode

When CANVA_API_KEY is available:
1. Design template in Canva Connect
2. Autofill brand kit colors and fonts
3. Export as PNG/PDF

## Quality gates

- [ ] N slides match storyboard
- [ ] Each slide has one idea (not more)
- [ ] Slide 1 is a hook (not an intro)
- [ ] Last slide is a CTA
- [ ] Text readable at mobile size
