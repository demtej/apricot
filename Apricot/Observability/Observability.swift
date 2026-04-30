import Foundation

protocol AnalyticsTracking {
    func track(_ event: ProductEvent)
}

protocol Logging {
    func log(
        level: LogLevel,
        message: String,
        metadata: [String: LogValue]
    )
}

enum LogLevel: String {
    case debug
    case info
    case error
}

enum LogValue: Equatable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    var description: String {
        switch self {
        case let .string(value):
            value
        case let .int(value):
            String(value)
        case let .double(value):
            String(format: "%.2f", value)
        case let .bool(value):
            value ? "true" : "false"
        }
    }
}

struct AppObservability {
    let analytics: AnalyticsTracking
    let logger: Logging

    static let noop = AppObservability(
        analytics: NoopAnalyticsTracker(),
        logger: NoopLogger()
    )

    static func live() -> AppObservability {
        let logger = ConsoleLogger()
        return AppObservability(
            analytics: ConsoleAnalyticsTracker(logger: logger),
            logger: logger
        )
    }
}

enum ProductEvent: Equatable {
    case addressSearchStarted(addressPreview: String)
    case addressSearchSucceeded(addressPreview: String, resultCount: Int, durationMs: Int)
    case addressSearchFailed(addressPreview: String, errorCategory: String, durationMs: Int)
    case transactionOpened(txIdPreview: String, addressPreview: String)
    case transactionDetailLoaded(txIdPreview: String, durationMs: Int)
    case transactionDetailFailed(txIdPreview: String, errorCategory: String, durationMs: Int)
    case transactionGraphViewed(txIdPreview: String)
    case recentSearchSelected(addressPreview: String)
    case cacheHit(resource: CacheResource, keyPreview: String)
    case cacheMiss(resource: CacheResource, keyPreview: String)

    var name: String {
        switch self {
        case .addressSearchStarted:
            "address_search_started"
        case .addressSearchSucceeded:
            "address_search_succeeded"
        case .addressSearchFailed:
            "address_search_failed"
        case .transactionOpened:
            "transaction_opened"
        case .transactionDetailLoaded:
            "transaction_detail_loaded"
        case .transactionDetailFailed:
            "transaction_detail_failed"
        case .transactionGraphViewed:
            "transaction_graph_viewed"
        case .recentSearchSelected:
            "recent_search_selected"
        case .cacheHit:
            "cache_hit"
        case .cacheMiss:
            "cache_miss"
        }
    }

    var properties: [String: LogValue] {
        switch self {
        case let .addressSearchStarted(addressPreview):
            [
                "address_preview": .string(addressPreview)
            ]
        case let .addressSearchSucceeded(addressPreview, resultCount, durationMs):
            [
                "address_preview": .string(addressPreview),
                "result_count": .int(resultCount),
                "duration_ms": .int(durationMs)
            ]
        case let .addressSearchFailed(addressPreview, errorCategory, durationMs):
            [
                "address_preview": .string(addressPreview),
                "error_category": .string(errorCategory),
                "duration_ms": .int(durationMs)
            ]
        case let .transactionOpened(txIdPreview, addressPreview):
            [
                "tx_id_preview": .string(txIdPreview),
                "address_preview": .string(addressPreview)
            ]
        case let .transactionDetailLoaded(txIdPreview, durationMs):
            [
                "tx_id_preview": .string(txIdPreview),
                "duration_ms": .int(durationMs)
            ]
        case let .transactionDetailFailed(txIdPreview, errorCategory, durationMs):
            [
                "tx_id_preview": .string(txIdPreview),
                "error_category": .string(errorCategory),
                "duration_ms": .int(durationMs)
            ]
        case let .transactionGraphViewed(txIdPreview):
            [
                "tx_id_preview": .string(txIdPreview)
            ]
        case let .recentSearchSelected(addressPreview):
            [
                "address_preview": .string(addressPreview)
            ]
        case let .cacheHit(resource, keyPreview), let .cacheMiss(resource, keyPreview):
            [
                "resource": .string(resource.rawValue),
                "key_preview": .string(keyPreview)
            ]
        }
    }
}

enum CacheResource: String, Equatable {
    case addressSummary = "address_summary"
    case addressTransactions = "address_transactions"
    case transactionDetail = "transaction_detail"
}

enum ObservabilityPrivacy {
    static func addressPreview(_ address: String) -> String {
        truncated(value: address, prefix: 10, suffix: 0)
    }

    static func txIdPreview(_ txId: String) -> String {
        truncated(value: txId, prefix: 8, suffix: 4)
    }

    static func cacheKeyPreview(_ key: String, resource: CacheResource) -> String {
        switch resource {
        case .transactionDetail:
            txIdPreview(key)
        case .addressSummary, .addressTransactions:
            addressPreview(key)
        }
    }

    private static func truncated(value: String, prefix: Int, suffix: Int) -> String {
        guard value.count > prefix + suffix else { return value }
        let prefixText = String(value.prefix(prefix))
        guard suffix > 0 else { return prefixText + "…" }
        let suffixText = String(value.suffix(suffix))
        return prefixText + "…" + suffixText
    }
}

final class ConsoleAnalyticsTracker: AnalyticsTracking {
    private let logger: Logging

    init(logger: Logging) {
        self.logger = logger
    }

    func track(_ event: ProductEvent) {
        logger.log(level: .info, message: "analytics_event", metadata: [
            "event_name": .string(event.name)
        ].merging(event.properties) { current, _ in current })
    }
}

final class ConsoleLogger: Logging {
    private let formatter = ISO8601DateFormatter()

    func log(
        level: LogLevel,
        message: String,
        metadata: [String: LogValue] = [:]
    ) {
        let timestamp = formatter.string(from: Date())
        let details = metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value.description)" }
            .joined(separator: " ")
        let suffix = details.isEmpty ? "" : " " + details
        print("[\(timestamp)] [\(level.rawValue.uppercased())] \(message)\(suffix)")
    }
}

struct NoopAnalyticsTracker: AnalyticsTracking {
    func track(_: ProductEvent) {}
}

struct NoopLogger: Logging {
    func log(
        level _: LogLevel,
        message _: String,
        metadata _: [String: LogValue]
    ) {}
}
