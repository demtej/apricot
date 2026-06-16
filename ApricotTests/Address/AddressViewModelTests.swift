@testable import Apricot
import XCTest

@MainActor
final class AddressViewModelTests: XCTestCase {
    private var mockService = MockBitcoinService()
    private var analytics = TestAnalyticsTracker()
    private var logger = TestLogger()

    override func setUp() async throws {
        mockService = MockBitcoinService()
        analytics = TestAnalyticsTracker()
        logger = TestLogger()
    }

    private func makeViewModel(
        address: String = "bc1qtest",
        initialState: AddressSearchState = .idle
    ) -> AddressViewModel {
        AddressViewModel(
            address: address,
            service: mockService,
            observability: AppObservability(analytics: analytics, logger: logger),
            initialState: initialState
        )
    }

    // MARK: - Initial state

    func test_initialState_isIdle() {
        XCTAssertEqual(makeViewModel().state, .idle)
    }

    // MARK: - Loading state is synchronous

    func test_load_setsLoadingStateSynchronously() {
        mockService.delay = 2_000_000_000
        let vm = makeViewModel()
        vm.load()
        XCTAssertEqual(vm.state, .loading)
    }

    // MARK: - Success: loaded

    func test_load_success_withTransactions_setsLoadedState() async throws {
        let summary = makeSummary()
        let transactions = [makeTransaction(direction: .incoming)]
        mockService.result = .success(AddressData(summary: summary, transactions: transactions))

        let vm = makeViewModel()
        vm.load()
        try await waitForNonLoading(vm)

        guard case let .loaded(loadedSummary, loadedTransactions, showsInsights) = vm.state else {
            return XCTFail("Expected .loaded, got \(vm.state)")
        }
        XCTAssertEqual(loadedSummary, summary)
        XCTAssertEqual(loadedTransactions.count, 1)
        XCTAssertTrue(showsInsights)
        XCTAssertEqual(analytics.events.first, .addressSearchStarted(addressPreview: "bc1qtest"))
        XCTAssertEqual(analytics.events.count, 2)
        guard case let .addressSearchSucceeded(addressPreview, resultCount, durationMs) = analytics.events[1] else {
            return XCTFail("Expected address_search_succeeded event")
        }
        XCTAssertEqual(addressPreview, "bc1qtest")
        XCTAssertEqual(resultCount, 1)
        XCTAssertGreaterThanOrEqual(durationMs, 0)
    }

    // MARK: - Success: empty

    func test_load_success_withNoTransactions_setsEmptyState() async throws {
        let summary = makeSummary()
        mockService.result = .success(AddressData(summary: summary, transactions: []))

        let vm = makeViewModel()
        vm.load()
        try await waitForNonLoading(vm)

        guard case let .empty(loadedSummary, showsInsights) = vm.state else {
            return XCTFail("Expected .empty, got \(vm.state)")
        }
        XCTAssertEqual(loadedSummary, summary)
        XCTAssertTrue(showsInsights)
    }

    func test_load_success_withInsightsDisabled_setsLoadedStateWithoutInsights() async throws {
        let summary = makeSummary()
        let transactions = [makeTransaction(direction: .incoming)]
        mockService.result = .success(AddressData(summary: summary, transactions: transactions))
        let vm = AddressViewModel(
            address: "bc1qtest",
            service: mockService,
            featureFlags: LocalFeatureFlags(addressInsightsEnabled: false)
        )

        vm.load()
        try await waitForNonLoading(vm)

        guard case let .loaded(_, _, showsInsights) = vm.state else {
            return XCTFail("Expected .loaded, got \(vm.state)")
        }
        XCTAssertFalse(showsInsights)
    }

    // MARK: - Failure

    func test_load_failure_notFound_setsFailedNotFoundState() async throws {
        mockService.result = .failure(AddressSearchError.notFound)

        let vm = makeViewModel()
        vm.load()
        try await waitForNonLoading(vm)

        XCTAssertEqual(vm.state, .failed(.notFound))
        XCTAssertEqual(analytics.events.count, 2)
        guard case let .addressSearchFailed(addressPreview, errorCategory, durationMs) = analytics.events[1] else {
            return XCTFail("Expected address_search_failed event")
        }
        XCTAssertEqual(addressPreview, "bc1qtest")
        XCTAssertEqual(errorCategory, "not_found")
        XCTAssertGreaterThanOrEqual(durationMs, 0)
    }

    func test_load_failure_network_setsFailedNetworkState() async throws {
        mockService.result = .failure(AddressSearchError.network)

        let vm = makeViewModel()
        vm.load()
        try await waitForNonLoading(vm)

        XCTAssertEqual(vm.state, .failed(.network))
    }

    // MARK: - didOpenTransaction

    func test_didOpenTransaction_tracksTransactionOpened() {
        let vm = makeViewModel()
        let transaction = makeTransaction()
        vm.didOpenTransaction(transaction, forAddress: "bc1qtestaddress123")

        XCTAssertEqual(analytics.events, [
            .transactionOpened(
                txIdPreview: "abc123de…6789",
                addressPreview: "bc1qtestad…"
            )
        ])
    }

    // MARK: - initialState for testing

    func test_initialState_canBeOverridden() {
        let summary = makeSummary()
        let vm = makeViewModel(initialState: .empty(summary: summary, showsInsights: false))
        guard case .empty = vm.state else {
            return XCTFail("Expected .empty")
        }
    }

    // MARK: - Helpers

    private func waitForNonLoading(_ vm: AddressViewModel, timeout: TimeInterval = 1.0) async throws {
        let deadline = Date.now.addingTimeInterval(timeout)
        while vm.state == .loading, Date.now < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertNotEqual(vm.state, .loading, "Timed out waiting for non-loading state")
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
            statusLabel: "Confirmed",
            counterpartyAddress: nil
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
