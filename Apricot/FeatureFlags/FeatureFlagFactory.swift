import Foundation

enum FeatureFlagFactory {
    typealias RemoteProviderFactory = (String, String) -> any FeatureFlagProvider

    static func make(
        apiKey: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogAPIKey") as? String ?? "",
        host: String = Bundle.main.object(forInfoDictionaryKey: "ApricotPostHogHost") as? String ?? "",
        makeRemote: RemoteProviderFactory = { PostHogFeatureFlags(apiKey: $0, host: $1) },
        skipNetworkInTests: Bool = isRunningTests
    ) -> any FeatureFlagProvider {
        guard !skipNetworkInTests else { return LocalFeatureFlags() }

        // xcconfig escapes // as \/ to avoid the comment character; sanitize before use.
        let sanitizedHost = host.replacingOccurrences(of: "\\/", with: "/")

        guard !apiKey.isEmpty, !sanitizedHost.isEmpty else {
            return LocalFeatureFlags()
        }
        return makeRemote(apiKey, sanitizedHost)
    }

    /// True when the process is an XCTest host. Checked via env vars that Xcode sets on the
    /// test-runner process before any app code runs (reliable even at static-init time).
    static var isRunningTests: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["XCTestConfigurationFilePath"] != nil
            || env["XCTestBundlePath"] != nil
            || env["XCInjectBundleInto"] != nil
    }
}
