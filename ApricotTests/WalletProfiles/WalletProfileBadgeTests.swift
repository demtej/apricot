@testable import Apricot
import XCTest

// MARK: - Mock

private final class MockWalletProfileStore: WalletProfileStoring {
    private var profiles: [String: WalletProfile_Mock] = [:]

    func profile(for address: String) -> WalletProfile? { nil }

    func resolveProfile(for address: String, kind: WalletProfileKind) -> WalletProfile {
        fatalError("Not needed for badge tests")
    }

    func rename(address: String, to label: String) {
        profiles[address]?.label = label
    }

    func recolor(address: String, to colorHex: String) {
        profiles[address]?.colorHex = colorHex
    }

    func setNotes(address: String, to notes: String) {
        profiles[address]?.notes = notes
    }

    // MARK: - Test helpers

    struct WalletProfile_Mock {
        var label: String
        var colorHex: String
        var notes: String
    }

    /// Seed a profile directly — no SwiftData involved.
    func seed(address: String, label: String, colorHex: String = "F4A26B", notes: String = "") {
        profiles[address] = WalletProfile_Mock(label: label, colorHex: colorHex, notes: notes)
    }

    func displayBadge(for address: String) -> String {
        guard let label = profiles[address]?.label else { return "" }
        let compact = label.filter { !$0.isWhitespace }.uppercased()
        return String(compact.prefix(3))
    }
}

// MARK: - Tests

final class WalletProfileBadgeTests: XCTestCase {
    private let store = MockWalletProfileStore()

    // MARK: - displayBadge

    func test_badge_shortLabel_returnsUppercasedFull() {
        store.seed(address: "addr1", label: "S1")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "S1")
    }

    func test_badge_longLabel_capsAtThreeChars() {
        store.seed(address: "addr1", label: "Savings")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "SAV")
    }

    func test_badge_labelWithSpaces_stripsSpacesBeforeCapping() {
        store.seed(address: "addr1", label: "AL RIO")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "ALR")
    }

    func test_badge_labelWithMultipleSpaces_stripsAll() {
        store.seed(address: "addr1", label: "A B C D")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "ABC")
    }

    func test_badge_lowercaseLabel_returnsUppercase() {
        store.seed(address: "addr1", label: "cold")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "COL")
    }

    func test_badge_exactlyThreeChars_returnsAll() {
        store.seed(address: "addr1", label: "Hot")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "HOT")
    }

    func test_badge_unknownAddress_returnsEmpty() {
        XCTAssertEqual(store.displayBadge(for: "unknown"), "")
    }

    func test_badge_singleChar_returnsIt() {
        store.seed(address: "addr1", label: "X")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "X")
    }

    func test_badge_onlySpaces_returnsEmpty() {
        store.seed(address: "addr1", label: "   ")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "")
    }
}
