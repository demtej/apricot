import SwiftData
import SwiftUI

@main
struct ApricotApp: App {
    @StateObject private var recentSearchStore = RecentSearchStore()
    @StateObject private var profileStore: WalletProfileStore
    private let aliasModelContainer: ModelContainer
    private let featureFlags: any FeatureFlagProvider
    private let observability: AppObservability
    private let bitcoinService: BitcoinServiceProtocol

    @State private var isSplashVisible = true

    init() {
        // Feature flags must initialize first: PostHogSDK.shared.setup() runs here when PostHog is configured.
        featureFlags = FeatureFlagFactory.make()
        let observability = ObservabilityFactory.make()
        self.observability = observability
        bitcoinService = LiveBitcoinService(observability: observability)

        do {
            let container = try ModelContainer(for: WalletProfile.self, Tag.self)
            aliasModelContainer = container
            _profileStore = StateObject(wrappedValue: WalletProfileStore(context: container.mainContext))
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("LaunchBackground").ignoresSafeArea()

                NavigationStack {
                    HomeView(
                        bitcoinService: bitcoinService,
                        viewModel: HomeViewModel(observability: observability),
                        observability: observability
                    ) { address, recentSearchStore in
                        AddressViewModel(
                            address: address,
                            service: bitcoinService,
                            featureFlags: featureFlags,
                            recentSearchStore: recentSearchStore,
                            profileStore: profileStore,
                            observability: observability
                        )
                    }
                }
                .environmentObject(recentSearchStore)
                .environmentObject(profileStore)

                if isSplashVisible {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeOut(duration: 0.35)) {
                                    isSplashVisible = false
                                }
                            }
                        }
                }
            }
        }
        .modelContainer(aliasModelContainer)
    }
}
