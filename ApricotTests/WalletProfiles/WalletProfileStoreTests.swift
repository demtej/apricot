@testable import Apricot
import SwiftData
import XCTest

@MainActor
final class WalletProfileStoreTests: XCTestCase {
    private var container: ModelContainer!
    private var store: WalletProfileStore!

    override func setUp() async throws {
        container = try ModelContainer(
            for: WalletProfile.self, Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = WalletProfileStore(context: container.mainContext)
    }

    override func tearDown() async throws {
        container = nil
        store = nil
    }

    // MARK: - resolveProfile

    func test_resolveProfile_createsNewProfile() {
        let profile = store.resolveProfile(for: "addr1", kind: .searched)
        XCTAssertEqual(profile.address, "addr1")
        XCTAssertEqual(profile.label, "S1")
        XCTAssertEqual(profile.color, .apricot)
        XCTAssertEqual(profile.kind, .searched)
    }

    func test_resolveProfile_returnsExistingProfileOnSecondCall() {
        let first = store.resolveProfile(for: "addr1", kind: .searched)
        let second = store.resolveProfile(for: "addr1", kind: .searched)
        XCTAssertTrue(first === second)
    }

    func test_resolveProfile_doesNotOverwriteKindOnSecondCall() {
        store.resolveProfile(for: "addr1", kind: .counterparty)
        let profile = store.resolveProfile(for: "addr1", kind: .searched)
        XCTAssertEqual(profile.kind, .counterparty)
    }

    func test_resolveProfile_sequenceNumbersIncrementPerKind() {
        let s1 = store.resolveProfile(for: "addr1", kind: .searched)
        let s2 = store.resolveProfile(for: "addr2", kind: .searched)
        let c1 = store.resolveProfile(for: "addr3", kind: .counterparty)
        XCTAssertEqual(s1.sequenceNumber, 1)
        XCTAssertEqual(s2.sequenceNumber, 2)
        XCTAssertEqual(c1.sequenceNumber, 1)
    }

    func test_resolveProfile_counterpartyGetsCorrectLabelPrefix() {
        let profile = store.resolveProfile(for: "addr1", kind: .counterparty)
        XCTAssertEqual(profile.label, "C1")
    }

    // MARK: - rename

    func test_rename_updatesLabel() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.rename(address: "addr1", to: "My Savings")
        XCTAssertEqual(store.profile(for: "addr1")?.label, "My Savings")
    }

    func test_rename_unknownAddress_doesNothing() {
        store.rename(address: "unknown", to: "whatever")
        XCTAssertNil(store.profile(for: "unknown"))
    }

    // MARK: - recolor

    func test_recolor_updatesColor() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.recolor(address: "addr1", to: .teal)
        XCTAssertEqual(store.profile(for: "addr1")?.color, .teal)
    }

    func test_recolor_allColorsRoundTrip() {
        store.resolveProfile(for: "addr1", kind: .searched)
        for color in WalletProfileColor.allCases {
            store.recolor(address: "addr1", to: color)
            XCTAssertEqual(store.profile(for: "addr1")?.color, color)
        }
    }

    // MARK: - setNotes

    func test_setNotes_updatesNotes() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.setNotes(address: "addr1", to: "Cold storage")
        XCTAssertEqual(store.profile(for: "addr1")?.notes, "Cold storage")
    }

    func test_setNotes_canBeCleared() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.setNotes(address: "addr1", to: "Some note")
        store.setNotes(address: "addr1", to: "")
        XCTAssertEqual(store.profile(for: "addr1")?.notes, "")
    }

    // MARK: - displayBadge

    func test_displayBadge_usesCurrentLabel() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.rename(address: "addr1", to: "Savings")
        XCTAssertEqual(store.displayBadge(for: "addr1"), "SAV")
    }

    func test_displayBadge_unknownAddress_returnsEmpty() {
        XCTAssertEqual(store.displayBadge(for: "unknown"), "")
    }

    // MARK: - profiles published property

    func test_profiles_includesAllResolvedProfiles() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.resolveProfile(for: "addr2", kind: .searched)
        store.resolveProfile(for: "addr3", kind: .counterparty)
        XCTAssertEqual(store.profiles.count, 3)
    }
}
