@testable import Apricot
import XCTest

final class FeatureFlagFactoryTests: XCTestCase {
    func test_emptyAPIKey_returnsLocalFeatureFlags() {
        let result = FeatureFlagFactory.make(apiKey: "", host: "https://us.i.posthog.com")

        XCTAssertTrue(result is LocalFeatureFlags)
    }

    func test_emptyHost_returnsLocalFeatureFlags() {
        let result = FeatureFlagFactory.make(apiKey: "phc_test", host: "")

        XCTAssertTrue(result is LocalFeatureFlags)
    }

    func test_emptyBoth_returnsLocalFeatureFlags() {
        let result = FeatureFlagFactory.make(apiKey: "", host: "")

        XCTAssertTrue(result is LocalFeatureFlags)
    }

    func test_validConfig_invokesRemoteProvider() {
        var remoteInvoked = false
        let stub = LocalFeatureFlags()

        let result = FeatureFlagFactory.make(
            apiKey: "phc_test",
            host: "https://us.i.posthog.com",
            makeRemote: { _, _ in
                remoteInvoked = true
                return stub
            }
        )

        XCTAssertTrue(remoteInvoked)
        XCTAssertTrue(result is LocalFeatureFlags)
    }

    func test_localFeatureFlagsDefaultsToEnabled() {
        let result = FeatureFlagFactory.make(apiKey: "", host: "")

        XCTAssertTrue(result.addressInsightsEnabled)
    }
}
