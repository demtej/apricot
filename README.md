<p align="center">
  <img src="docs/assets/app-icon.png" width="96" alt="Apricot app icon" />
</p>

<h1 align="center">Apricot</h1>

<p align="center">
  Bitcoin on-chain tracking, investigation, and audit — built with SwiftUI and Kotlin Multiplatform.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/iOS-17.0%2B-blue?logo=apple&logoColor=white" alt="iOS 17.0+" />
  <img src="https://img.shields.io/badge/Kotlin_Multiplatform-2.0-7F52FF?logo=kotlin&logoColor=white" alt="Kotlin Multiplatform" />
  <img src="https://img.shields.io/badge/Xcode-15.x-1575F9?logo=xcode&logoColor=white" alt="Xcode 15" />
</p>

---

Apricot is a Bitcoin address tracker designed for on-chain investigation and auditing. Users can search any public Bitcoin address, label it, attach notes, assign it a color, and relate it to other wallets seen in transactions — building a persistent local picture of on-chain activity across sessions.

The core idea: every address you touch — whether you searched it or discovered it as a counterparty in a transaction — gets a profile. Profiles carry labels, colors, and notes you define. Over time this creates a graph of related wallets that you can use to follow fund flows, trace UTXOs, and audit transaction history without losing context between sessions.

---

## Screenshots

<p align="center">
  <img src="docs/screenshots/home.png" width="220" alt="Home screen" />
  <img src="docs/screenshots/address.png" width="220" alt="Address detail" />
  <img src="docs/screenshots/address2.png" width="220" alt="Address detail edit" />
  <img src="docs/screenshots/transaction-detail.png" width="220" alt="Transaction detail" />
  <img src="docs/screenshots/transaction-flow.png" width="220" alt="Transaction flow" />
</p>

## Demo

<img src="docs/screenshots/demo.gif" alt="Apricot app demo" width="320">

---

## Architecture

```
Apricot iOS App
├── SwiftUI Presentation
├── Apricot Design System
├── Wallet Profiles (SwiftData)
├── Observability
└── Shared KMP Module
    ├── Domain (Bitcoin models, repository interfaces)
    ├── Data (DTOs, mappers, Mempool.space repository)
    ├── Use Cases
    ├── Cache (in-memory TTL)
    └── Mempool API Client (Ktor)
```

**Layer ownership:**

| Layer | Owns |
|---|---|
| iOS app | SwiftUI views, navigation, app composition, design system, platform integrations, wallet profile persistence (SwiftData) |
| KMP shared module | Domain models, DTOs, mappers, repositories, use cases, API client, cache |

### Wallet profiles and address tracking

Every Bitcoin address encountered in the app — whether searched directly or discovered as a counterparty in a transaction — gets a persistent wallet profile. Profiles are created automatically on first encounter and carry:

- **Label** — auto-assigned (`S1, S2, …` for addresses you search; `C1, C2, …` for counterparties you discover), fully user-editable.
- **Color** — visual tag for grouping related wallets at a glance.
- **Notes** — free-form field for investigation context, suspicion flags, or audit trails.

An address keeps its first-assigned label even if later encountered through a different path, so your annotations survive as you follow transaction chains. All profile data is local-only, persisted with SwiftData (`Apricot/Features/WalletProfiles/`), independent of the KMP shared module.

**Boundaries enforced by convention:**
- DTOs never reach the presentation layer — mappers convert them to domain models at the data boundary.
- Domain models never import API-specific types.
- The Mempool.space provider is hidden behind a `BitcoinRepository` interface; the iOS app never references it directly.
- Observability and feature flags are accessed through protocols so implementations can be swapped without touching call sites.

---

## Technical Highlights

### Kotlin Multiplatform shared layer

Business and data logic lives in a KMP module compiled to an XCFramework and embedded into the iOS app. The iOS app consumes domain models and use cases via Swift, with no knowledge of the underlying Kotlin types.

The KMP module includes:
- `BitcoinRepository` — repository interface and two concrete implementations: `MempoolBitcoinRepository` (live API) and `CachingBitcoinRepository` (TTL cache wrapper).
- Three use cases: `GetAddressSummary`, `GetAddressTransactions`, `GetTransactionDetail`.
- DTO types for the Mempool.space API and mappers that convert them to clean domain models.
- An in-memory TTL cache with differentiated TTLs: confirmed transaction details are cached longer than pending ones; address summaries and transaction lists use short TTLs.

### Design system

The app ships its own design system implemented in Swift:
- **Tokens**: `ApricotColors` (warm pastel palette with light/dark variants), `ApricotTypography` (Geist sans + JetBrains Mono), `ApricotSpacing`.
- **Components**: `ApricotButton`, `ApricotCard`, `ApricotStatCard`, `ApricotSearchField`, `ApricotBadge`, `MonoText`, `ApricotLoadingState`, `ApricotErrorState`, `ApricotEmptyState`.
- Blockchain-specific values (addresses, transaction IDs, fees, amounts) are always rendered in `MonoText` — a styled monospaced component that gives them a distinct, readable appearance.

Reference files for the design system are in `docs/design/`.

---

## Observability & Feature Flags

Both are abstracted behind protocols so they can be swapped without changing call sites.

### PostHog integration (optional)

PostHog powers remote feature flags and production analytics. Configuration is read from a local xcconfig file that is not committed to the repo.

To configure PostHog locally:

```bash
cp Config/Apricot.example.xcconfig Config/Apricot.local.xcconfig
# then edit Config/Apricot.local.xcconfig and add your key and host
```

```
APRICOT_POSTHOG_API_KEY = phc_your_key_here
APRICOT_POSTHOG_HOST = https://us.i.posthog.com
```

After editing, run `make xcode` to regenerate the Xcode project.

### Without PostHog credentials

The app builds and runs for any contributor without PostHog access:
- Feature flags fall back to `LocalFeatureFlags` with all flags enabled.
- Analytics fall back to `ConsoleAnalyticsTracker`, which logs events to the console via `ConsoleLogger`.

### Analytics events

All events use privacy-safe previews. Addresses are truncated to 10 characters and transaction IDs to 8+4 characters — full values are never sent.

| Event | Properties |
|---|---|
| `address_search_started` | `address_preview` |
| `address_search_succeeded` | `address_preview`, `result_count`, `duration_ms` |
| `address_search_failed` | `address_preview`, `error_category`, `duration_ms` |
| `transaction_opened` | `tx_id_preview`, `address_preview` |
| `transaction_detail_loaded` | `tx_id_preview`, `duration_ms` |
| `transaction_detail_failed` | `tx_id_preview`, `error_category`, `duration_ms` |
| `transaction_graph_viewed` | `tx_id_preview` |
| `recent_search_selected` | `address_preview` |
| `cache_hit` | `resource`, `key_preview` |
| `cache_miss` | `resource`, `key_preview` |

### Feature flags

The initial remote flag is `address-insights-enabled` (PostHog key) → `addressInsightsEnabled` (app code). When enabled, the app shows additional address-level insights: first/last activity, incoming/outgoing/mixed transaction classification, and a simple activity summary.


### Dashboard

<p align="center">
  <img src="docs/screenshots/posthog-dashboard.png" width="900" alt="PostHog analytics dashboard" />
</p>

---

## Testing & CI

### KMP tests

Unit tests for domain models, DTO mappers, use cases, cache hit/miss/expiration, and repository behavior.

```bash
./gradlew :shared:allTests
```

### iOS unit tests

ViewModel state transition tests and business logic tests.

```bash
xcodebuild -project Apricot.xcodeproj -scheme ApricotUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

### Snapshot tests

Snapshot tests live under `ApricotSnapshotTests/` and use fixed Swift-only fixtures — no network calls, no PostHog, no real KMP layer. All snapshots are recorded at a fixed 390×844 light-mode configuration for determinism.

```bash
# Run locally
xcodebuild -project Apricot.xcodeproj -scheme ApricotSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Record or refresh reference images
make record-snapshots
```

Reference images are committed under `ApricotSnapshotTests/Snapshots/__Snapshots__/`.

> **Note:** Snapshot test execution in CI is currently disabled. macOS CI runners and local Xcode environments can produce subtly different rendering output, causing spurious failures. The infrastructure is in place — it's a known limitation to address before shipping.

### GitHub Actions CI

The CI pipeline runs on every pull request and push to `main`:

| Job | Runner | What it checks |
|---|---|---|
| SwiftLint | macos-latest | Lint rules via `make lint` |
| SwiftFormat | macos-latest | Formatting via `make format-check` |
| KMP Tests | macos-latest | All Kotlin shared module tests |
| iOS Unit Tests | macos-15 | ApricotUnitTests scheme |
| iOS Build | macos-15 | App compiles cleanly for simulator |

---

## Getting Started

### Requirements

- Xcode 15.x
- Java 17+ (for Gradle)
- `xcodegen` — `brew install xcodegen`
- `swiftlint` and `swiftformat` — `brew install swiftlint swiftformat`

### First-time setup

```bash
make bootstrap   # builds debug + release KMP XCFrameworks, then generates Apricot.xcodeproj
```

Open `Apricot.xcodeproj` in Xcode after running bootstrap.

### Common commands

```bash
make kmp              # rebuild debug KMP XCFramework (required after shared/ changes)
make kmp-release      # rebuild release KMP XCFramework (required for Archive / TestFlight)
make kmp-all          # rebuild both debug and release KMP XCFrameworks
make xcode            # regenerate Apricot.xcodeproj from project.yml
make lint             # run SwiftLint
make format           # format Swift files
make format-check     # check formatting without modifying files
make clean            # clean Gradle outputs and remove generated Xcode project
```

For normal day-to-day development, `make kmp && make xcode` is enough — Xcode only needs the
debug XCFramework when running on the simulator/device from the IDE.

### Archive / TestFlight

Archiving (Product > Archive, or a TestFlight upload) requires the **release** XCFramework at
`shared/build/XCFrameworks/release/shared.xcframework`. If only the debug XCFramework has been
built, Xcode fails with "There is no XCFramework found at
shared/build/XCFrameworks/release/shared.xcframework".

```bash
make prepare-archive    # clean stale Xcode artifacts, build release XCFramework, regenerate project
make validate-archive   # prepare-archive, then run a Release archive from the console via xcodebuild
make preflight-release  # lint, format-check, build debug+release XCFrameworks, regenerate
                         # project, run unit tests, and a Release build of the app
```

Before submitting to TestFlight / the App Store, run `make preflight-release` and then either
`make prepare-archive` (to archive from Xcode's UI) or `make validate-archive` (to validate the
archive entirely from the console).

---

## Architecture Decisions

Key technical decisions are recorded as Architecture Decision Records in [`docs/adr/`](docs/adr/). A few highlights:

- [ADR 001](docs/adr/001-use-kotlin-multiplatform-for-shared-bitcoin-logic.md) — KMP hosts all Bitcoin domain logic, mappers, use cases, and the Ktor API client. The iOS app consumes it as an XCFramework via a Swift-native facade.
- [ADR 002](docs/adr/002-use-mempool-space-as-initial-bitcoin-data-provider.md) — Mempool.space is the initial data provider, fully isolated behind repository interfaces so the rest of the app is provider-agnostic.
- [ADR 003](docs/adr/003-use-xcodegen-as-project-source-of-truth.md) — `project.yml` is the source of truth for the Xcode project; `Apricot.xcodeproj` is generated and git-ignored.
- [ADR 004](docs/adr/004-use-posthog-for-remote-feature-flags-and-analytics.md) — PostHog provides both remote feature flags (`FeatureFlagProvider`) and event analytics (`AnalyticsTracker`) behind protocol abstractions.
- [ADR 005](docs/adr/005-use-in-memory-kmp-cache-for-mvp.md) — A simple TTL cache in the KMP shared module reduces redundant API calls within a session.
- [ADR 006](docs/adr/006-keep-observability-provider-agnostic.md) — Analytics and logging are dispatched through protocols; PostHog is active when configured, console is the fallback.
- [ADR 007](docs/adr/007-keep-snapshot-tests-local-until-ci-is-stabilized.md) — Snapshot tests run locally only until CI rendering is consistent enough to avoid false positives.

---

## Known Limitations & Future Work

- **UTXO graph** — UTXO-level traceability (linking specific outputs across transactions) is the natural next step beyond address-level tracking; not yet implemented.
- **Wallet relationship graph** — a visual graph of addresses linked through transactions is planned but not yet built.
- **Snapshot tests in CI** — disabled due to rendering differences between local Xcode environments and macOS CI runners. Infrastructure is ready; execution pending a stable approach.
- **UI tests** — the happy path (search → transaction detail) is planned but not yet implemented.
- **Error handling** — basic error states are in place; deeper recovery flows are out of scope for the MVP.
- **Single data provider** — Mempool.space is the only backend. The repository interface is designed to support additional providers.
- **Bitcoin only** — Ethereum and other chains are out of scope.
- **No wallet connection** — read-only; no key management, signing, or transaction broadcasting.
