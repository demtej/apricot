import Foundation

enum FeatureFlagFactory {
    typealias RemoteProviderFactory = (String, String) -> any FeatureFlagProvider

    static func make(
        apiKey: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogAPIKey") as? String ?? "",
        host: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogHost") as? String ?? "",
        makeRemote: RemoteProviderFactory = { PostHogFeatureFlags(apiKey: $0, host: $1) }
    ) -> any FeatureFlagProvider {
        // xcconfig escapes // as \/ to avoid the comment character; sanitize before use.
        let sanitizedHost = host.replacingOccurrences(of: "\\/", with: "/")

        guard !apiKey.isEmpty, !sanitizedHost.isEmpty else {
            return LocalFeatureFlags()
        }
        return makeRemote(apiKey, sanitizedHost)
    }
}
