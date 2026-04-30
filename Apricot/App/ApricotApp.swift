import SwiftUI

@main
struct ApricotApp: App {
    @StateObject private var recentSearchStore = RecentSearchStore()
    private let featureFlags = LocalFeatureFlags()
    private let bitcoinService: BitcoinServiceProtocol = LiveBitcoinService()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(bitcoinService: bitcoinService) { recentSearchStore in
                    AddressSearchViewModel(
                        service: bitcoinService,
                        featureFlags: featureFlags,
                        recentSearchStore: recentSearchStore
                    )
                }
            }
            .environmentObject(recentSearchStore)
        }
    }
}
