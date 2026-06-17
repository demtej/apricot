# Privacy Policy — Apricot

**Last updated:** May 2026

---

Apricot is a Bitcoin address and transaction explorer. This policy explains what data the app collects, how it is used, and what it does not do.

---

## What Apricot Does Not Collect

- **No private keys.** Apricot never asks for, receives, or stores Bitcoin private keys or seed phrases of any kind.
- **No wallet connection.** Apricot does not connect to any Bitcoin wallet. It reads only publicly available on-chain data.
- **No account or login.** Apricot requires no registration, sign-in, or personal account.
- **No full addresses or transaction IDs sent to analytics.** Any analytics events that reference an address or transaction ID use a truncated, non-identifying preview (e.g., the first 10 characters of an address).
- **No sale of personal data.** We do not sell, rent, or share your personal information with third parties for marketing or advertising purposes.
- **No financial data.** Apricot does not collect bank details, payment information, or any data linked to your personal finances.

---

## Data Collected

### Usage Analytics

Apricot uses **PostHog** (posthog.com) to collect anonymous usage events. These events help us understand how the app is used and improve it over time.

**Events collected include:**

| Event | Purpose | Data sent |
|---|---|---|
| `address_search_started` | Measure search usage | Truncated address preview (first 10 chars) |
| `address_search_succeeded` | Measure success rate | Truncated address preview, result count, duration |
| `address_search_failed` | Identify errors | Truncated address preview, error category, duration |
| `transaction_opened` | Measure feature usage | Truncated tx ID preview, truncated address preview |
| `transaction_detail_loaded` | Measure load performance | Truncated tx ID preview, duration |
| `transaction_detail_failed` | Identify errors | Truncated tx ID preview, error category |
| `transaction_graph_viewed` | Measure feature usage | Truncated tx ID preview |
| `recent_search_selected` | Measure feature usage | Truncated address preview |
| `cache_hit` / `cache_miss` | Measure cache effectiveness | Resource type, truncated key preview |

All previews are non-identifying truncations. Full Bitcoin addresses and transaction IDs are never transmitted to PostHog.

PostHog may also collect standard technical information as part of its SDK, including:
- Device type and operating system version
- App version
- Session identifiers (randomly generated, not linked to your identity)
- Approximate region (not precise location)

For details on PostHog's data practices, see: https://posthog.com/privacy

### Feature Flags

Apricot uses PostHog to deliver remote feature flags (e.g., enabling or disabling the Address Insights section). This involves a lightweight network request to the PostHog API at app launch. No personal data is sent as part of this request beyond what PostHog's SDK collects by default (see above).

### Bitcoin Blockchain Data

When you search for a Bitcoin address or transaction, Apricot queries the **mempool.space** public API to fetch on-chain data. This data is entirely public — any address or transaction on the Bitcoin blockchain is publicly visible to anyone.

Apricot does not send your device identity or any personal information to mempool.space beyond what is standard in an HTTPS request (IP address, User-Agent). For details on mempool.space's data practices, see their privacy policy at mempool.space.

### Recent Searches

Apricot stores the addresses you have recently searched on your device (local storage only). This data is never uploaded to any server. You can clear it by deleting the app.

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

*(Replace with a support email or web form URL before submission)*
