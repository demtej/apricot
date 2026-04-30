# AGENTS.md

Apricot is a portfolio-grade iOS app with a Kotlin Multiplatform shared layer.

Work incrementally. Do not implement unrelated features unless explicitly requested.

## Project Constraints

- Swift 5.9-compatible code.
- iOS 17.0+.
- SwiftUI for iOS UI.
- Kotlin Multiplatform for shared Bitcoin domain, data, use-case, and cache logic.
- Do not use Swift 6-only features.
- Do not use APIs that require Swift 5.10+ or Swift 6 unless explicitly approved.
- Do not add external dependencies without explicit approval.
- Keep the app compiling after every meaningful change.

## Architecture

The project follows a pragmatic modular architecture.

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

## Layer Ownership

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

## Architecture Rules

- DTOs must not leak into presentation code.
- Domain models must not depend on API-specific naming.
- Provider-specific code, such as Mempool.space, must be isolated behind repository interfaces.
- Feature flags must be abstracted behind a provider protocol.
- Observability must be abstracted behind protocols.
- Avoid business logic inside SwiftUI views.
- Keep KMP-to-Swift adaptation inside the iOS service layer or a dedicated KMP iOS facade.
- Keep ViewModels focused on state management and presentation logic.

## Current Scope

Bitcoin only.

Current MVP:

- Search a public Bitcoin address.
- Show address summary.
- Show transaction list.
- Open transaction detail.
- Explain transaction data visually and in simple language.
- Show a visual transaction flow.

Out of scope:

- Ethereum.
- Wallet connection.
- Trading.
- Authentication.
- Push notifications.
- App Store release.
- Complex AI summaries.

## Data Provider

Initial provider:

```text
mempool.space
```

The KMP shared module should hide provider-specific details from the iOS app.

## Design Direction

Use the Apricot Design System.

Design reference files live in:

```text
docs/design/
```

Important files:

```text
docs/design/colors_and_type.css
docs/design/components.css
docs/design/design-system-summary.md
docs/design/screenshots/
docs/design/ui_kits/
docs/design/preview/
```

The app should feel:

- Pastel.
- Calm.
- Premium.
- Educational.
- Approachable.
- Friendly for non-crypto users.

Avoid:

- Neon crypto aesthetics.
- Cyberpunk visuals.
- Trading-terminal layouts.
- Meme coin styling.
- Dense technical tables.

Blockchain-specific values should use monospaced typography:

- Bitcoin addresses.
- Transaction IDs.
- Hashes.
- BTC amounts.
- Sats.
- Fees.
- Block metadata.

## Build Commands

Use these commands when validating changes:

```bash
make kmp
make xcode
xcodebuild -project Apricot.xcodeproj -scheme ApricotTests -destination 'platform=iOS Simulator,name=iPhone 17' test
xcodebuild -project Apricot.xcodeproj -scheme Apricot -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If simulator naming fails, inspect available simulators with:

```bash
xcrun simctl list devices available
```

## Testing Priorities

Business logic should be tested.

Prioritize tests for:

- KMP domain models.
- DTO to domain mappers.
- Address summary calculations.
- Transaction direction classification.
- Repository behavior.
- Cache hit/miss/expiration.
- iOS ViewModel state transitions.
- Formatter utilities.
- Recent search behavior.
- Snapshot tests for stable UI screens when requested.

Do not add snapshot tests unless the task explicitly asks for them.

## Code Style

- Prefer explicit names.
- Prefer small types.
- Avoid force unwraps.
- Avoid large ViewModels.
- Favor async/await where appropriate.
- Keep formatting logic out of SwiftUI views.
- Keep networking out of SwiftUI views.
- Add comments only when they clarify non-obvious decisions.
- Prefer simple abstractions over premature generalization.

## Dependency Rules

Do not add new external dependencies unless explicitly approved.

If a dependency is needed, explain:

- Why it is needed.
- What alternatives exist.
- Why native APIs are not enough.
- Where it will be used.

## Git / Generated Files

Do not commit build artifacts.

Avoid committing:

```text
Apricot.xcodeproj/
.gradle/
shared/build/
DerivedData/
.DS_Store
```

The Xcode project is generated from:

```text
project.yml
```

If `project.yml` changes, regenerate with:

```bash
make xcode
```

If KMP changes, rebuild with:

```bash
make kmp
```

## Working Style

- One branch should represent one focused task.
- Keep changes small and reviewable.
- Do not refactor unrelated code.
- Do not change project architecture unless explicitly requested.
- Do not silently introduce new product scope.
- If a requested change has risk, call it out before implementing.