@testable import Apricot
import XCTest

@MainActor
final class AddressSearchViewModelTests: XCTestCase {
    private var mockService = MockBitcoinService()
    private var viewModel = AddressSearchViewModel(service: MockBitcoinService())

    override func setUp() async throws {
        mockService = MockBitcoinService()
        viewModel = AddressSearchViewModel(service: mockService)
    }

    // MARK: - Initial state

    func test_initialState_isIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_initialAddressInput_isEmpty() {
        XCTAssertEqual(viewModel.addressInput, "")
    }

    // MARK: - Guard conditions

    func test_search_withEmptyInput_doesNotChangeState() {
        viewModel.addressInput = ""
        viewModel.search()
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_search_withWhitespaceOnly_doesNotChangeState() {
        viewModel.addressInput = "   "
        viewModel.search()
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Loading state is synchronous

    func test_search_withValidInput_setsLoadingStateSynchronously() {
        mockService.delay = 2_000_000_000 // delay so it stays loading
        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        XCTAssertEqual(viewModel.state, .loading)
    }

    // MARK: - Success: loaded

    func test_search_success_withTransactions_setsLoadedState() async throws {
        let summary = makeSummary()
        let transactions = [makeTransaction(direction: .incoming)]
        mockService.result = .success(AddressData(summary: summary, transactions: transactions))

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        guard case let .loaded(loadedSummary, loadedTransactions, showsInsights) = viewModel.state else {
            XCTFail("Expected .loaded, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loadedSummary, summary)
        XCTAssertEqual(loadedTransactions.count, 1)
        XCTAssertTrue(showsInsights)
    }

    // MARK: - Success: empty

    func test_search_success_withNoTransactions_setsEmptyState() async throws {
        let summary = makeSummary()
        mockService.result = .success(AddressData(summary: summary, transactions: []))

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        guard case let .empty(loadedSummary, showsInsights) = viewModel.state else {
            XCTFail("Expected .empty, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loadedSummary, summary)
        XCTAssertTrue(showsInsights)
    }

    func test_search_success_withInsightsDisabled_setsLoadedStateWithoutInsights() async throws {
        let summary = makeSummary()
        let transactions = [makeTransaction(direction: .incoming)]
        mockService.result = .success(AddressData(summary: summary, transactions: transactions))
        viewModel = AddressSearchViewModel(
            service: mockService,
            featureFlags: LocalFeatureFlags(addressInsightsEnabled: false)
        )

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        guard case let .loaded(loadedSummary, loadedTransactions, showsInsights) = viewModel.state else {
            XCTFail("Expected .loaded, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loadedSummary, summary)
        XCTAssertEqual(loadedTransactions.count, 1)
        XCTAssertFalse(showsInsights)
    }

    // MARK: - Failure

    func test_search_failure_notFound_setsFailedNotFoundState() async throws {
        mockService.result = .failure(AddressSearchError.notFound)

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        XCTAssertEqual(viewModel.state, .failed(.notFound))
    }

    func test_search_failure_network_setsFailedNetworkState() async throws {
        mockService.result = .failure(AddressSearchError.network)

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        XCTAssertEqual(viewModel.state, .failed(.network))
    }

    // MARK: - Clear

    func test_clear_resetsStateAndInput() async throws {
        let summary = makeSummary()
        mockService.result = .success(AddressData(summary: summary, transactions: [makeTransaction()]))

        viewModel.addressInput = "bc1qtest"
        viewModel.search()
        try await waitForNonLoading()

        viewModel.clear()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.addressInput, "")
    }

    // MARK: - Re-search cancels previous

    func test_consecutiveSearches_useLatestInput() async throws {
        let first = makeSummary(address: "bc1qfirst")
        let second = makeSummary(address: "bc1qsecond")

        // First search with a long delay
        mockService.delay = 5_000_000_000
        mockService.result = .success(AddressData(summary: first, transactions: []))
        viewModel.addressInput = "bc1qfirst"
        viewModel.search()

        // Immediately override with second search (no delay)
        mockService.delay = 0
        mockService.result = .success(AddressData(summary: second, transactions: []))
        viewModel.addressInput = "bc1qsecond"
        viewModel.search()

        try await waitForNonLoading()

        guard case let .empty(loadedSummary, _) = viewModel.state else {
            XCTFail("Expected .empty, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loadedSummary.address, "bc1qsecond")
    }

    // MARK: - Helpers

    private func waitForNonLoading(timeout: TimeInterval = 1.0) async throws {
        let deadline = Date.now.addingTimeInterval(timeout)
        while viewModel.state == .loading, Date.now < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertNotEqual(viewModel.state, .loading, "Timed out waiting for non-loading state")
    }

    private func makeSummary(address: String = "bc1qtest") -> AddressSummaryItem {
        AddressSummaryItem(
            address: address,
            shortAddress: BitcoinFormatter.shortAddress(address),
            confirmedBalanceBTC: "0.01 BTC",
            confirmedBalanceSats: "1,000,000 sats",
            totalReceivedBTC: "0.05 BTC",
            totalSentBTC: "0.04 BTC",
            transactionCount: 3
        )
    }

    private func makeTransaction(direction: TransactionDirectionDisplay = .incoming) -> TransactionItem {
        TransactionItem(
            id: "abc123def456789",
            shortId: "abc123de…",
            direction: direction,
            amountDisplay: "0.01000000 BTC",
            amountIsPositive: direction != .outgoing,
            isConfirmed: true,
            statusLabel: "Confirmed"
        )
    }
}

// MARK: - Mock service

final class MockBitcoinService: BitcoinServiceProtocol {
    var result: Result<AddressData, Error> = .success(AddressData(
        summary: AddressSummaryItem(
            address: "bc1qdefault",
            shortAddress: "bc1qdefault",
            confirmedBalanceBTC: "0.00 BTC",
            confirmedBalanceSats: "0 sats",
            totalReceivedBTC: "0.00 BTC",
            totalSentBTC: "0.00 BTC",
            transactionCount: 0
        ),
        transactions: []
    ))
    var delay: UInt64 = 0

    func fetchAddressData(address _: String) async throws -> AddressData {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }
        return try result.get()
    }

    func fetchTransactionDetail(txId _: String, forAddress _: String) async throws -> TransactionDetailItem {
        throw TransactionDetailError.unknown
    }
}
