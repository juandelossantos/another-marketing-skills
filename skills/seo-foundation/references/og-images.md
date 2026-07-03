# OG Image Guide

Source: Open Graph protocol (ogp.me).

## Specs
- Dimensions: 1200x630px (1.91:1 aspect ratio)
- Format: PNG or JPG
- Max size: 8MB (Facebook), 5MB (Twitter)
- Text: title (48px+), brand name (24px+)
- Readable on mobile: test at 300x157px

## Required meta tags
```html
<meta property="og:title" content="Title (40-60 chars)">
<meta property="og:description" content="Description (2-4 sentences)">
<meta property="og:image" content="https://example.com/og-image.png">
<meta property="og:url" content="https://example.com/page/">
<meta property="og:type" content="website">
```

## Twitter Card
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Same as og:title">
<meta name="twitter:description" content="Same as og:description">
<meta name="twitter:image" content="Same as og:image">
```

## Design rules
- 3-5 words max text overlay
- High contrast (white text on dark bg or vice versa)
- Brand colors from DESIGN.md
- No small text (unreadable at 300px preview)
- Test at Twitter Card Validator
