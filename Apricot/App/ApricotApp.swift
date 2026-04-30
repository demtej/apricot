import SwiftUI

@main
struct ApricotApp: App {
    @StateObject private var recentSearchStore = RecentSearchStore()
    private let featureFlags = LocalFeatureFlags()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView { recentSearchStore in
                    AddressSearchViewModel(
                        featureFlags: featureFlags,
                        recentSearchStore: recentSearchStore
                    )
                }
            }
            .environmentObject(recentSearchStore)
        }
    }
}
