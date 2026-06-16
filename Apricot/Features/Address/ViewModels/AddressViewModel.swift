import Foundation

@MainActor
final class AddressViewModel: ObservableObject {
    @Published private(set) var state: AddressSearchState

    private let address: String
    private let service: BitcoinServiceProtocol
    private let featureFlags: any FeatureFlagProvider
    private let recentSearchStore: RecentSearchStoring?
    private let profileStore: WalletProfileStoring?
    private let observability: AppObservability
    private var loadTask: Task<Void, Never>?

    init(
        address: String,
        service: BitcoinServiceProtocol = LiveBitcoinService(),
        featureFlags: any FeatureFlagProvider = LocalFeatureFlags(),
        recentSearchStore: RecentSearchStoring? = nil,
        profileStore: WalletProfileStoring? = nil,
        observability: AppObservability = .noop,
        initialState: AddressSearchState = .idle
    ) {
        self.address = address
        self.service = service
        self.featureFlags = featureFlags
        self.recentSearchStore = recentSearchStore
        self.profileStore = profileStore
        self.observability = observability
        self.state = initialState
    }

    func load() {
        loadTask?.cancel()
        state = .loading
        let startedAt = Date()
        let addressPreview = ObservabilityPrivacy.addressPreview(address)
        observability.analytics.track(.addressSearchStarted(addressPreview: addressPreview))
        observability.logger.log(level: .info, message: "Address search started", metadata: [
            "address_preview": .string(addressPreview)
        ])
        loadTask = Task { [weak self] in
            await self?.doFetch(startedAt: startedAt)
        }
    }

    func didOpenTransaction(_ transaction: TransactionItem, forAddress address: String) {
        observability.analytics.track(.transactionOpened(
            txIdPreview: ObservabilityPrivacy.txIdPreview(transaction.id),
            addressPreview: ObservabilityPrivacy.addressPreview(address)
        ))
    }

    // MARK: - Private

    private func doFetch(startedAt: Date) async {
        do {
            let data = try await service.fetchAddressData(address: address)
            guard !Task.isCancelled else { return }
            let showsInsights = featureFlags.addressInsightsEnabled
            if data.transactions.isEmpty {
                state = .empty(summary: data.summary, showsInsights: showsInsights)
            } else {
                state = .loaded(
                    summary: data.summary,
                    transactions: data.transactions,
                    showsInsights: showsInsights
                )
            }
            // Fire profile resolution after yielding to SwiftUI so the loaded
            // state renders immediately rather than blocking on SwiftData I/O.
            Task { [weak self] in
                guard let self else { return }
                recentSearchStore?.add(address: address)
                profileStore?.resolveProfile(for: address, kind: .searched)
                for tx in data.transactions {
                    if let counterparty = tx.counterpartyAddress {
                        profileStore?.resolveProfile(for: counterparty, kind: .counterparty)
                    }
                }
            }
            let durationMs = Self.durationMs(since: startedAt)
            let addressPreview = ObservabilityPrivacy.addressPreview(address)
            observability.analytics.track(.addressSearchSucceeded(
                addressPreview: addressPreview,
                resultCount: data.transactions.count,
                durationMs: durationMs
            ))
            observability.logger.log(level: .info, message: "Address search succeeded", metadata: [
                "address_preview": .string(addressPreview),
                "duration_ms": .int(durationMs),
                "result_count": .int(data.transactions.count)
            ])
        } catch {
            guard !Task.isCancelled else { return }
            let searchError = (error as? AddressSearchError) ?? .unknown
            state = .failed(searchError)
            let durationMs = Self.durationMs(since: startedAt)
            let addressPreview = ObservabilityPrivacy.addressPreview(address)
            observability.analytics.track(.addressSearchFailed(
                addressPreview: addressPreview,
                errorCategory: searchError.analyticsCategory,
                durationMs: durationMs
            ))
            observability.logger.log(level: .error, message: "Address search failed", metadata: [
                "address_preview": .string(addressPreview),
                "duration_ms": .int(durationMs),
                "error_category": .string(searchError.analyticsCategory)
            ])
        }
    }

    private static func durationMs(since startedAt: Date) -> Int {
        Int(Date().timeIntervalSince(startedAt) * 1000)
    }
}
