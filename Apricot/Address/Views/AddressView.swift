import SwiftUI

private struct TransactionNavContext: Identifiable, Hashable {
    let transaction: TransactionItem
    let address: String
    var id: String { transaction.id }
}

struct AddressView: View {
    let initialAddress: String
    private let service: BitcoinServiceProtocol
    private let observability: AppObservability
    private let loadsOnAppear: Bool

    @StateObject private var viewModel: AddressSearchViewModel
    @State private var pendingNavigation: TransactionNavContext?

    init(
        address: String,
        viewModel: AddressSearchViewModel,
        service: BitcoinServiceProtocol,
        observability: AppObservability = .noop,
        loadsOnAppear: Bool = true
    ) {
        initialAddress = address
        self.service = service
        self.observability = observability
        self.loadsOnAppear = loadsOnAppear
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()

            VStack(spacing: 0) {
                searchHeader
                Divider().overlay(Color.apricotBorderSubtle)
                content
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Address")
        .navigationDestination(item: $pendingNavigation) { ctx in
            TransactionDetailView(
                transaction: ctx.transaction,
                forAddress: ctx.address,
                service: service,
                observability: observability
            )
        }
        .task {
            guard loadsOnAppear else { return }
            viewModel.addressInput = initialAddress
            viewModel.search()
        }
    }

    // MARK: - Search header

    private var searchHeader: some View {
        ApricotSearchField(
            text: $viewModel.addressInput,
            onSubmit: { viewModel.search() }
        )
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.vertical, ApricotSpacing.s3)
        .background(Color.apricotBgPage)
    }

    // MARK: - Content switcher

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Spacer()
        case .loading:
            ApricotLoadingState()
        case let .loaded(summary, transactions, showsInsights):
            loadedView(summary: summary, transactions: transactions, showsInsights: showsInsights)
        case let .empty(summary, showsInsights):
            emptyView(summary: summary, showsInsights: showsInsights)
        case let .failed(error):
            ApricotErrorState(
                title: error.title,
                message: error.message,
                retryTitle: "Try Again",
                onRetry: { viewModel.search() }
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
                AddressSummaryCard(summary: summary, showsInsights: showsInsights)
                    .padding(.top, ApricotSpacing.s4)

                transactionListHeader(count: transactions.count)

                ForEach(transactions) { tx in
                    Button {
                        viewModel.didOpenTransaction(tx, forAddress: summary.address)
                        pendingNavigation = TransactionNavContext(transaction: tx, address: summary.address)
                    } label: {
                        TransactionRow(transaction: tx, showsDirectionClassification: showsInsights)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.bottom, ApricotSpacing.s10)
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
                AddressSummaryCard(summary: summary, showsInsights: showsInsights)
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

#Preview {
    let service = LiveBitcoinService()
    return NavigationStack {
        AddressView(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            viewModel: AddressSearchViewModel(service: service),
            service: service
        )
    }
}
