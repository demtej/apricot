import SwiftUI

private struct TransactionNavContext: Identifiable, Hashable {
    let transaction: TransactionItem
    let address: String
    var id: String { transaction.id }
}

struct AddressView: View {
    private let address: String
    private let service: BitcoinServiceProtocol
    private let observability: AppObservability
    private let loadsOnAppear: Bool

    @StateObject private var viewModel: AddressViewModel
    @State private var pendingNavigation: TransactionNavContext?
    @State private var showsRealAddress = false
    @EnvironmentObject private var profileStore: WalletProfileStore

    init(
        address: String,
        viewModel: AddressViewModel,
        service: BitcoinServiceProtocol,
        observability: AppObservability = .noop,
        loadsOnAppear: Bool = true
    ) {
        self.address = address
        self.service = service
        self.observability = observability
        self.loadsOnAppear = loadsOnAppear
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Address")
        .navigationDestination(item: $pendingNavigation) { ctx in
            TransactionDetailView(
                transaction: ctx.transaction,
                forAddress: ctx.address,
                viewModel: TransactionDetailViewModel(
                    service: service,
                    profileStore: profileStore,
                    observability: observability
                )
            )
        }
        .task {
            guard loadsOnAppear else { return }
            viewModel.load()
        }
    }

    // MARK: - Content switcher

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Spacer()
        case .loading:
            ScrollView {
                ApricotLoadingState()
                    .padding(.top, ApricotSpacing.s4)
            }
        case let .loaded(summary, transactions, showsInsights):
            loadedView(summary: summary, transactions: transactions, showsInsights: showsInsights)
        case let .empty(summary, showsInsights):
            emptyView(summary: summary, showsInsights: showsInsights)
        case let .failed(error):
            ApricotErrorState(
                title: error.title,
                message: error.message,
                retryTitle: "Try Again",
                onRetry: { viewModel.load() }
            )
        }
    }

    // MARK: - Loaded

    private func loadedView(
        summary: AddressSummaryItem,
        transactions: [TransactionItem],
        showsInsights: Bool
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: ApricotSpacing.s3) {
                AddressSummaryCard(
                    summary: summary,
                    alias: profileStore.profile(for: summary.address)?.label,
                    showsRealAddress: $showsRealAddress,
                    showsInsights: showsInsights
                )
                .padding(.top, ApricotSpacing.s4)

                transactionListHeader(count: transactions.count)

                ForEach(transactions) { tx in
                    Button {
                        viewModel.didOpenTransaction(tx, forAddress: summary.address)
                        pendingNavigation = TransactionNavContext(transaction: tx, address: summary.address)
                    } label: {
                        TransactionRow(
                            transaction: tx,
                            showsDirectionClassification: showsInsights,
                            counterpartyAlias: tx.counterpartyAddress.flatMap {
                                profileStore.profile(for: $0)?.label
                            },
                            showsRealAddress: showsRealAddress
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.bottom, ApricotSpacing.s10)
            Spacer()
        }
    }

    private func transactionListHeader(count: Int) -> some View {
        HStack {
            Text("TRANSACTIONS")
                .font(.apricotLabel)
                .tracking(.apricotTrackingWide)
                .foregroundStyle(Color.apricotFgSecondary)
            Spacer()
            Text("\(count)")
                .font(.apricotLabel)
                .foregroundStyle(Color.apricotFgMuted)
        }
        .padding(.top, ApricotSpacing.s2)
    }

    // MARK: - Empty

    private func emptyView(summary: AddressSummaryItem, showsInsights: Bool) -> some View {
        ScrollView {
            VStack(spacing: ApricotSpacing.s4) {
                AddressSummaryCard(
                    summary: summary,
                    alias: profileStore.profile(for: summary.address)?.label,
                    showsRealAddress: $showsRealAddress,
                    showsInsights: showsInsights
                )
                .padding(.top, ApricotSpacing.s4)

                ApricotEmptyState(
                    title: "No Transactions",
                    message: "This address has not been used yet."
                )
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.bottom, ApricotSpacing.s10)
        }
    }
}

// MARK: - Previews

#Preview("Loaded with alias") {
    let service = LiveBitcoinService()
    let profileStore = WalletProfileStore.preview()
    return NavigationStack {
        AddressView(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            viewModel: AddressViewModel(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                service: service,
                initialState: .loaded(
                    summary: AddressSummaryItem(
                        address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                        shortAddress: "bc1qar0s…59gtzz",
                        confirmedBalanceBTC: "0.05 BTC",
                        confirmedBalanceSats: "5,000,000 sats",
                        totalReceivedBTC: "0.10 BTC",
                        totalSentBTC: "0.05 BTC",
                        transactionCount: 3
                    ),
                    transactions: [],
                    showsInsights: true
                )
            ),
            service: service,
            loadsOnAppear: false
        )
    }
    .environmentObject(profileStore)
}

#Preview("Loading") {
    let service = LiveBitcoinService()
    return NavigationStack {
        AddressView(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            viewModel: AddressViewModel(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                service: service,
                initialState: .loading
            ),
            service: service,
            loadsOnAppear: false
        )
    }
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Error") {
    let service = LiveBitcoinService()
    return NavigationStack {
        AddressView(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            viewModel: AddressViewModel(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                service: service,
                initialState: .failed(.network)
            ),
            service: service,
            loadsOnAppear: false
        )
    }
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Empty address") {
    let service = LiveBitcoinService()
    return NavigationStack {
        AddressView(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            viewModel: AddressViewModel(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                service: service,
                initialState: .empty(
                    summary: AddressSummaryItem(
                        address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
                        shortAddress: "bc1qar0s…59gtzz",
                        confirmedBalanceBTC: "0.00 BTC",
                        confirmedBalanceSats: "0 sats",
                        totalReceivedBTC: "0.00 BTC",
                        totalSentBTC: "0.00 BTC",
                        transactionCount: 0
                    ),
                    showsInsights: true
                )
            ),
            service: service,
            loadsOnAppear: false
        )
    }
    .environmentObject(WalletProfileStore.preview())
}
