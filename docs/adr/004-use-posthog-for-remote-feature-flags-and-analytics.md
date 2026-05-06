# ADR 004: Use PostHog for Remote Feature Flags and Analytics

## Status

Accepted

## Context

Apricot needs two capabilities: the ability to toggle features remotely without shipping a new build, and basic analytics to understand how users interact with the app.

Feature flags are used to gate the `addressInsightsEnabled` feature. Analytics events include address searches, transaction opens, cache hits/misses, and graph views.

Both capabilities are typically provided by third-party services. Choosing separate services for flags and analytics adds integration overhead and increases the number of external dependencies.

## Decision

Use PostHog as a single provider for both remote feature flags and event analytics. PostHog's iOS SDK is integrated into the app and configured with the project API key.

Feature flag evaluation is abstracted behind a `FeatureFlagProvider` protocol. Analytics events are dispatched through an observability protocol. The iOS app does not depend on PostHog types directly; it depends on the protocols. PostHog is the concrete implementation injected at app startup.

## Consequences

**Positive:**
- One SDK and one dashboard covers both flags and analytics, reducing integration surface area.
- PostHog has a generous free tier that covers the expected usage volume for this project.
- The protocol-based abstraction means PostHog can be replaced without changes to feature or observability code.
- PostHog is self-hostable if data residency becomes a concern.

**Negative:**
- Adding any third-party SDK increases app binary size and introduces a dependency on an external service.
- PostHog's iOS SDK is not as widely used as Amplitude or Firebase, so community resources are more limited.
- Remote flag evaluation introduces a network dependency at startup. If PostHog is unreachable, flags fall back to defaults — this behavior must be explicitly designed for.

## Alternatives Considered

**Firebase (Remote Config + Analytics):** Mature and widely used, but heavier integration and ties the app to the Google ecosystem. Combining two Firebase products also adds configuration complexity.

**LaunchDarkly (flags) + Mixpanel or Amplitude (analytics):** Best-in-class for each concern individually, but two separate SDKs and two dashboards with no cross-referencing between events and flags. Overkill for an MVP.

**Local feature flags only:** Avoids the external dependency entirely but requires a new build to toggle features, which defeats the purpose of flags for testing or staged rollouts.
