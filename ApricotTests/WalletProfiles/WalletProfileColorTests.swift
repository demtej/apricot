@testable import Apricot
import SwiftData
import SwiftUI
import XCTest

final class WalletProfileColorTests: XCTestCase {
    func test_allCases_colorDoesNotCrash() {
        for c in WalletProfileColor.allCases {
            _ = c.color
        }
    }

    func test_rawValues_roundTrip() {
        for c in WalletProfileColor.allCases {
            XCTAssertEqual(WalletProfileColor(rawValue: c.rawValue), c)
        }
    }

    func test_rawValues_areExpectedStrings() {
        XCTAssertEqual(WalletProfileColor.apricot.rawValue, "apricot")
        XCTAssertEqual(WalletProfileColor.coral.rawValue, "coral")
        XCTAssertEqual(WalletProfileColor.amber.rawValue, "amber")
        XCTAssertEqual(WalletProfileColor.green.rawValue, "green")
        XCTAssertEqual(WalletProfileColor.teal.rawValue, "teal")
        XCTAssertEqual(WalletProfileColor.blue.rawValue, "blue")
        XCTAssertEqual(WalletProfileColor.pink.rawValue, "pink")
        XCTAssertEqual(WalletProfileColor.purple.rawValue, "purple")
    }

    func test_legacyHexRawValue_returnsNil() {
        XCTAssertNil(WalletProfileColor(rawValue: "F4A26B"))
        XCTAssertNil(WalletProfileColor(rawValue: "1D9E75"))
        XCTAssertNil(WalletProfileColor(rawValue: "unknown"))
    }

    func test_caseCount_isEight() {
        XCTAssertEqual(WalletProfileColor.allCases.count, 8)
    }
}

// MARK: - WalletProfile.color computed property

@MainActor
final class WalletProfileColorFallbackTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var container: ModelContainer!

    override func setUp() async throws {
        container = try ModelContainer(
            for: WalletProfile.self, Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    override func tearDown() async throws {
        container = nil
    }

    func test_color_validRawValue_returnsMatchingCase() {
        let profile = WalletProfile(address: "a", label: "S1", color: .teal, kind: .searched, sequenceNumber: 1)
        XCTAssertEqual(profile.color, .teal)
        XCTAssertEqual(profile.colorHex, "teal")
    }

    func test_color_legacyHexString_fallsBackToApricot() {
        let profile = WalletProfile(address: "a", label: "S1", color: .apricot, kind: .searched, sequenceNumber: 1)
        // Simulate legacy data by directly setting colorHex to an old hex string
        profile.colorHex = "F4A26B"
        XCTAssertEqual(profile.color, .apricot)
    }

    func test_color_setter_updatesColorHex() {
        let profile = WalletProfile(address: "a", label: "S1", color: .apricot, kind: .searched, sequenceNumber: 1)
        profile.color = .purple
        XCTAssertEqual(profile.colorHex, "purple")
        XCTAssertEqual(profile.color, .purple)
    }

    func test_color_allCases_roundTripThroughColorHex() {
        let profile = WalletProfile(address: "a", label: "S1", color: .apricot, kind: .searched, sequenceNumber: 1)
        for c in WalletProfileColor.allCases {
            profile.color = c
            XCTAssertEqual(profile.color, c, "Failed round-trip for \(c.rawValue)")
        }
    }
}
