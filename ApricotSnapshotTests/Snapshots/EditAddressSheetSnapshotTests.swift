@testable import Apricot
import SwiftUI

@MainActor
final class EditAddressSheetSnapshotTests: SnapshotTestCase {

    // MARK: - EditAddressSheet

    func test_editAddressSheet_defaultState() {
        assertScreenSnapshot(
            of: EditAddressSheet(
                address: SnapshotFixtures.address,
                label: "S1",
                color: .apricot,
                notes: ""
            )
            .environmentObject(SnapshotFixtures.makeWalletProfileStore()),
            named: "default"
        )
    }

    func test_editAddressSheet_customAliasAndColor() {
        assertScreenSnapshot(
            of: EditAddressSheet(
                address: SnapshotFixtures.address,
                label: "Savings",
                color: .teal,
                notes: "Cold storage — moved here after the April rebalance."
            )
            .environmentObject(SnapshotFixtures.makeWalletProfileStore()),
            named: "custom_alias_teal"
        )
    }

    func test_editAddressSheet_aliasWithSpaces() {
        assertScreenSnapshot(
            of: EditAddressSheet(
                address: SnapshotFixtures.address,
                label: "AL RIO",
                color: .pink,
                notes: ""
            )
            .environmentObject(SnapshotFixtures.makeWalletProfileStore()),
            named: "alias_with_spaces"
        )
    }

    func test_editAddressSheet_withTags() {
        assertScreenSnapshot(
            of: EditAddressSheet(
                address: SnapshotFixtures.address,
                label: "Cold Storage",
                color: .blue,
                notes: "Long-term hold.",
                tags: ["cold storage", "dca"]
            )
            .environmentObject(SnapshotFixtures.makeWalletProfileStore()),
            named: "with_tags"
        )
    }

    // MARK: - RecentSearchesSection

    func test_recentSearches_defaultColors() {
        let searches = [
            RecentSearch(address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh", searchedAt: Date(timeIntervalSince1970: 1_000_000)),
            RecentSearch(address: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy", searchedAt: Date(timeIntervalSince1970: 996_400)),
            RecentSearch(address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", searchedAt: Date(timeIntervalSince1970: 913_600)),
        ]

        assertScreenSnapshot(
            of: ZStack {
                Color.apricotBgPage.ignoresSafeArea()
                VStack {
                    RecentSearchesSection(searches: searches, onSelect: { _ in })
                        .padding(.top, 20)
                    Spacer()
                }
            }
            .environmentObject(SnapshotFixtures.makeWalletProfileStore()),
            named: "default_colors"
        )
    }
}
