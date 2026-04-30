import SwiftUI

struct AddressView: View {
    let initialAddress: String
    private let service: BitcoinServiceProtocol

    @StateObject private var viewModel: AddressSearchViewModel
    @State private var selectedTransaction: TransactionItem?
    @State private var loadedAddress: String = ""

    init(address: String, viewModel: AddressSearchViewModel, service: BitcoinServiceProtocol) {
        initialAddress = address
        self.service = service
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
        .navigationDestination(item: $selectedTransaction) { tx in
            TransactionDetailView(transaction: tx, forAddress: loadedAddress, service: service)
        }
        .task {
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
        case .loaded(let summary, let transactions, let showsInsights):
            loadedView(summary: summary, transactions: transactions, showsInsights: showsInsights)
        case .empty(let summary, _):
            emptyView(summary: summary)
        case .failed(let error):
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
                AddressSummaryCard(summary: summary)
                    .padding(.top, ApricotSpacing.s4)

                transactionListHeader(count: transactions.count)

                ForEach(transactions) { tx in
                    Button {
                        loadedAddress = summary.address
                        selectedTransaction = tx
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

    private func emptyView(summary: AddressSummaryItem) -> some View {
        ScrollView {
            VStack(spacing: ApricotSpacing.s4) {
                AddressSummaryCard(summary: summary)
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
