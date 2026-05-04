import SwiftUI

@main
struct ApricotApp: App {
    @StateObject private var recentSearchStore = RecentSearchStore()
    private let featureFlags: any FeatureFlagProviding
    private let observability: AppObservability
    private let bitcoinService: BitcoinServiceProtocol

    init() {
        let observability = AppObservability.live()
        featureFlags = FeatureFlagFactory.make()
        self.observability = observability
        bitcoinService = LiveBitcoinService(observability: observability)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(
                    bitcoinService: bitcoinService,
                    viewModel: HomeViewModel(observability: observability),
                    observability: observability
                ) { recentSearchStore in
                    AddressSearchViewModel(
                        service: bitcoinService,
                        featureFlags: featureFlags,
                        recentSearchStore: recentSearchStore,
                        observability: observability
                    )
                }
            }
            .environmentObject(recentSearchStore)
        }
    }
}
