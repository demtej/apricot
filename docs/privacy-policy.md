# Privacy Policy — Apricot

**Last updated:** May 2026

Apricot is a Bitcoin address and transaction explorer for iOS. This policy explains what data the app collects, how it is used, and what it does not do.

---

## What Apricot Does Not Collect

- **No private keys.** Apricot never asks for, receives, or stores Bitcoin private keys or seed phrases of any kind.
- **No wallet connection.** Apricot does not connect to any Bitcoin wallet. It reads only publicly available on-chain data.
- **No account or login.** Apricot requires no registration, sign-in, or personal account.
- **No trading.** Apricot does not support buying, selling, or trading Bitcoin or any other asset.
- **No financial advice.** Nothing in Apricot should be interpreted as a recommendation to buy, sell, or hold Bitcoin or any other asset.
- **No full addresses sent to analytics.** Any analytics events that reference an address or transaction ID use a truncated, non-identifying preview (e.g., the first 10 characters of an address).
- **No sale of personal data.** We do not sell, rent, or share personal information with third parties for marketing or advertising purposes.

---

## Data Collected

### Usage Analytics

Apricot uses **PostHog** ([posthog.com](https://posthog.com)) to collect anonymous usage events. These events help us understand how the app is used and improve it over time.

Events include: `address_search_started`, `address_search_succeeded`, `address_search_failed`, `transaction_opened`, `transaction_graph_viewed`, `cache_hit`, `cache_miss`, and similar interaction signals.

All address and transaction references in analytics are truncated non-identifying previews. Full Bitcoin addresses and transaction IDs are never transmitted to PostHog.

PostHog may also collect standard technical information, including device type, OS version, app version, a randomly generated session identifier, and approximate region. For details, see [posthog.com/privacy](https://posthog.com/privacy).

### Feature Flags

Apricot uses PostHog to deliver remote feature flags. This involves a lightweight network request to the PostHog API at app launch. No personal data beyond PostHog's standard SDK collection is sent as part of this request.

### Bitcoin Blockchain Data

When you search for a Bitcoin address or transaction, Apricot queries the **mempool.space** public API to fetch on-chain data. This data is entirely public — any address or transaction on the Bitcoin blockchain is publicly visible to anyone.

Apricot does not send your device identity or any personal information to mempool.space beyond what is standard in an HTTPS request (IP address, User-Agent).

### Recent Searches

Apricot stores addresses you have recently searched **on your device only**. This data is never uploaded to any server. You can clear it by deleting the app.

---

## Data Retention

- **Analytics events** are retained by PostHog per their data retention policy.
- **Recent searches** are stored locally on your device and are deleted when you uninstall the app.
- **No other data** is stored by Apricot or its developer.

---

## Children's Privacy

Apricot is not directed to children under 13. We do not knowingly collect personal information from children under 13.

---

## Changes to This Policy

If this policy changes materially, we will update the "Last updated" date above. Continued use of the app after changes constitutes acceptance of the updated policy.

---

## Contact

If you have questions about this privacy policy, contact us at:

**Email:** apricotappsupport@gmail.com

---

[← Back to Apricot](index.md) · [Support](support.md)
