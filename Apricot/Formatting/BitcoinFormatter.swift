import Foundation

/// Centralized formatting utilities for Bitcoin values.
///
/// BTC amounts always use a dot decimal separator regardless of device locale.
/// Sats use comma grouping. Dates use the device locale and timezone.
enum BitcoinFormatter {

    // MARK: - Cached formatters

    private static let btcFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.decimalSeparator = "."        // explicit dot — ignores device locale
        f.usesGroupingSeparator = false
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 8
        return f
    }()

    private static let satsFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.usesGroupingSeparator = true
        f.maximumFractionDigits = 0
        return f
    }()

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    // MARK: - BTC

    /// Formats satoshis as a BTC string with a guaranteed dot decimal separator.
    /// Trailing zeros above 2 decimal places are trimmed.
    ///
    ///     100_000_000 → "1.00 BTC"
    ///     1_234_567   → "0.01234567 BTC"
    ///     1_000_000   → "0.01 BTC"
    static func btc(_ sats: Int64) -> String {
        let value = Double(sats) / 100_000_000.0
        let formatted = btcFormatter.string(from: NSNumber(value: value))
            ?? String(format: "%.8f", value)
        return formatted + " BTC"
    }

    // MARK: - Sats

    /// Formats a satoshi count with comma grouping and correct singular/plural unit.
    ///
    ///     1         → "1 sat"
    ///     1_234_567 → "1,234,567 sats"
    static func sats(_ value: Int64) -> String {
        let formatted = satsFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let unit = abs(value) == 1 ? "sat" : "sats"
        return formatted + " " + unit
    }

    // MARK: - Truncation

    /// Shortens a transaction ID to first 8 + "…" + last 4 characters.
    ///
    ///     "a1075db55d416d3ca199f55b6084e211…fc80e9d5fbf5d48d" → "a1075db5…d48d"
    static func shortTxId(_ txId: String) -> String {
        guard txId.count > 13 else { return txId }
        return String(txId.prefix(8)) + "…" + String(txId.suffix(4))
    }

    /// Shortens a Bitcoin address to first 8 + "…" + last 6 characters.
    ///
    ///     "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz" → "bc1qar0s…59gtzz"
    static func shortAddress(_ address: String) -> String {
        guard address.count > 16 else { return address }
        return String(address.prefix(8)) + "…" + String(address.suffix(6))
    }

    // MARK: - Date

    /// Formats a Unix epoch timestamp as a human-readable date and time using the device locale.
    ///
    ///     1_714_435_200 → "Apr 30, 2024 at 2:00 AM"  (locale-dependent)
    static func timestamp(epochSeconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochSeconds))
        return timestampFormatter.string(from: date)
    }
}
