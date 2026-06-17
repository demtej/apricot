import SwiftUI

struct HomeView: View {
    private let bitcoinService: BitcoinServiceProtocol
    private let observability: AppObservability
    private let makeAddressViewModel: (String, RecentSearchStoring?) -> AddressViewModel
    @StateObject private var viewModel: HomeViewModel

    @State private var searchQuery = ""
    @State private var searchedAddress: String? = nil
    @State private var tickerDone = false
    @State private var showDisclaimer = false
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

            VStack(alignment: .leading, spacing: 0) {
                brandHeader
                heroSection
                searchSection
                ScrollView {
                    recentSection
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
        .onChange(of: searchedAddress) { _, new in
            if new == nil { searchQuery = "" }
        }
    }

    // MARK: - Sections

    private var brandHeader: some View {
        HStack(spacing: 0) {
            HStack(spacing: 10) {
                ApricotLogo(size: 32)
                Text("Apricot")
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.4)
                    .foregroundStyle(Color.apricotFgPrimary)
                if !tickerDone {
                    DisclaimerTicker(onComplete: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            tickerDone = true
                        }
                    })
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 10)
                } else {
                    Spacer()
                    Button {
                        showDisclaimer = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.apricotAccent)
                    }
                    .padding(.trailing, ApricotSpacing.s5)
                    .transition(.opacity.combined(with: .scale(scale: 0.6)))
                    .sheet(isPresented: $showDisclaimer) {
                        DisclaimerSheet()
                    }
                }
            }
            .padding(.leading, ApricotSpacing.s5)
            .layoutPriority(1)

            
        }
        .padding(.vertical, ApricotSpacing.s3)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            Text("Look up an address")
                .font(.apricotH1)
                .tracking(-0.68)
                .foregroundStyle(Color.apricotFgPrimary)
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
