# Apricot — UI Kit

Pixel-honest mobile recreations of the five core Apricot screens, framed in iOS device chrome.

## Files
- `index.html` — interactive showcase of all five screens
- `atoms.jsx` — shared icon set (`window.ApricotKit.Icon`), logo, helpers
- `HomeScreen.jsx` — search hero + recent + "what can I look up?"
- `AddressScreen.jsx` — summary card, insight banner, filter chips, tx list
- `TxScreen.jsx` — plain-language summary, quick facts grid, flow diagram, progressive technical details
- `StateScreens.jsx` — `LoadingScreen` (skeletons) + `ErrorScreen`
- `ios-frame.jsx` — device frame (starter component)

## Conventions
- Sans (`var(--font-sans)`) for everything that's a *story* — titles, labels, body, numbers expressed in words.
- Mono (`var(--font-mono)`) for everything that's *data* — addresses, hashes, BTC amounts, fees, timestamps, block heights.
- Sage = received / positive. Rose = sent. Amber = pending. Sky = informational/educational.
- Apricot accent appears sparingly — primary CTA, hero pills, "this wallet" highlight inside the flow diagram.

## Patterns to copy from
- **Stat card grid** in `AddressScreen.jsx` — 2×2 mini cards inside a hero card.
- **Flow diagram** in `TxScreen.jsx` — soft gradient arrow with apricot pill in the middle, "(this)" highlight on the destination output.
- **Progressive disclosure** — `Technical details` accordion in `TxScreen.jsx` keeps the calm surface but doesn't lock advanced users out.
