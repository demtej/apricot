# Apricot

<p align="center">
  <img src="docs/assets/app-icon.png" width="96" alt="Apricot app icon" />
</p>

<h1 align="center">Apricot</h1>

<p align="center">
  A human-friendly Bitcoin address explorer built with SwiftUI and Kotlin Multiplatform.
</p>

Apricot is a mobile-first Bitcoin address explorer designed to make blockchain activity easier to understand for non-technical users.

The app lets users search a public Bitcoin address, view its balance and activity, inspect transactions, and understand inputs, outputs, fees, confirmations, and transaction flow through a clean and visual interface.

## Project Goal

This project is built as a portfolio-grade mobile application focused on product quality, clean architecture, modularization, testing, feature flags, caching, observability, and modern engineering practices.

The goal is not to build another dense blockchain explorer. The goal is to create a human-friendly Bitcoin explorer with a polished mobile experience and a strong technical foundation.

## Product Scope

### MVP

- Search a public Bitcoin address.
- Show confirmed and unconfirmed balance.
- Show total received and total sent.
- Show transaction count.
- Show a list of transactions.
- Open a transaction detail.
- Explain inputs, outputs, fees, confirmations, timestamps, and transaction status in simple language.
- Display a visual transaction flow.

### Optional Insights

Controlled by a feature flag:

- First activity.
- Last activity.
- Incoming / outgoing / mixed transaction classification.
- Simple address activity insights.

## Technical Goals

This project is intended to demonstrate:

- SwiftUI mobile development.
- Swift 5.9-compatible iOS code.
- Kotlin Multiplatform shared business/data layer.
- Modular architecture.
- Clean separation between Domain, Data, and Presentation.
- Repository pattern.
- Use cases.
- DTO to domain mapping.
- Dependency injection without a heavy external framework.
- Feature flags.
- Caching.
- Unit testing.
- Snapshot testing.
- UI testing.
- SwiftLint and SwiftFormat.
- GitHub Actions CI.
- Observability through analytics and structured logging.
- Strong README and architecture documentation.

## Requirements

- Swift 5.9
- iOS 17.0+
- SwiftUI
- Kotlin Multiplatform
- Xcode 15.x recommended
- JDK and Gradle for the KMP shared module

## Tooling

Install the local formatting and linting tools with Homebrew:

```bash
brew install swiftlint swiftformat
```

Available commands:

```bash
make lint
make format
make format-check
```

- `make lint`: runs SwiftLint with the project configuration.
- `make format`: formats Swift files in `Apricot/` and `ApricotTests/` using the project configuration.
- `make format-check`: runs SwiftFormat in lint mode to verify formatting without changing files.

The iOS app should be written using Swift 5.9-compatible APIs. Avoid Swift 6-only language features or APIs that require newer compiler versions unless explicitly approved.

## Architecture Direction

The project will use a pragmatic modular architecture.

```text
Apricot iOS App
├── SwiftUI Presentation
├── Apricot Design System
├── Observability
└── Shared KMP Module
    ├── Domain
    ├── Data
    ├── Use Cases
    ├── Mempool API Client
    └── Cache
```

The iOS app owns:

- SwiftUI views.
- Navigation.
- App composition.
- Platform-specific integrations.
- Design system implementation.
- iOS-specific tests.

The KMP shared module owns:

- Bitcoin domain models.
- DTOs.
- Mappers.
- Repositories.
- Use cases.
- Mempool API client.
- Cache logic.
- Business logic tests.

## Data Provider

The initial Bitcoin data provider will be `mempool.space`.

The shared KMP module should hide provider-specific details from the iOS app.

## Design Direction

Apricot should feel:

- Calm.
- Pastel.
- Premium.
- Educational.
- Trustworthy.
- Friendly for non-crypto users.

The app should avoid the typical neon/cyberpunk crypto aesthetic.

The main UI should use a clean modern sans-serif typeface. Blockchain-specific data such as addresses, transaction IDs, hashes, fees, amounts, and block metadata should use a polished monospaced font with a subtle retro-computing feel.

Design reference files are located in:

```text
docs/design/
```

Important design files:

```text
docs/design/colors_and_type.css
docs/design/components.css
docs/design/design-system-summary.md
docs/design/screenshots/
docs/design/ui_kits/
docs/design/preview/
```

The CSS files are design references only. The iOS app should use native SwiftUI components and Swift design tokens.

## Feature Flag

Initial feature flag:

```text
addressInsightsEnabled
```

When enabled, the app may show additional address-level insights such as:

- First activity.
- Last activity.
- Incoming / outgoing / mixed transaction classification.
- Simple activity insights.

This flag is intentionally small and practical, so the project can demonstrate feature flagging without adding unnecessary complexity.

## Observability Direction

The project should include an observability layer abstracted behind protocols.

Initial events:

- `address_search_started`
- `address_search_succeeded`
- `address_search_failed`
- `transaction_opened`
- `transaction_graph_viewed`
- `cache_hit`
- `cache_miss`

The first implementation can be local/console-based. Real analytics providers can be integrated later behind the same abstraction.

## Cache Direction

The shared KMP module should include a simple in-memory TTL cache.

Initial cache targets:

- Address summary.
- Address transaction list.
- Transaction detail.

Suggested TTLs:

- Address summary: short TTL.
- Transaction list: short TTL.
- Confirmed transaction detail: longer TTL.
- Pending transaction detail: short TTL.

## Testing Strategy

Business logic should be tested.

Initial testing priorities:

- KMP domain models.
- DTO to domain mappers.
- Address summary calculations.
- Transaction direction classification.
- Repository behavior.
- Cache hit/miss/expiration.
- iOS ViewModel state transitions.
- Snapshot tests for main screens.
- UI test for the happy path: search address → open transaction.

## Development Approach

The project will be built incrementally using Claude Code.

Each iteration should be small, reviewable, and validated before moving to the next one.

Initial priorities:

1. Project skeleton.
2. KMP integration.
3. Bitcoin domain models.
4. Mempool API client.
5. Address search flow.
6. Transaction detail flow.
7. Visual transaction graph.
8. Feature flag.
9. Cache.
10. Tests.
11. Tooling.
12. Observability.
13. Polish.

## Out of Scope for Initial MVP

- Wallet connection.
- Portfolio tracking.
- Push notifications.
- AI-generated summaries.

## PostHog Setup (Local)

Feature flags are powered by PostHog. The API key and host are read from a local xcconfig file that is **not committed to the repo**.

To configure PostHog locally:

```bash
cp Config/Apricot.example.xcconfig Config/Apricot.local.xcconfig
```

Then open `Config/Apricot.local.xcconfig` and fill in your values:

```
APRICOT_POSTHOG_API_KEY = phc_your_key_here
APRICOT_POSTHOG_HOST = https://us.i.posthog.com
```

After editing, run `make xcode` to regenerate the Xcode project so the build settings are picked up.

If `Config/Apricot.local.xcconfig` is absent or the keys are empty, the app falls back to `LocalFeatureFlags` with all flags enabled. The app builds and runs for any contributor without PostHog credentials.

The remote flag key in PostHog is `address-insights-enabled`, which maps to `addressInsightsEnabled` in the app.

## Status

Work in progress.
