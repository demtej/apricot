# ADR 005: Use an In-Memory KMP Cache for MVP

## Status

Accepted

## Context

Fetching Bitcoin data from Mempool.space on every navigation event would result in redundant network calls and degraded perceived performance. Address summaries and transaction lists are reasonable candidates for short-term caching. Confirmed transaction details change rarely once on-chain and can be cached longer.

The cache must live in the KMP shared module to keep caching logic out of the iOS layer and to make it testable without a simulator.

## Decision

Implement a simple in-memory TTL cache in the KMP shared module. The cache stores values keyed by string (typically an address or transaction ID), evicts entries after a configurable TTL, and is invalidated on process restart since it holds no persistent state.

TTL targets:
- Address summary: short TTL (data changes as new transactions arrive)
- Transaction list: short TTL
- Confirmed transaction detail: longer TTL (rarely changes once confirmed)
- Pending transaction detail: short TTL (changes until confirmed)

Cache hit and miss events are dispatched through the observability layer.

## Consequences

**Positive:**
- Reduces redundant API calls during a session. Navigating back to an already-fetched address or transaction returns immediately from cache.
- The cache is fully under our control: no external dependencies, no storage permissions, no migration logic.
- Easy to test: cache hit, miss, and expiration scenarios are covered by KMP unit tests.

**Negative:**
- The cache does not survive app restarts. Every session starts cold.
- Memory is not bounded beyond TTL expiration. In normal single-user use this is not a concern, but it is worth noting.
- TTL-based invalidation can serve stale data within the TTL window if the underlying Bitcoin data changes (e.g., a new transaction arrives for an address).

## Alternatives Considered

**SQLDelight (persistent cache):** Would survive restarts and allow richer querying, but adds schema management and migration overhead. Unnecessary for an MVP where fresh data on restart is acceptable.

**NSCache / platform-native cache on the iOS side:** Would work for the iOS target but is not testable from KMP and would need to be reimplemented for any future Android target. Moving caching into the shared module is the cleaner long-term choice.

**No cache:** Simplest option, but the UX impact of re-fetching on every navigation event is noticeable, especially on slower connections.
