# Design: another-marketing-skills Landing Page

## Identity

- **Name:** another-marketing-skills
- **Tagline:** "You built it. Now promote it."
- **Design direction:** Minimalist editorial UI (inspired by Notion, Linear) — warm monochrome palette, typographic contrast, flat bento grids, muted pastel accents. No gradients, no heavy shadows. The landing page must demonstrate what it sells.

## Design Tokens

### Colors

```
--bg-base:       #FAF8F5  (warm off-white, light)
--bg-surface:    #F2EFEA  (warm card surface, light)
--bg-elevated:   #E8E4DD  (elevated surfaces, light)
--text-primary:  #1A1A1A  (near-black)
--text-secondary:#6B6560  (warm gray)
--text-muted:    #A09890  (muted)
--accent:        #E85D3A  (warm orange-red)
--accent-subtle: #F5E6E1  (accent tint)
--border:        #D8D2CB  (subtle borders)
```

### Typography

- **Headings:** Geist (sans-serif, variable weight 600-800)
- **Body:** Inter (sans-serif, weight 400-500)
- **Code/Mono:** JetBrains Mono (code blocks, CLI commands)
- **Scale:** 14 / 16 / 18 / 24 / 32 / 48 / 64 px

### Spacing

- **Grid:** 12-column, 24px gutter
- **Section padding:** 120px vertical (desktop), 64px (mobile)
- **Card padding:** 24px
- **Content max-width:** 1200px

### Dark Mode

```
--bg-base:       #1A1817
--bg-surface:    #242120
--bg-elevated:   #2E2A28
--text-primary:  #EDE9E5
--text-secondary:#A09890
--text-muted:    #6B6560
--accent:        #FF774D
--accent-subtle: #2E1F1A
--border:        #35302E
```

## Layout (Page Structure)

### Hero
- Full-viewport, centered content stack
- Prompt input mockup (interactive demo)
- Tagline + subtitle
- Single CTA: GitHub button

### Chapter 1: The Problem
- Section with fragmented-tools illustration
- Bold statement + supporting stats
- Side-by-side: before (fragmented) vs after (unified)

### Chapter 2: The System
- Bento grid of skill cards (4-6 skills)
- Each card: name, flavor label, one-sentence description
- Architecture flow diagram: Input → Skills → Formats → Distribution

### Chapter 3: In Action
- 2-3 case study cards with metrics
- Gallery of generated content examples

### Chapter 4: For Developers
- Install command with copy button
- Quick start example
- Agent compatibility logos

### Footer
- GitHub link, Docs link, "Built on another-agent-skills"

## Wireframes (ASCII)

```
┌──────────────────────────────────────────────┐
│                    HERO                       │
│  ┌──────────────────────────────────────┐    │
│  │  "You built it. Now promote it."     │    │
│  │  [Prompt input mockup] → [Generate]  │    │
│  │        [★ GitHub CTA]                │    │
│  └──────────────────────────────────────┘    │
├──────────────────────────────────────────────┤
│           CH1: THE PROBLEM                    │
│  ┌──────────────┐  ┌────────────────────┐    │
│  │ Fragmented    │  │ "Most marketing    │    │
│  │ tools visual  │  │ tools are black    │    │
│  │ (icons)       │  │ boxes"             │    │
│  └──────────────┘  └────────────────────┘    │
├──────────────────────────────────────────────┤
│           CH2: THE SYSTEM                     │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐        │
│  │product│ │show- │ │social│ │email │        │
│  │-market│ │case  │ │-copy │ │-drip │        │
│  │ing    │ │      │ │      │ │      │        │
│  └──────┘ └──────┘ └──────┘ └──────┘        │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐        │
│  │launch │ │market│ │seo   │ │...   │        │
│  │-plan  │ │-plan │ │found.│ │      │        │
│  └──────┘ └──────┘ └──────┘ └──────┘        │
├──────────────────────────────────────────────┤
│           CH3: IN ACTION                      │
│  ┌────────────────┐ ┌────────────────┐        │
│  │ Case Study 1   │ │ Case Study 2   │        │
│  │ +34% open rate │ │ 2x engagement  │        │
│  └────────────────┘ └────────────────┘        │
├──────────────────────────────────────────────┤
│           CH4: FOR DEVELOPERS                 │
│  ┌──────────────────────────────────────┐    │
│  │  npm install / git clone ... [copy]  │    │
│  │  "Quick start: let's showcase my     │    │
│  │   product"                           │    │
│  └──────────────────────────────────────┘    │
├──────────────────────────────────────────────┤
│                  FOOTER                       │
│  GitHub · Docs · Built on another-agent-skills│
└──────────────────────────────────────────────┘
```

## Responsive Breakpoints

- **Mobile:** < 768px — single column, stacked cards, hamburger nav
- **Tablet:** 768-1024px — 2-column grids, reduced hero
- **Desktop:** > 1024px — full layout as above

## Accessibility

- WCAG AA minimum contrast ratio (4.5:1 text, 3:1 large text)
- Focus indicators on all interactive elements
- Skip-to-content link
- Semantic HTML landmarks
- Dark/light mode respects `prefers-color-scheme`

## Tech Stack (Landing Page)

| Tool | Version | Purpose |
|------|---------|---------|
| Vite | 8.0.14 | Build tool + dev server |
| React | 19.2.6 | Component UI |
| Tailwind CSS | 4.3.0 | Utility CSS + dark mode |
| @vitejs/plugin-react | 6.0.2 | React Fast Refresh |
| react-i18next | latest | EN/ES i18n |
| react-router-dom | latest | HashRouter (GH Pages) |
| GitHub Actions | — | Build + deploy to gh-pages |

Verified via Context7.

## References

Full research context in `development/COPY_RESEARCH.md` (copywriting, persuasion, platform rules). Full project plan in `development/MASTER_PLAN.md` Section 6 (landing page).
