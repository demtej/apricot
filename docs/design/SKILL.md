---
name: apricot-design
description: Use this skill to generate well-branded interfaces and assets for Apricot, a human-friendly Bitcoin explorer, either for production or throwaway prototypes/mocks. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. Always link `colors_and_type.css` and `components.css` from the root of the skill, and use the semantic class names defined there (`.t-h1`, `.t-mono`, `.btn`, `.card`, `.tx-row`, `.stat-card`, `.badge-in`, etc.) instead of inventing new styles.

Key rules:
- Sans (Geist) for the entire UI. Mono (JetBrains Mono) **only** for blockchain data — addresses, transaction ids, hashes, BTC amounts, fees, timestamps, block heights.
- Sage = received. Rose = sent. Amber = pending. Sky = informational. Apricot accent is the *brand* color, used sparingly for primary CTAs and brand moments — not as a default for everything.
- Warm neutrals, never pure black or pure cool grey. Surfaces, borders, and shadows all carry warmth.
- Voice is calm, second-person, plain-language. No crypto slang, no emoji, no exclamation marks.

If working on production code, copy `colors_and_type.css` + `components.css` and use the tokens; the JSX in `ui_kits/apricot/` is reference, not production.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions about screen, audience, and tone, and act as an expert designer who outputs HTML artifacts or production code, depending on the need.
