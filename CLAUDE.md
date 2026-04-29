# Claude Code Instructions

You are helping build Apricot, a portfolio-grade iOS app with a Kotlin Multiplatform shared layer.

Work incrementally. Do not implement unrelated features unless explicitly requested.

## Priorities

- Keep the app compiling after every meaningful change.
- Prefer small, reviewable changes.
- Maintain clear architecture boundaries.
- Avoid overengineering.
- Add tests for business logic.
- Keep UI code clean and readable.
- Do not introduce external dependencies without asking first.

## Swift Version

This project must target Swift 5.9.

Do not use Swift 6-only features.

Avoid APIs or syntax that require Swift 5.10+ or Swift 6 unless explicitly requested.

The iOS app should compile with Swift 5 language mode.

Preferred iOS deployment target: iOS 17.0.

## Architecture Rules

- The iOS app owns SwiftUI views, navigation, app composition, and platform-specific integrations.
- The KMP shared module owns Bitcoin domain models, DTOs, mappers, repositories, use cases, and cache.
- DTOs must not leak into presentation code.
- Domain models should not depend on API-specific naming.
- Provider-specific code should be isolated behind repository interfaces.
- Feature flags should be abstracted behind a provider protocol.
- Observability should be abstracted behind protocols.
- Avoid business logic inside SwiftUI views.

## Current Scope

Bitcoin only.

MVP:

- Search a public Bitcoin address.
- Show address summary.
- Show transaction list.
- Open transaction detail.
- Explain transaction data visually and in simple language.

Out of scope for now:

- Ethereum.
- Wallet connection.
- Trading.
- Authentication.
- Push notifications.
- App Store release.
- Complex AI summaries.

## Design System

Design reference files are located in:

`docs/design/`

Important files:

- `docs/design/colors_and_type.css`
- `docs/design/components.css`
- `docs/design/design-system-summary.md`
- `docs/design/screenshots/`
- `docs/design/ui_kits/`
- `docs/design/preview/`

The CSS files are references only. The iOS app must use native SwiftUI components and Swift design tokens.

The design system should feel pastel, calm, premium, educational, and approachable.

Blockchain-specific values such as addresses, transaction ids, hashes, fees, and amounts should use a polished monospaced style.

## Code Style

- Prefer explicit names.
- Prefer small types.
- Avoid force unwraps.
- Avoid large ViewModels.
- Favor async/await where appropriate.
- Add comments only when they clarify non-obvious decisions.
- Add tests for business logic and important state transitions.