import XCTest
@testable import Apricot

@MainActor
final class TransactionDetailViewModelTests: XCTestCase {

    private var mockService: MockTransactionService!
    private var viewModel: TransactionDetailViewModel!

    override func setUp() async throws {
        mockService = MockTransactionService()
        viewModel = TransactionDetailViewModel(service: mockService)
    }

    // MARK: - Initial state

    func test_initialState_isIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Loading is synchronous

    func test_load_setsLoadingStateSynchronously() {
        mockService.delay = 2_000_000_000
        viewModel.load(txId: "abc123", forAddress: "bc1qtest")
        XCTAssertEqual(viewModel.state, .loading)
    }

    // MARK: - Success

    func test_load_success_setsLoadedState() async throws {
        let item = makeDetail()
        mockService.transactionResult = .success(item)

        viewModel.load(txId: item.id, forAddress: "bc1qtest")
        try await waitForNonLoading()

        guard case .loaded(let loaded) = viewModel.state else {
            XCTFail("Expected .loaded, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loaded.id, item.id)
    }

    // MARK: - Failure: not found

    func test_load_failure_notFound_setsFailedState() async throws {
        mockService.transactionResult = .failure(TransactionDetailError.notFound)

        viewModel.load(txId: "abc123", forAddress: "bc1qtest")
        try await waitForNonLoading()

        XCTAssertEqual(viewModel.state, .failed(.notFound))
    }

    // MARK: - Failure: network

    func test_load_failure_network_setsFailedState() async throws {
        mockService.transactionResult = .failure(TransactionDetailError.network)

        viewModel.load(txId: "abc123", forAddress: "bc1qtest")
        try await waitForNonLoading()

        XCTAssertEqual(viewModel.state, .failed(.network))
    }

    // MARK: - Failure: unknown error mapped to .unknown

    func test_load_failure_unknownError_mapsToUnknown() async throws {
        struct SomeError: Error {}
        mockService.transactionResult = .failure(SomeError())

        viewModel.load(txId: "abc123", forAddress: "bc1qtest")
        try await waitForNonLoading()

        XCTAssertEqual(viewModel.state, .failed(.unknown))
    }

    // MARK: - Retry

    func test_retry_reloadsAndSetsLoadedState() async throws {
        mockService.transactionResult = .failure(TransactionDetailError.network)
        viewModel.load(txId: "abc123", forAddress: "bc1qtest")
        try await waitForNonLoading()
        XCTAssertEqual(viewModel.state, .failed(.network))

        let item = makeDetail()
        mockService.transactionResult = .success(item)
        viewModel.retry(txId: item.id, forAddress: "bc1qtest")
        try await waitForNonLoading()

        guard case .loaded = viewModel.state else {
            XCTFail("Expected .loaded after retry, got \(viewModel.state)")
            return
        }
    }

    // MARK: - Cancellation: second load wins

    func test_consecutiveLoads_useLatestResult() async throws {
        let first = makeDetail(id: "aaaa1111")
        let second = makeDetail(id: "bbbb2222")

        mockService.delay = 5_000_000_000
        mockService.transactionResult = .success(first)
        viewModel.load(txId: first.id, forAddress: "bc1qtest")

        mockService.delay = 0
        mockService.transactionResult = .success(second)
        viewModel.load(txId: second.id, forAddress: "bc1qtest")
        try await waitForNonLoading()

        guard case .loaded(let loaded) = viewModel.state else {
            XCTFail("Expected .loaded, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(loaded.id, second.id)
    }

    // MARK: - Helpers

    private func waitForNonLoading(timeout: TimeInterval = 1.0) async throws {
        let deadline = Date.now.addingTimeInterval(timeout)
        while viewModel.state == .loading, Date.now < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertNotEqual(viewModel.state, .loading, "Timed out waiting for non-loading state")
    }

    private func makeDetail(id: String = "abc123def456") -> TransactionDetailItem {
        TransactionDetailItem(
            id: id,
            shortId: String(id.prefix(8)) + "…",
            summary: "You received 0.01000000 BTC in this confirmed transaction.",
            direction: .incoming,
            status: .confirmed,
            confirmations: 6,
            blockHeight: 800_000,
            timestamp: "Apr 29, 2026 at 12:00 PM",
            feeBTC: "0.00001000 BTC",
            feeSats: "1,000 sat",
            netAmountDisplay: "0.01000000 BTC",
            netAmountIsPositive: true,
            inputCount: 1,
            outputCount: 2,
            inputs: [
                IOItem(
                    index: 0,
                    address: "bc1qsender",
                    amountBTC: "0.01001000 BTC",
                    amountSats: "1,001,000 sat",
                    isRelevantAddress: false
                )
            ],
            outputs: [
                IOItem(
                    index: 0,
                    address: "bc1qtest",
                    amountBTC: "0.01000000 BTC",
                    amountSats: "1,000,000 sat",
                    isRelevantAddress: true
                ),
                IOItem(
                    index: 1,
                    address: "bc1qchange",
                    amountBTC: "0.00000000 BTC",
                    amountSats: "0 sat",
                    isRelevantAddress: false
                )
            ]
        )
    }
}

// MARK: - Mock service

final class MockTransactionService: BitcoinServiceProtocol {
    var transactionResult: Result<TransactionDetailItem, Error> = .failure(TransactionDetailError.unknown)
    var delay: UInt64 = 0

    func fetchAddressData(address: String) async throws -> AddressData {
        throw AddressSearchError.unknown
    }

    func fetchTransactionDetail(txId: String, forAddress: String) async throws -> TransactionDetailItem {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }
        return try transactionResult.get()
    }
}
