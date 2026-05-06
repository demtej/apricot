# ADR 006: Keep Observability Provider-Agnostic

## Status

Accepted

## Context

The app needs to track events and log information for debugging and product insight. The specific observability backend (console, PostHog, Crashlytics, or others) may change over time. If event-dispatching code references the backend SDK directly, every provider change requires touching feature code.

The same concern applies to feature flag evaluation. Both capabilities are third-party integrations that should not leak into domain or presentation logic.

## Decision

Define protocol-based abstractions for observability:

- An `AnalyticsTracker` protocol (or equivalent) with a single `track(event:properties:)` method.
- A `FeatureFlagProvider` protocol with a method to evaluate a named flag.

The iOS app's feature code dispatches events and reads flags through these protocols. The concrete implementations — PostHog analytics, PostHog feature flags, or a console logger — are injected at app startup.

When PostHog credentials are configured, `PostHogAnalyticsTracker` is the active `AnalyticsTracker` implementation, sending events to the PostHog dashboard. When credentials are absent, `ConsoleAnalyticsTracker` is used as a fallback, printing events to the debug console. Both are selected at app startup through `ObservabilityFactory`; no feature code changes when switching between them.

Tracked events: `address_search_started`, `address_search_succeeded`, `address_search_failed`, `transaction_opened`, `transaction_graph_viewed`, `cache_hit`, `cache_miss`.

## Consequences

**Positive:**
- Switching or adding observability backends requires a new protocol implementation and a change to the composition root, not changes to feature code.
- The console implementation is useful during development and adds no network calls in debug builds.
- Multiple implementations can be composed (e.g., console + PostHog simultaneously).
- Protocols are easy to mock in tests, so ViewModels that dispatch events can be tested without real analytics calls.

**Negative:**
- The abstraction adds a layer of indirection. For a project with one analytics backend this may feel like over-engineering.
- Protocol definitions must be kept in sync with the events the app actually needs. Adding a new event type requires updating the protocol or adding a generic fallback.

## Alternatives Considered

**Call PostHog SDK directly from ViewModels:** Simpler in the short term, but PostHog becomes a hard dependency throughout the codebase. Testing ViewModels would require either a real PostHog connection or swizzling.

**No analytics:** Avoids the dependency entirely. Appropriate for pure portfolio demos, but tracking a small set of events was included as a deliberate portfolio feature to demonstrate observability thinking.
