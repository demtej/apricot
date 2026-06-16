@testable import Apricot
import SwiftUI

@MainActor
final class AddressViewSnapshotTests: SnapshotTestCase {
    func test_addressView_loaded_withInsightsEnabled() {
        assertScreenSnapshot(
            of: makeAddressView(
                state: .loaded(
                    summary: SnapshotFixtures.summary,
                    transactions: SnapshotFixtures.addressTransactions,
                    showsInsights: true
                )
            ),
            named: "insights_on"
        )
    }

    func test_addressView_loaded_withInsightsDisabled() {
        assertScreenSnapshot(
            of: makeAddressView(
                state: .loaded(
                    summary: SnapshotFixtures.summary,
                    transactions: SnapshotFixtures.addressTransactions,
                    showsInsights: false
                )
            ),
            named: "insights_off"
        )
    }

    func test_addressView_loading() {
        assertScreenSnapshot(of: makeAddressView(state: .loading))
    }

    func test_addressView_failed() {
        assertScreenSnapshot(of: makeAddressView(state: .failed(.network)))
    }

    private func makeAddressView(state: AddressSearchState) -> some View {
        let service = SnapshotBitcoinService()
        let viewModel = AddressViewModel(
            address: SnapshotFixtures.address,
            service: service,
            observability: .noop,
            initialState: state
        )

        return NavigationStack {
            AddressView(
                address: SnapshotFixtures.address,
                viewModel: viewModel,
                service: service,
                loadsOnAppear: false
            )
        }
        .environmentObject(WalletProfileStore.preview())
    }
}
