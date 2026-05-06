import Foundation
import PostHog

final class PostHogFeatureFlags: FeatureFlagProvider {
    private static let flagKey = "address-insights-enabled"

    init(apiKey: String, host: String) {
        let maskedKey = Self.mask(apiKey)

        let config = PostHogConfig(projectToken: apiKey, host: host)
        PostHogSDK.shared.setup(config)

        // preloadFeatureFlags defaults to true; flags are fetched automatically after setup.
        // didReceiveFeatureFlags fires each time a flags response arrives (success or failure).
        NotificationCenter.default.addObserver(
            forName: PostHogSDK.didReceiveFeatureFlags,
            object: nil,
            queue: nil
        ) { _ in
            let raw = PostHogSDK.shared.getFeatureFlag(Self.flagKey)
        }
    }

    var addressInsightsEnabled: Bool {
        // isFeatureEnabled returns false when the flag is disabled or not yet loaded.
        // PostHog omits disabled flags from the response (nil), which correctly maps to false here.
        PostHogSDK.shared.isFeatureEnabled(Self.flagKey)
    }

    private static func mask(_ key: String) -> String {
        guard key.count > 11 else { return String(repeating: "*", count: key.count) }
        return "\(key.prefix(8))…\(key.suffix(3))"
    }
}
