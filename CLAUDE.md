# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## Build Commands

> These will be filled in once the project skeleton exists. Expected setup: Xcode for the iOS app, Gradle for the KMP shared module, and a top-level Makefile for convenience.

## Swift Version

- Target: Swift 5.9, iOS 17.0+, Xcode 15.x.
- Do not use Swift 6-only features or APIs requiring Swift 5.10+.
- The iOS app must compile with Swift 5 language mode.

## Architecture

```
Apricot iOS App
├── SwiftUI Presentation
├── Apricot Design System
├── Observability
└── Shared KMP Module
    ├── Domain (Bitcoin models)
    ├── Data (DTOs, mappers, repositories)
    ├── Use Cases
    ├── Mempool API Client
    └── Cache
```

**Layer ownership:**
- iOS app: SwiftUI views, navigation, app composition, design system, platform integrations.
- KMP shared module: domain models, DTOs, mappers, repositories, use cases, Mempool API client, cache.

**Rules:**
- DTOs must not leak into presentation code.
- Domain models must not depend on API-specific naming.
- Provider-specific code (Mempool.space) must be isolated behind repository interfaces.
- Feature flags must be abstracted behind a provider protocol.
- Observability must be abstracted behind protocols.
- Avoid business logic inside SwiftUI views.

## Data Provider

Initial provider: `mempool.space`. The KMP shared module hides all provider-specific details from the iOS app.

## Feature Flag

Initial flag: `addressInsightsEnabled`

When enabled, shows additional address-level insights: first/last activity, incoming/outgoing/mixed transaction classification, and simple activity insights.

## Observability

The observability layer is abstracted behind protocols. The first implementation is console-based.

Initial events: `address_search_started`, `address_search_succeeded`, `address_search_failed`, `transaction_opened`, `transaction_graph_viewed`, `cache_hit`, `cache_miss`.

## Cache

Simple in-memory TTL cache in the KMP shared module.

Targets: address summary (short TTL), transaction list (short TTL), confirmed transaction detail (longer TTL), pending transaction detail (short TTL).

## Testing Priorities

- KMP: domain models, DTO→domain mappers, address summary calculations, transaction direction classification, repository behavior, cache hit/miss/expiration.
- iOS: ViewModel state transitions, snapshot tests for main screens, UI test for happy path (search address → open transaction).

## Current Scope

Bitcoin only. MVP: search a public Bitcoin address, show address summary, show transaction list, open transaction detail, explain transaction data visually.

Out of scope: Ethereum, wallet connection, trading, authentication, push notifications, App Store release, complex AI summaries.

## Design System

Reference files in `docs/design/`:
- `colors_and_type.css` — color tokens and typography
- `components.css` — component recipes
- `design-system-summary.md` — design guidelines
- `ui_kits/` — screen mockups (Home, Address, Transaction, Loading, Error states)
- `screenshots/` and `preview/` — visual references

CSS files are references only. The iOS app uses native SwiftUI components and Swift design tokens.

Aesthetic: pastel, calm, premium, educational, approachable. Avoid neon/cyberpunk crypto aesthetics.

Blockchain-specific values (addresses, transaction IDs, hashes, fees, amounts) must use a polished monospaced style.

## Code Style

- Prefer explicit names and small types.
- Avoid force unwraps and large ViewModels.
- Favor async/await where appropriate.
- Comments only when they clarify non-obvious decisions.
