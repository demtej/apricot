@testable import Apricot
import Foundation

final class TestAnalyticsTracker: AnalyticsTracking {
    private(set) var events: [ProductEvent] = []

    func track(_ event: ProductEvent) {
        events.append(event)
    }
}

final class TestLogger: Logging {
    struct Entry: Equatable {
        let level: LogLevel
        let message: String
        let metadata: [String: LogValue]
    }

    private(set) var entries: [Entry] = []

    func log(level: LogLevel, message: String, metadata: [String: LogValue]) {
        entries.append(Entry(level: level, message: message, metadata: metadata))
    }
}
