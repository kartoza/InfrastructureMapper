<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Design System

The Infrastructure Mapper visual identity follows the Kartoza design
language. This page captures the palette, typography, and visual
conventions used across the docs site, slide decks, QGIS styles, and
QField forms.

## Palette

The palette is rooted in landscape colours: forest, moss, earth, sky.

<div class="kz-swatches" markdown>

<div class="kz-swatch" style="background:#2F5D50">
<strong>Forest Green</strong>
<code>#2F5D50</code>
<span>Primary brand &mdash; headers, callouts, links</span>
</div>

<div class="kz-swatch" style="background:#7C9C75">
<strong>Moss Green</strong>
<code>#7C9C75</code>
<span>Secondary &mdash; cards, secondary buttons</span>
</div>

<div class="kz-swatch" style="background:#A9825A;color:white">
<strong>Earth Brown</strong>
<code>#A9825A</code>
<span>Warm accent &mdash; emphasis, badges</span>
</div>

<div class="kz-swatch" style="background:#E0D2B2">
<strong>Sandstone Beige</strong>
<code>#E0D2B2</code>
<span>Surface tone &mdash; page backgrounds, soft fills</span>
</div>

<div class="kz-swatch" style="background:#A4DDED">
<strong>Sky Blue</strong>
<code>#A4DDED</code>
<span>Water domains, info callouts</span>
</div>

<div class="kz-swatch" style="background:#2B7A78;color:white">
<strong>Deep Teal</strong>
<code>#2B7A78</code>
<span>Active state, accent links</span>
</div>

<div class="kz-swatch" style="background:#C1E1C1">
<strong>Leaf Yellow-Green</strong>
<code>#C1E1C1</code>
<span>Vegetation domain, success states</span>
</div>

<div class="kz-swatch" style="background:#9FA8A3">
<strong>Rock Gray</strong>
<code>#9FA8A3</code>
<span>Hardscape, neutral borders</span>
</div>

</div>

The full palette is reflected in `docs/stylesheets/extra.css` as CSS
custom properties:

```css
:root {
  --kz-forest:    #2F5D50;
  --kz-moss:      #7C9C75;
  --kz-earth:     #A9825A;
  --kz-sandstone: #E0D2B2;
  --kz-sky:       #A4DDED;
  --kz-teal:      #2B7A78;
  --kz-leaf:      #C1E1C1;
  --kz-rock:      #9FA8A3;
}
```

Dark-mode shades use the same hues with adjusted lightness; see the
`[data-md-color-scheme="slate"]` block in the same file.

## Typography

| Use | Family | Notes |
|---|---|---|
| Body and headings | [Inter] | Loaded via mkdocs-material's Google Fonts integration. |
| Code, monospace | [JetBrains Mono] | Variable weight, ligatures on. |
| Diagrams | Inter | Mermaid uses the same body family for visual coherence. |

Type scale is the mkdocs-material default. We deliberately don't override
heading sizes &mdash; the theme's defaults are tuned for technical reading
and we want to preserve that.

[Inter]: https://rsms.me/inter/
[JetBrains Mono]: https://www.jetbrains.com/lp/mono/

## Components

The custom CSS in `docs/stylesheets/extra.css` defines a small set of
reusable components used across the docs:

### `.kz-hero`

A full-bleed hero block at the top of the landing page. Forest-green
background, white type, centred call-to-action buttons.

### Material `grid cards`

Section index pages (Getting Started, Schema Lifecycle, Developer Guide,
About) use [Material's built-in `grid cards`][grid-cards] component. We
add a brand-tinted hover state and recolour the leading icon to match the
palette, but the underlying markup is whatever mkdocs-material renders.

[grid-cards]: https://squidfunk.github.io/mkdocs-material/reference/grids/#grid-cards

### `.kz-domain-grid`

A subclass of `.grid.cards` used only on `docs/data-model/index.md`. It
tightens the grid so the capture-domain cards pack closer, centres their
content, and styles the leading PNG via `img.kz-domain-img`.

### `.kz-swatches` + `.kz-swatch`

The palette swatches you're looking at on this page.

### `.kz-footer-credits`

The "Made with 💗 by Kartoza &middot; Donate &middot; GitHub" tagline used
on the landing page. The site-wide footer copyright is set in `mkdocs.yml`
under the `copyright:` key, so it appears on every page automatically.

## QGIS styling

QGIS styling lives in `qml/`. Each capture domain has a `.qml` style file
that maps the schema's lookup-table values to a colour from the palette
above (e.g. `vegetation_condition.condition = 'good'` → Leaf Yellow-Green).
The mapping is intentionally consistent with the data-model card icons on
the docs site, so users see the same colours in the docs and in QGIS.

## QField forms

QField field-capture forms (a future addition) will follow the same palette
and typography for any custom-styled widgets. The default QField widgets
already pick up reasonable contrasts; we only override when a field
domain has a domain-specific accent (e.g. water-domain inputs framed in
Sky Blue).

## Why a separate design system page

The docs site, QGIS styles, slide decks, and field forms are all visually
linked &mdash; users move between them on the same project. A single source
of truth for "what colour is the vegetation domain" prevents drift.
