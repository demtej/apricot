@testable import Apricot
import SwiftUI

@MainActor
final class TransactionDetailViewSnapshotTests: SnapshotTestCase {
    func test_transactionDetailView_loaded() {
        let transaction = SnapshotFixtures.addressTransactions[0]
        let viewModel = TransactionDetailViewModel(
            service: SnapshotBitcoinService(),
            observability: .noop,
            initialState: .loaded(SnapshotFixtures.detail)
        )

        assertScreenSnapshot(
            of: NavigationStack {
                TransactionDetailView(
                    transaction: transaction,
                    forAddress: SnapshotFixtures.address,
                    viewModel: viewModel,
                    loadsOnAppear: false
                )
            }
            .environmentObject(WalletProfileStore.preview())
        )
    }
}
