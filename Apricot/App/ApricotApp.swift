import SwiftUI

@main
struct ApricotApp: App {
    @StateObject private var recentSearchStore = RecentSearchStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(recentSearchStore)
        }
    }
}
