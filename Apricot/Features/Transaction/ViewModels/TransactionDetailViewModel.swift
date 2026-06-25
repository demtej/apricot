import Foundation

@MainActor
final class TransactionDetailViewModel: ObservableObject {
    @Published private(set) var state: TransactionDetailState = .idle

    private let service: BitcoinServiceProtocol
    private let profileStore: WalletProfileStoring?
    private let observability: AppObservability
    private var loadTask: Task<Void, Never>?
    private var graphViewTrackedTxId: String?

    init(
        service: BitcoinServiceProtocol = LiveBitcoinService(),
        profileStore: WalletProfileStoring? = nil,
        observability: AppObservability = .noop,
        initialState: TransactionDetailState = .idle
    ) {
        state = initialState
        self.service = service
        self.profileStore = profileStore
        self.observability = observability
    }

    func load(txId: String, forAddress: String) {
        loadTask?.cancel()
        state = .loading
        graphViewTrackedTxId = nil
        let startedAt = Date()
        let txPreview = ObservabilityPrivacy.txIdPreview(txId)
        observability.logger.log(level: .info, message: "Transaction detail load started", metadata: [
            "tx_id_preview": .string(txPreview)
        ])
        loadTask = Task { [weak self] in
            await self?.doLoad(txId: txId, forAddress: forAddress, startedAt: startedAt)
        }
    }

    func retry(txId: String, forAddress: String) {
        load(txId: txId, forAddress: forAddress)
    }

    // MARK: - Private

    func trackTransactionGraphViewed(txId: String) {
        guard graphViewTrackedTxId != txId else { return }
        graphViewTrackedTxId = txId
        observability.analytics.track(.transactionGraphViewed(
            txIdPreview: ObservabilityPrivacy.txIdPreview(txId)
        ))
    }

    private func doLoad(txId: String, forAddress: String, startedAt: Date) async {
        do {
            let item = try await service.fetchTransactionDetail(txId: txId, forAddress: forAddress)
            guard !Task.isCancelled else { return }
            state = .loaded(item)
            Task { [weak self] in self?.resolveCounterpartyProfiles(item, forAddress: forAddress) }
            let durationMs = Self.durationMs(since: startedAt)
            let txPreview = ObservabilityPrivacy.txIdPreview(txId)
            observability.analytics.track(.transactionDetailLoaded(
                txIdPreview: txPreview,
                durationMs: durationMs
            ))
            observability.logger.log(level: .info, message: "Transaction detail loaded", metadata: [
                "duration_ms": .int(durationMs),
                "tx_id_preview": .string(txPreview)
            ])
        } catch {
            if Task.isCancelled { return }
            let detailError = (error as? TransactionDetailError) ?? .unknown
            state = .failed(detailError)
            let durationMs = Self.durationMs(since: startedAt)
            let txPreview = ObservabilityPrivacy.txIdPreview(txId)
            observability.analytics.track(.transactionDetailFailed(
                txIdPreview: txPreview,
                errorCategory: detailError.analyticsCategory,
                durationMs: durationMs
            ))
            observability.logger.log(level: .error, message: "Transaction detail failed", metadata: [
                "duration_ms": .int(durationMs),
                "error_category": .string(detailError.analyticsCategory),
                "tx_id_preview": .string(txPreview)
            ])
        }
    }

    private func resolveCounterpartyProfiles(_ item: TransactionDetailItem, forAddress: String) {
        guard let profileStore else { return }
        let counterpartyAddresses = (item.inputs + item.outputs)
            .compactMap(\.address)
            .filter { $0 != forAddress }
        for address in Set(counterpartyAddresses) {
            profileStore.resolveProfile(for: address, kind: .counterparty)
        }
    }

    private static func durationMs(since startedAt: Date) -> Int {
        Int(Date().timeIntervalSince(startedAt) * 1000)
    }
}
