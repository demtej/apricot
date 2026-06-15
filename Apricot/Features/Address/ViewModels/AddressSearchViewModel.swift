import Foundation

@MainActor
final class AddressSearchViewModel: ObservableObject {
    @Published private(set) var state: AddressSearchState = .idle
    @Published var addressInput: String = ""

    private let service: BitcoinServiceProtocol
    private let featureFlags: any FeatureFlagProvider
    private let recentSearchStore: RecentSearchStoring?
    private let profileStore: WalletProfileStoring?
    private let observability: AppObservability
    private var searchTask: Task<Void, Never>?

    init(
        service: BitcoinServiceProtocol = LiveBitcoinService(),
        featureFlags: any FeatureFlagProvider = LocalFeatureFlags(),
        recentSearchStore: RecentSearchStoring? = nil,
        profileStore: WalletProfileStoring? = nil,
        observability: AppObservability = .noop,
        initialState: AddressSearchState = .idle
    ) {
        state = initialState
        self.service = service
        self.featureFlags = featureFlags
        self.recentSearchStore = recentSearchStore
        self.profileStore = profileStore
        self.observability = observability
    }

    /// Sets state to .loading synchronously, then starts the async fetch.
    func search() {
        let trimmed = addressInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        searchTask?.cancel()
        state = .loading
        let startedAt = Date()
        let addressPreview = ObservabilityPrivacy.addressPreview(trimmed)
        observability.analytics.track(.addressSearchStarted(addressPreview: addressPreview))
        observability.logger.log(level: .info, message: "Address search started", metadata: [
            "address_preview": .string(addressPreview)
        ])
        searchTask = Task { [weak self] in
            await self?.doFetch(address: trimmed, startedAt: startedAt)
        }
    }

    func clear() {
        searchTask?.cancel()
        addressInput = ""
        state = .idle
    }

    // MARK: - Private

    func didOpenTransaction(_ transaction: TransactionItem, forAddress address: String) {
        observability.analytics.track(.transactionOpened(
            txIdPreview: ObservabilityPrivacy.txIdPreview(transaction.id),
            addressPreview: ObservabilityPrivacy.addressPreview(address)
        ))
    }

    private func doFetch(address: String, startedAt: Date) async {
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
            recentSearchStore?.add(address: address)
            profileStore?.resolveProfile(for: address, kind: .searched)
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
