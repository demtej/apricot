# Apricot Design System Summary

Apricot is the design system for a mobile-first Bitcoin address explorer.

## Visual Direction

- Soft pastel palette.
- Warm apricot/peach accent.
- Calm, premium, educational, and trustworthy.
- Avoid neon, cyberpunk, trading-terminal, or meme-coin aesthetics.
- Use rounded cards, subtle borders, soft backgrounds, and clear hierarchy.

## Typography

- Main UI: modern, clean, highly readable sans-serif.
- Blockchain data: monospaced font with a subtle retro-computing feel.
- Use monospace only for:
  - Bitcoin addresses.
  - Transaction IDs.
  - Hashes.
  - Satoshi/BTC amounts.
  - Fees.
  - Block metadata.
  - Technical timestamps.

## Product Screens

Initial screens to implement:

1. Home / Search.
2. Address Summary.
3. Transaction List.
4. Transaction Detail.
5. Transaction Flow Diagram.
6. Loading State.
7. Empty State.
8. Error State.

## SwiftUI Implementation Notes

- Translate CSS tokens into SwiftUI design tokens.
- Do not use WebViews.
- Do not copy CSS directly into the app.
- Use native SwiftUI components.
- Prefer reusable components in an Apricot Design System module/package.
- Keep blockchain-specific text visually distinct with monospace typography.
- Support light and dark mode.
- Prioritize readability and accessibility.