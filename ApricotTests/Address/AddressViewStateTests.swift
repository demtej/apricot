@testable import Apricot
import XCTest

final class AddressViewStateTests: XCTestCase {
    private let dummySummary = AddressSummaryItem(
        address: "bc1qtest",
        shortAddress: "bc1q…test",
        confirmedBalanceBTC: "0.00 BTC",
        confirmedBalanceSats: "0 sats",
        totalReceivedBTC: "0.00 BTC",
        totalSentBTC: "0.00 BTC",
        transactionCount: 0
    )

    func test_isLoaded_whenLoaded_returnsTrue() {
        let state = AddressSearchState.loaded(summary: dummySummary, transactions: [], showsInsights: false)
        XCTAssertTrue(state.isLoaded)
    }

    func test_isLoaded_whenEmpty_returnsTrue() {
        let state = AddressSearchState.empty(summary: dummySummary, showsInsights: false)
        XCTAssertTrue(state.isLoaded)
    }

    func test_isLoaded_whenIdle_returnsFalse() {
        XCTAssertFalse(AddressSearchState.idle.isLoaded)
    }

    func test_isLoaded_whenLoading_returnsFalse() {
        XCTAssertFalse(AddressSearchState.loading.isLoaded)
    }

    func test_isLoaded_whenFailed_returnsFalse() {
        XCTAssertFalse(AddressSearchState.failed(.network).isLoaded)
    }
}
