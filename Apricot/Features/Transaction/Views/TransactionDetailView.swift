import SwiftUI

struct TransactionDetailView: View {
    let transaction: TransactionItem
    let forAddress: String
    private let loadsOnAppear: Bool

    @StateObject private var viewModel: TransactionDetailViewModel
    @State private var showsRealAddress = false
    @State private var showsUTXOInspector = false
    @EnvironmentObject private var profileStore: WalletProfileStore

    init(
        transaction: TransactionItem,
        forAddress: String,
        service: BitcoinServiceProtocol = LiveBitcoinService(),
        observability: AppObservability = .noop,
        loadsOnAppear: Bool = true
    ) {
        self.transaction = transaction
        self.forAddress = forAddress
        self.loadsOnAppear = loadsOnAppear
        _viewModel = StateObject(wrappedValue: TransactionDetailViewModel(
            service: service,
            observability: observability
        ))
    }

    init(
        transaction: TransactionItem,
        forAddress: String,
        viewModel: TransactionDetailViewModel,
        loadsOnAppear: Bool = true
    ) {
        self.transaction = transaction
        self.forAddress = forAddress
        self.loadsOnAppear = loadsOnAppear
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Transaction")
        .navigationDestination(isPresented: $showsUTXOInspector) {
            if case let .loaded(detail) = viewModel.state {
                TransactionUTXOView(detail: detail)
            }
        }
        .task {
            guard loadsOnAppear else { return }
            viewModel.load(txId: transaction.id, forAddress: forAddress)
        }
    }

    // MARK: - Content switcher

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ScrollView {
                ApricotLoadingState()
                    .padding(.top, ApricotSpacing.s4)
            }
        case let .loaded(detail):
            loadedView(detail: detail)
        case let .failed(error):
            ApricotErrorState(
                title: error.title,
                message: error.message,
                retryTitle: "Try Again",
                onRetry: {
                    viewModel.retry(txId: transaction.id, forAddress: forAddress)
                }
            )
        }
    }

    // MARK: - Loaded

    private func loadedView(detail: TransactionDetailItem) -> some View {
        ScrollView {
            LazyVStack(spacing: ApricotSpacing.s4) {
                identityCard(detail: detail)
                if detail.status == .confirmed {
                    confirmationCard(detail: detail)
                }
                amountCard(detail: detail)
                TransactionFlowCard(
                    inputs: detail.inputs,
                    outputs: detail.outputs,
                    feeSats: detail.feeSats,
                    showsRealAddress: showsRealAddress,
                    resolveAlias: { profileStore.profile(for: $0)?.label },
                    onInspect: { showsUTXOInspector = true }
                )
                .onAppear {
                    viewModel.trackTransactionGraphViewed(txId: detail.id)
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.vertical, ApricotSpacing.s4)
            .padding(.bottom, ApricotSpacing.s10)
        }
    }

    // MARK: - Identity

    private func identityCard(detail: TransactionDetailItem) -> some View {
        let counterparty = transaction.counterpartyAddress
        let counterpartyAlias = counterparty.flatMap { profileStore.profile(for: $0)?.label }
        let displaysAlias = counterpartyAlias != nil && !showsRealAddress

        return ApricotCard {
            VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                // Transaction ID row
                sectionLabel("TRANSACTION ID")
                HStack(alignment: .top, spacing: ApricotSpacing.s3) {
                    Text(detail.id)
                        .apricotMono(.small)
                        .foregroundStyle(Color.apricotFgPrimary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: ApricotSpacing.s3)
                    CopyButton(value: detail.id)
                }

                if detail.direction == .mixed, counterparty == nil {
                    Divider().overlay(Color.apricotBorderSubtle)
                    sectionLabel("TRANSFER TYPE")
                    Text("Internal transfer — funds stayed within this wallet")
                        .font(.apricotBody)
                        .foregroundStyle(Color.apricotFgSecondary)
                } else if let counterparty {
                    Divider().overlay(Color.apricotBorderSubtle)

                    // Counterparty wallet row
                    sectionLabel(displaysAlias ? "ALIAS" : "WALLET")
                    HStack(alignment: .center, spacing: ApricotSpacing.s3) {
                        ZStack(alignment: .leading) {
                            // Always reserves the height of the full address (2 lines)
                            Text(counterparty)
                                .apricotMono(.small)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0)

                            Group {
                                if displaysAlias, let alias = counterpartyAlias {
                                    Text(alias)
                                        .apricotMono(.small)
                                        .foregroundStyle(Color.apricotFgPrimary)
                                } else {
                                    Text(counterparty)
                                        .apricotMono(.small)
                                        .foregroundStyle(Color.apricotFgPrimary)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .id(displaysAlias)
                            .transition(.opacity.combined(with: .modifier(
                                active: BlurModifier(radius: 8),
                                identity: BlurModifier(radius: 0)
                            )))
                        }
                        Spacer(minLength: ApricotSpacing.s3)
                        if counterpartyAlias != nil {
                            Button {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    showsRealAddress.toggle()
                                }
                            } label: {
                                Image(systemName: showsRealAddress ? "eye.slash" : "eye")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.apricotAccent)
                            }
                        }
                        CopyButton(value: counterparty)
                    }
                }
            }
        }
    }

    // MARK: - Confirmation details

    private func confirmationCard(detail: TransactionDetailItem) -> some View {
        ApricotCard {
            VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                sectionLabel("CONFIRMATION DETAILS")

                if let conf = detail.confirmations {
                    statRow(label: "Confirmations", value: "\(conf)", mono: true)
                }
                if let height = detail.blockHeight {
                    if detail.confirmations != nil {
                        Divider().overlay(Color.apricotBorderSubtle)
                    }
                    statRow(label: "Block Height", value: "\(height)", mono: true)
                }
                if let ts = detail.timestamp {
                    if detail.confirmations != nil || detail.blockHeight != nil {
                        Divider().overlay(Color.apricotBorderSubtle)
                    }
                    statRow(label: "Time", value: ts, mono: false)
                }
            }
        }
    }

    // MARK: - Amounts

    private func amountCard(detail: TransactionDetailItem) -> some View {
        ApricotCard {
            VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                sectionLabel("AMOUNTS")

                HStack {
                    Text("Net Amount")
                        .font(.apricotBody)
                        .foregroundStyle(Color.apricotFgSecondary)
                    Spacer()
                    Text(detail.signedNetAmountDisplay)
                        .apricotMono(.small)
                        .foregroundStyle(detail.netAmountIsPositive ? Color.apricotInFg : Color.apricotOutFg)
                }

                Divider().overlay(Color.apricotBorderSubtle)

                HStack(alignment: .center) {
                    Text("Fee")
                        .font(.apricotBody)
                        .foregroundStyle(Color.apricotFgSecondary)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        MonoText(text: detail.feeBTC, size: .small)
                        Text(detail.feeSats)
                            .apricotMono(.small)
                            .foregroundStyle(Color.apricotFgMuted)
                    }
                }
            }
        }
    }

    // MARK: - Shared helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.apricotLabel)
            .tracking(.apricotTrackingWide)
            .foregroundStyle(Color.apricotFgSecondary)
    }

    private func statRow(label: String, value: String, mono: Bool) -> some View {
        HStack {
            Text(label)
                .font(.apricotBody)
                .foregroundStyle(Color.apricotFgSecondary)
            Spacer()
            if mono {
                MonoText(text: value, size: .small)
            } else {
                Text(value)
                    .font(.apricotBody)
                    .foregroundStyle(Color.apricotFgPrimary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: TransactionItem(
                id: "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d",
                shortId: "a1075db5…d48d",
                direction: .incoming,
                amountDisplay: "0.01 BTC",
                amountIsPositive: true,
                isConfirmed: true,
                statusLabel: "Confirmed",
                counterpartyAddress: nil
            ),
            forAddress: "1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf"
        )
    }
}
