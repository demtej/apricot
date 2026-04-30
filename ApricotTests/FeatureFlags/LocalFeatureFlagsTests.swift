import XCTest
@testable import Apricot

final class LocalFeatureFlagsTests: XCTestCase {

    func test_defaultAddressInsightsEnabled_isTrue() {
        let flags = LocalFeatureFlags()

        XCTAssertTrue(flags.addressInsightsEnabled)
    }

    func test_addressInsightsEnabled_canBeOverriddenToFalse() {
        let flags = LocalFeatureFlags(addressInsightsEnabled: false)

        XCTAssertFalse(flags.addressInsightsEnabled)
    }
}
