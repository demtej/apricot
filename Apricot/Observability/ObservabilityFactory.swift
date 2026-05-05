import Foundation

enum ObservabilityFactory {
    /// Assumes PostHogSDK.shared.setup() has already been called
    /// (done by FeatureFlagFactory when PostHog is configured).
    static func make(
        apiKey: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogAPIKey") as? String ?? "",
        host: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogHost") as? String ?? ""
    ) -> AppObservability {
        let sanitizedHost = host.replacingOccurrences(of: "\\/", with: "/")
        let logger = ConsoleLogger()

        let analytics: AnalyticsTracking = if !apiKey.isEmpty, !sanitizedHost.isEmpty {
            PostHogAnalyticsTracker()
        } else {
            ConsoleAnalyticsTracker(logger: logger)
        }

        return AppObservability(analytics: analytics, logger: logger)
    }
}
