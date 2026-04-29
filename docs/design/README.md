# Apricot Design System

A mobile-first design system for **Apricot**, a human-friendly Bitcoin explorer. Apricot helps non-technical users understand what's happening in a wallet or transaction through plain language, soft pastel visuals, and clear progressive disclosure.

This system was built from the brand brief alone — there is no upstream codebase or Figma file. All visual decisions, type pairing, and component recipes are original to this project. **If you have brand assets, screenshots, or an existing UI to align with, share them and we'll iterate.**

---

## Index

| File / Folder | What it is |
|---|---|
| `colors_and_type.css` | Foundational tokens — color, type, spacing, radii, elevation. Light + dark themes. Semantic type classes (`.t-h1`, `.t-mono`, etc.) |
| `components.css` | Component recipes — `.btn`, `.field`, `.search-field`, `.card`, `.stat-card`, `.badge`, `.tx-row`, `.skeleton`, etc. |
| `preview/` | Cards rendered on the Design System tab — type, colors, spacing, components, brand. |
| `ui_kits/apricot/` | Mobile UI kit — five core screens framed in iOS chrome. See its own README. |
| `SKILL.md` | Skill manifest so this system can be loaded into Claude Code or invoked directly. |

---

## Content fundamentals

**Voice.** Calm, factual, educational. The app is a guide, not a dashboard. It speaks to a curious newcomer, not a trader.

**Person.** Second person, neutral. *"This wallet received 0.01250 BTC from one external wallet."* Not "you received." Not "the user."

**Casing.** Sentence case everywhere. Labels in all-caps for tiny eyebrow tags only (uppercase + 0.04em letterspacing).

**Tone examples.**
- "Look up a wallet or transaction" *(home title — verb-led, plain)*
- "We'll explain what we find" *(reassuring, sets expectations)*
- "Used regularly. Last activity was a few minutes ago." *(insight — short, observational)*
- "We can't reach the network. Check your connection and try again. We've kept your search safe." *(error — what + what to do + reassurance)*
- "A Bitcoin address — like a bank account. See its balance and history." *(education — analogy first, mechanism second)*

**Avoid.** "HODL", "stack sats", "based", emoji as decoration, exclamation marks, anything that reads as either crypto-bro or marketing-bro. No "🚀". No "Welcome aboard!".

**Numbers.** All BTC amounts, addresses, fees, timestamps, and block heights in mono. Currency conversions use the `≈` glyph ("approximately") to set expectations: *"≈ $3,142.18 USD"*.

**Emoji.** None. Iconography only.

---

## Visual foundations

**Palette.** Warm pastel. Apricot/peach as the singular brand accent (`#F4A26B` is the hero). Cream surfaces (`#FFFDFA` page, `#FAF6F0` surface). Taupe text (warm dark, never pure black). Pastel sage / rose / amber / sky for semantic states — these are *quiet*, never neon.

**Type.** Geist sans for the entire UI. JetBrains Mono *only* for blockchain data. The mono carries the "trustworthy, slightly nostalgic" feel via stylistic alternates and `font-variant-numeric: tabular-nums` so digits align in stat grids.

**Surfaces.** Cards have generous radii (16–20px), warm 1px borders (`#E6DCCB`), and very soft warm shadows (`rgba(76, 54, 28, 0.04–0.08)` — never neutral grey shadows). Hero cards on screens use 20px radius; standard list rows use 12px.

**Backgrounds.** Solid warm tones, not gradients. Two exceptions: (1) the brand logo card uses a soft apricot-cream gradient as a brand moment, (2) the chart fill uses an apricot→transparent vertical gradient under the line.

**Animation.** Restrained. 140ms ease for color/background transitions. 80ms tighter scale on `:active` (`scale(0.98)`). Skeleton shimmer is a 1.4s ease-in-out loop. No bouncy springs, no parallax.

**Hover.** Surfaces darken one step (`bg-elevated` → `bg-surface`); accent buttons step to `accent-hover` (`#EE8A4E`).

**Press.** `transform: scale(0.98)` plus the next-darker accent step.

**Borders.** Always 1px, always warm. Three weights: `subtle` (most cards/rows), `default` (inputs), `strong` (focus/hover on inputs).

**Focus ring.** `0 0 0 3px rgba(244, 162, 107, 0.35)` — apricot at 35% alpha. Visible without being loud.

**Transparency / blur.** Sparingly. The accent-soft (`#FFE8D2`) is opaque in light mode but uses 12% apricot-on-dark in dark mode for the same warmth without overpowering.

**Corners.** Pill (full radius) for buttons and badges. 12px for inputs and small cards. 16–20px for content cards. 28px for hero brand surfaces.

**Cards.** Three flavors: flat (sits on surface, no shadow), default (`shadow-xs`, `border-subtle`), elevated (`shadow-md`, used for sheets/popovers).

**Layout.** Mobile-first, 360px design width. 16–20px page padding. 8–12px gaps between list items. Stat grids are always 2 columns on mobile.

---

## Iconography

**System.** Lucide, 1.75 stroke weight, 18–22px common sizes. Lucide is open-license and CDN-available; we ship a small subset inline as SVG inside `ui_kits/apricot/atoms.jsx` and `preview/icons.html`.

**Why Lucide.** Soft, slightly rounded line caps match the warm surface treatment. Stroke style stays calm at small sizes. Drop-in match for the system's friendly tone.

**Inline SVG, not icon font.** This keeps icons recolor-able via `currentColor` and avoids font loading overhead.

**No emoji. No unicode glyphs as icons.** Two stylistic exceptions: the `≈` (approximately equal) sign for fiat conversions, and the apricot mark itself.

**Logo.** Custom mark — soft circular apricot fruit form with a sage-green leaf and a small highlight dot. See `preview/brand-logo.html`. Wordmark uses Geist 600.

---

## Substitutions to flag

These were chosen as nearest-fit Google Fonts; if you have licensed brand fonts, swap them in `colors_and_type.css`:

- **Geist** (Vercel, OFL, on Google Fonts) — clean modern sans. Substitute candidates: Inter, Manrope, SF Pro.
- **JetBrains Mono** (Apache 2.0, on Google Fonts) — slightly nostalgic mono with great glyph distinction (0/O, 1/l/I). Substitute candidates: IBM Plex Mono, Berkeley Mono.

If a different mono "trustworthy/nostalgic" pick is desired (e.g. iA Writer Mono S), share the file and we'll wire it into `fonts/` and update the `@import`.

---

## Accessibility notes

- Body text targets WCAG AA against `bg-page` (`#3A352C` on `#FFFDFA` ≈ 11.2:1).
- Caption / secondary (`#7C7261`) hits 4.7:1 — passes AA for normal text.
- Interactive elements have a 48px minimum hit area.
- Focus ring is always visible; `:focus-visible` is used so keyboard nav is loud and pointer nav stays quiet.
- Semantic colors never carry meaning alone — every state badge has a matching dot, label, and icon.
- Mono sizes do not drop below 13px in production; mobile-readable.
- Dark mode flips warm surfaces to warm charcoal — NOT pure black — to preserve the calm feel.
