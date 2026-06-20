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
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var recentSearchStore: RecentSearchStore
    @EnvironmentObject private var profileStore: WalletProfileStore

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
                    if isFiltering {
                        filterSection
                    } else {
                        recentSection
                    }
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
        .onAppear { viewModel.checkClipboard() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.checkClipboard() }
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

    private var isFiltering: Bool {
        !searchQuery.isEmpty
    }

    private var filteredProfiles: [WalletProfile] {
        let q = searchQuery.lowercased()
        return profileStore.profiles.filter { profile in
            profile.label.lowercased().contains(q)
                || profile.notes.lowercased().contains(q)
                || profile.tags.contains { $0.name.lowercased().contains(q) }
        }
    }

    private var searchSection: some View {
        VStack(spacing: 0) {
            ApricotSearchField(
                text: $searchQuery,
                onSubmit: {
                    searchedAddress = viewModel.submitSearch(query: searchQuery)
                },
                onPaste: viewModel.clipboardBitcoinAddress.map { address in
                    { searchedAddress = address }
                }
            )

            if showEmptyHint {
                emptyStateHint
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.bottom, ApricotSpacing.s6)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showEmptyHint)
    }

    private var showEmptyHint: Bool {
        recentSearchStore.searches.isEmpty
            && viewModel.clipboardBitcoinAddress == nil
            && !isFiltering
    }

    private var emptyStateHint: some View {
        HStack(spacing: ApricotSpacing.s3) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color.apricotAccent.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text("Paste a Bitcoin address")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.apricotFgPrimary)
                Text("Copy one to your clipboard and it'll appear here")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.apricotFgSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, ApricotSpacing.s4)
        .padding(.vertical, ApricotSpacing.s3)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.apricotAccent.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.apricotAccent.opacity(0.15), lineWidth: 0.5)
                )
        )
        .padding(.top, ApricotSpacing.s3)
    }

    private var recentSection: some View {
        RecentSearchesSection(searches: recentSearchStore.searches) { item in
            searchedAddress = viewModel.selectRecentSearch(item)
        }
    }

    private var filterSection: some View {
        WalletFilterSection(profiles: filteredProfiles) { profile in
            searchedAddress = profile.address
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
