# Structured Data (JSON-LD) Guide

Source: Schema.org.

## SoftwareApplication (for products/tools)
```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Product Name",
  "description": "Short description",
  "url": "https://example.com",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Linux, macOS, Windows",
  "author": {
    "@type": "Organization",
    "name": "Company Name"
  },
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  }
}
```

## Article (for blog posts)
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title",
  "description": "Brief description",
  "author": { "@type": "Person", "name": "Author Name" },
  "datePublished": "2026-07-02",
  "dateModified": "2026-07-02"
}
```

## Organization
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company Name",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png"
}
```

## FAQPage
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "Question?",
    "acceptedAnswer": { "@type": "Answer", "text": "Answer." }
  }]
}
```

## BreadcrumbList
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [{
    "@type": "ListItem",
    "position": 1,
    "name": "Home",
    "item": "https://example.com/"
  }]
}
```

Validate at: https://search.google.com/test/rich-results
