import SwiftUI

struct HomeView: View {
    private let bitcoinService: BitcoinServiceProtocol
    private let observability: AppObservability
    private let makeAddressViewModel: (String, RecentSearchStoring?) -> AddressViewModel
    @StateObject private var viewModel: HomeViewModel

    @State private var searchQuery = ""
    @State private var searchedAddress: String? = nil
    @EnvironmentObject private var recentSearchStore: RecentSearchStore

    init(
        bitcoinService: BitcoinServiceProtocol,
        viewModel: HomeViewModel,
        observability: AppObservability = .noop,
        makeAddressViewModel: @escaping (String, RecentSearchStoring?) -> AddressViewModel
    ) {
        self.bitcoinService = bitcoinService
        self.observability = observability
        self.makeAddressViewModel = makeAddressViewModel
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brandHeader
                    heroSection
                    searchSection
                    recentSection
                    disclaimerFooter
                }
            }
        }
        .navigationDestination(item: $searchedAddress) { address in
            AddressView(
                address: address,
                viewModel: makeAddressViewModel(address, recentSearchStore),
                service: bitcoinService,
                observability: observability
            )
        }
    }

    // MARK: - Sections

    private var brandHeader: some View {
        HStack(spacing: 10) {
            ApricotLogo(size: 32)
            Text("Apricot")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.apricotFgPrimary)
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.vertical, ApricotSpacing.s3)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            Text("Look up an address\nor transaction")
                .font(.apricotH1)
                .tracking(-0.68)
                .foregroundStyle(Color.apricotFgPrimary)

            Text("Paste a Bitcoin address or transaction ID.\nWe'll explain what we find.")
                .font(.apricotCaption)
                .foregroundStyle(Color.apricotFgSecondary)
                .lineSpacing(3)
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.top, ApricotSpacing.s4)
        .padding(.bottom, ApricotSpacing.s4)
    }

    private var searchSection: some View {
        ApricotSearchField(
            text: $searchQuery,
            onSubmit: {
                searchedAddress = viewModel.submitSearch(query: searchQuery)
            }
        )
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.bottom, ApricotSpacing.s6)
    }

    private var recentSection: some View {
        RecentSearchesSection(searches: recentSearchStore.searches) { item in
            searchedAddress = viewModel.selectRecentSearch(item)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerFooter: some View {
        Text("Apricot displays publicly available Bitcoin blockchain data. Not financial advice. No wallet connection. No private keys.")
            .font(.apricotLabel)
            .foregroundStyle(Color.apricotFgMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.top, ApricotSpacing.s6)
            .padding(.bottom, ApricotSpacing.s4)
    }
}

#Preview {
    let store = RecentSearchStore()
    let service = LiveBitcoinService()
    return NavigationStack {
        HomeView(bitcoinService: service, viewModel: HomeViewModel()) { address, recentSearchStore in
            AddressViewModel(
                address: address,
                service: service,
                featureFlags: LocalFeatureFlags(addressInsightsEnabled: false),
                recentSearchStore: recentSearchStore
            )
        }
    }
    .environmentObject(store)
    .environmentObject(WalletProfileStore.preview())
}
