# ADR 002: Use Mempool.space as the Initial Bitcoin Data Provider

## Status

Accepted

## Context

Apricot needs a Bitcoin data source to fetch address summaries and transaction lists. Options include running a self-hosted node, using a paid block explorer API, or relying on a free public API.

For an MVP portfolio project with no backend, a self-hosted node is out of scope. Paid APIs introduce billing complexity and secrets management overhead that are unnecessary at this stage.

## Decision

Use the public Mempool.space REST API as the sole data provider for the initial release.

All Mempool-specific code — HTTP client setup, endpoint paths, response DTOs, and mappers — lives inside the KMP shared module and is hidden behind repository interfaces. The iOS app and use cases depend only on domain types and repository protocols, not on Mempool.space details.

## Consequences

**Positive:**
- No API key or account required for development or demo use.
- Mempool.space is a well-maintained, widely used Bitcoin explorer with a stable public API.
- Rate limits are permissive enough for interactive single-user use.
- Provider details are fully isolated; swapping to a different provider requires only a new repository implementation, not changes to the iOS app or use cases.

**Negative:**
- The public endpoint has no SLA. In production, rate limits or downtime would directly affect users.
- The API is not versioned with stability guarantees. Field names or response structures could change without notice.
- For a real release, Mempool.space recommends self-hosting their instance or using their paid tier.

## Alternatives Considered

**Blockstream.info API:** Similar scope and trade-offs. Mempool.space was chosen because it offers a cleaner UI for manual verification during development and is actively maintained.

**Self-hosted Mempool instance:** Eliminates rate limit concerns but requires infrastructure, which is out of scope for an MVP portfolio project.

**Paid block explorer APIs (e.g., Blockchain.com, QuickNode):** Would provide stronger availability guarantees but add account management and secret handling with no benefit at the current scale.
