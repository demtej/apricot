@testable import Apricot
import SwiftUI

@MainActor
final class HomeViewSnapshotTests: SnapshotTestCase {
    func test_homeView_default() {
        let store = SnapshotFixtures.makeRecentSearchStore()
        let service = SnapshotBitcoinService()

        assertScreenSnapshot(
            of: NavigationStack {
                HomeView(
                    bitcoinService: service,
                    viewModel: HomeViewModel(),
                    makeAddressSearchViewModel: { _ in
                        AddressSearchViewModel(service: service)
                    }
                )
            }
            .environmentObject(store)
        )
    }
}
