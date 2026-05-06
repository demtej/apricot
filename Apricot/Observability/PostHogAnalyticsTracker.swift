import Foundation
import PostHog

final class PostHogAnalyticsTracker: AnalyticsTracker {
    typealias Capture = (_ eventName: String, _ properties: [String: Any]) -> Void

    private let capture: Capture

    init(capture: @escaping Capture = PostHogAnalyticsTracker.postHogCapture) {
        self.capture = capture
    }

    func track(_ event: ProductEvent) {
        let properties = event.properties.mapValues { $0.anyValue }
        capture(event.name, properties)
    }

    private static func postHogCapture(eventName: String, properties: [String: Any]) {
        PostHogSDK.shared.capture(eventName, properties: properties.isEmpty ? nil : properties)
    }
}

private extension LogValue {
    var anyValue: Any {
        switch self {
        case let .string(value): value
        case let .int(value): value
        case let .double(value): value
        case let .bool(value): value
        }
    }
}
