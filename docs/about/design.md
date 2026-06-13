<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Design System

This page reflects how the **Kartoza Brand Pack v0.1** is applied to the
Infrastructure Mapper documentation site. The Brand Pack is the upstream
source of truth; this page is a derivative for our specific surface
(MkDocs).

!!! warning "The previous in-repo "nature & environment" palette is retired"
    Earlier versions of this project used a bespoke isometric / nature
    palette (Forest Green, Moss Green, Earth Brown, Sandstone Beige, Leaf
    Yellow-Green &hellip;). All of those values have been removed in full
    &mdash; per the Brand Pack SRS &sect;1.5, this is **removal, not
    reconciliation**. None of those colour names or hex values appear in
    the new system.

## What's "on brand"

A page is on brand when a reader who has never seen it can tell within a
second that **Kartoza made it** &mdash; from the mark, the blue / amber /
grey palette, the Nunito type, and (where space allows) the map motif,
with nothing on the page fighting those four signals.

Consistency is the whole point; novelty is not a goal.

## Palette

The Kartoza palette has two coordinated families &mdash; the **logo
palette** (mark, accents, UI chrome) and the **map-motif palette**
(illustration-only). Both share one amber.

### Logo palette (UI chrome)

<div class="kz-swatches" markdown>

<div class="kz-swatch" style="background:#54A2CC;color:white">
<strong>Kartoza Blue</strong>
<code>#54A2CC</code>
<span>Primary accent &mdash; links, primary actions, headings &ge; 18 pt.</span>
</div>

<div class="kz-swatch" style="background:#EEB348">
<strong>Kartoza Amber</strong>
<code>#EEB348</code>
<span>Secondary / highlight accent. Subtitles, callouts, structure cues.</span>
</div>

<div class="kz-swatch" style="background:#8A8B8B;color:white">
<strong>Kartoza Grey</strong>
<code>#8A8B8B</code>
<span>Symbol grey loop; structural mid-grey.</span>
</div>

<div class="kz-swatch" style="background:#383939;color:white">
<strong>Charcoal</strong>
<code>#383939</code>
<span>Default body text. H1 / H2. The colour that does the reading work.</span>
</div>

<div class="kz-swatch" style="background:#676869;color:white">
<strong>Secondary Grey</strong>
<code>#676869</code>
<span>Eyebrows, captions, secondary text.</span>
</div>

<div class="kz-swatch" style="background:#D1D1D1">
<strong>Light Grey</strong>
<code>#D1D1D1</code>
<span>Table rules, dividers, disabled states.</span>
</div>

<div class="kz-swatch" style="background:#F5F5F2">
<strong>Cloud</strong>
<code>#F5F5F2</code>
<span>Page tint, zebra rows, panel surfaces.</span>
</div>

<div class="kz-swatch" style="background:#FFFFFF">
<strong>White</strong>
<code>#FFFFFF</code>
<span>Base surface.</span>
</div>

</div>

### Status colours (status-only)

Used in admonitions and chips. Always pair with an icon or text label
&mdash; never colour alone (NFR-002).

<div class="kz-swatches" markdown>

<div class="kz-swatch" style="background:#3C7D54;color:white">
<strong>Success</strong>
<code>#3C7D54</code>
<span>On <code>#EAF3EC</code> tint.</span>
</div>

<div class="kz-swatch" style="background:#EEB348">
<strong>Caution</strong>
<code>#EEB348</code>
<span>On <code>#FCF3E0</code> tint. (Reuses brand amber.)</span>
</div>

<div class="kz-swatch" style="background:#B0473C;color:white">
<strong>Error</strong>
<code>#B0473C</code>
<span>On <code>#FBEFEF</code> tint.</span>
</div>

</div>

### Colour roles &mdash; the rule

| Element | Colour |
| --- | --- |
| Body text | **Charcoal `#383939`** &mdash; never Blue or Amber |
| Headings H1 / H2 | Charcoal |
| Eyebrows (e.g. `KARTOZA · X`) | Secondary Grey, letter-spaced UPPER |
| Links | Kartoza Blue |
| Primary CTA fill | Kartoza Blue |
| Highlight / display headings &ge; 18 pt | Amber (sparing) |
| Table headers | Charcoal background, white type |

!!! danger "Blue and Amber are not body-text colours"
    Both fail WCAG AA contrast against white at paragraph size. They are
    *accents* &mdash; for links, fills, &ge; 18 pt headings, icons and
    chart series. Body copy stays in Charcoal at all times (FR-012,
    NFR-001).

## Map motif

Kartoza's signature illustration is a flat, top-down abstract map
&mdash; cool-grey parcels, amber zones, blue water, white street network,
optional meander pattern. It is the only source of visual texture on a
Kartoza surface; gradients and stock photography are not (FR-030,
FR-033).

On this docs site:

- The landing-page hero uses a **lightened motif background** so Charcoal
  body type stays legible (FR-031).
- Future section divider banners and full-bleed covers will use the
  full-saturation motif.
- The motif PNGs ship in the Brand Pack under
  `visual-elements/`; copies live under `docs/assets/brand/` for this
  project to consume.

## Logo

Use the supplied artwork as-is. Never re-type, recolour part-way, stretch
or add effects (FR-002). The variants:

| Variant | When |
| --- | --- |
| **Vertical lockup** (primary) | Cover pages, large blocks |
| **Horizontal lockup** | Headers, signatures, hero |
| **Symbol** | Tight spaces, favicons, app launchers |
| **Reversed (white) lockup** | Dark / Charcoal backgrounds |
| **Mono (Charcoal)** | Only when colour isn't possible |

Minimum sizes: vertical &ge; 90 px wide, horizontal &ge; 120 px wide,
symbol &ge; 16 px (FR-005). Maintain clear space around the logo equal
to the symbol's central aperture height (FR-004).

## Typography

| Use | Family | Notes |
| --- | --- | --- |
| Body, headings, eyebrows | **Nunito** | Loaded via Google Fonts. Stack: Nunito, "Helvetica Neue", Arial, sans-serif (FR-020). |
| Code, monospace | **JetBrains Mono** | Variable weight; for code blocks, inline code, terminal output (FR-021). |
| Accent / display | Nunito Italic in Amber | The "Key Objectives" style. Used sparingly. |

Line height &asymp; 1.45 for body. Heading colours: H1 / H2 in Charcoal;
eyebrows in Secondary Grey, letter-spaced UPPER; links in Blue (FR-024).

## Flat &mdash; no shadows, gradients or bevels

The system is **flat**. No drop shadows on logos, no gradients on
buttons, no glows, no bevels. Depth and texture come **only** from the
map motif (FR-033).

This is enforced in `extra.css`: hero blocks, grid cards, admonitions,
tables &mdash; none of them carry `box-shadow` or `background:
linear-gradient(...)`.

## Components used on this site

### `.kz-hero`

Landing-page hero. Cloud surface with a lightened slant-title motif
behind it. Charcoal type. Blue primary CTA. Flat.

### Material `grid cards`

Section index cards. Hairline Light-Grey border, Cloud-on-hover, Blue
border on hover. No shadow.

### `.kz-domain-grid`

A subclass of `.grid.cards` used on the Data Model index for the
capture-domain entries (image + name + summary).

### `.kz-swatches`

The palette swatches you're looking at on this page.

### `.kz-eyebrow`

The `KARTOZA · X` eyebrow above hero titles &mdash; Secondary Grey,
spaced UPPER (FR-024).

### `.kz-ai`

Inline badge marking AI-assisted content (per FR-095 / NFR-022): :robot:
icon + bold short label, on amber tint.

## Tokens (one source of truth)

Every colour and font lives in `docs/stylesheets/kartoza-tokens.css`
(copied from the Brand Pack `tokens/tokens.css`). All other CSS consumes
those tokens via `var(--kartoza-blue)` etc. To update the palette,
update the tokens file &mdash; nothing else (NFR-020).

```css
/* docs/stylesheets/kartoza-tokens.css */
:root{
  --kartoza-blue:  #54A2CC;
  --kartoza-amber: #EEB348;
  --kartoza-grey:  #8A8B8B;
  --text-default:  #383939;
  --text-muted:    #676869;
  --rule-line:     #D1D1D1;
  --surface-cloud: #F5F5F2;
  --surface-white: #FFFFFF;
  --font-sans: 'Nunito','Helvetica Neue',Arial,sans-serif;
  --font-mono: 'JetBrains Mono',monospace;
  --status-success: #3C7D54; --status-success-tint: #EAF3EC;
  --status-warn:    #EEB348; --status-warn-tint:    #FCF3E0;
  --status-error:   #B0473C; --status-error-tint:   #FBEFEF;
}
```

## Iconography note

The Brand Pack specifies a single flat icon style: two-weight line/solid,
Charcoal + one accent matching the symbol (FR-040). Domain PNG icons
under `docs/assets/` (vegetation, water, electricity &hellip;) are the
project's legacy bespoke set and are **scheduled for redrawing** in the
Kartoza style (FR-041 SHOULD). They render as-is for now.

## AI-assisted authoring (FR-095, NFR-022)

Per the Brand Pack governance rule, machine-generated artefacts on
Kartoza surfaces are marked with :robot: and the prompt is retained
alongside the output, with a human validating the result. On this site,
that takes the form of:

- A `.kz-ai` inline badge next to AI-drafted prose where appropriate.
- `PROMPT.log` at the repo root capturing every session prompt.
- A separate [AI Assistance Policy](ai-policy.md) page covering scope.

## Brand Pack location

The full Kartoza Brand Pack &mdash; including the SRS, Brand Guidelines
PDF, logo masters, motif PNGs and the token source &mdash; lives outside
this repository:

- Internal Kartoza staff: request access from the brand owner.
- Repo working copy: a snapshot is dropped into
  `Kartoza_Brand_Assets_v0_1/` at the project root for local
  development. The folder is **gitignored** and not part of project
  history; assets actually used by the docs site are copied into
  `docs/assets/brand/` and committed.
