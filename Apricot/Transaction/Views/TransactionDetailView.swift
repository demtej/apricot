import SwiftUI

struct TransactionDetailView: View {
    let transaction: TransactionItem
    let forAddress: String

    @StateObject private var viewModel = TransactionDetailViewModel()

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Transaction")
        .task {
            viewModel.load(txId: transaction.id, forAddress: forAddress)
        }
    }

    // MARK: - Content switcher

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            ApricotLoadingState()
        case .loaded(let detail):
            loadedView(detail: detail)
        case .failed(let error):
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
                summaryCard(detail: detail)
                identityCard(detail: detail)
                if detail.status == .confirmed {
                    confirmationCard(detail: detail)
                }
                amountCard(detail: detail)
                TransactionFlowCard(
                    inputs: detail.inputs,
                    outputs: detail.outputs,
                    feeSats: detail.feeSats
                )
                ioSection(title: "INPUTS", count: detail.inputCount, items: detail.inputs)
                ioSection(title: "OUTPUTS", count: detail.outputCount, items: detail.outputs)
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.vertical, ApricotSpacing.s4)
            .padding(.bottom, ApricotSpacing.s10)
        }
    }

    // MARK: - Summary

    private func summaryCard(detail: TransactionDetailItem) -> some View {
        ApricotCard(style: .elevated) {
            HStack(alignment: .top, spacing: ApricotSpacing.s3) {
                ApricotBadge(
                    label: detail.direction.label,
                    variant: detail.direction.badgeVariant,
                    showDot: false
                )
                Text(detail.summary)
                    .font(.apricotBody)
                    .foregroundStyle(Color.apricotFgPrimary)
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Identity

    private func identityCard(detail: TransactionDetailItem) -> some View {
        ApricotCard {
            VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                sectionLabel("TRANSACTION ID")

                MonoText(text: detail.shortId)

                Divider().overlay(Color.apricotBorderSubtle)

                HStack(alignment: .top, spacing: ApricotSpacing.s3) {
                    Text(detail.id)
                        .apricotMono(.small)
                        .foregroundStyle(Color.apricotFgSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: ApricotSpacing.s3)
                    Button {
                        UIPasteboard.general.string = detail.id
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.apricotAccent)
                    }
                }

                Divider().overlay(Color.apricotBorderSubtle)

                ApricotBadge(
                    label: detail.status.label,
                    variant: detail.status.badgeVariant,
                    showDot: detail.status == .pending
                )
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

    // MARK: - Inputs / Outputs

    private func ioSection(title: String, count: Int, items: [IOItem]) -> some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            HStack {
                Text(title)
                    .font(.apricotLabel)
                    .tracking(.apricotTrackingWide)
                    .foregroundStyle(Color.apricotFgSecondary)
                Spacer()
                Text("\(count)")
                    .font(.apricotLabel)
                    .foregroundStyle(Color.apricotFgMuted)
            }
            .padding(.top, ApricotSpacing.s2)

            ForEach(items) { item in
                ioRow(item: item)
            }
        }
    }

    private func ioRow(item: IOItem) -> some View {
        HStack(alignment: .center, spacing: ApricotSpacing.s3) {
            if item.isRelevantAddress {
                Circle()
                    .fill(Color.apricotAccent)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let address = item.address {
                    Text(address)
                        .apricotMono(.small)
                        .foregroundStyle(
                            item.isRelevantAddress ? Color.apricotFgPrimary : Color.apricotFgSecondary
                        )
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    Text("Coinbase / Unknown")
                        .font(.apricotCaption)
                        .italic()
                        .foregroundStyle(Color.apricotFgMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                MonoText(text: item.amountBTC, size: .small)
                Text(item.amountSats)
                    .apricotMono(.small)
                    .foregroundStyle(Color.apricotFgMuted)
            }
        }
        .padding(14)
        .background(Color.apricotBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.md)
                .strokeBorder(
                    item.isRelevantAddress
                        ? Color.apricotAccent.opacity(0.4)
                        : Color.apricotBorderSubtle,
                    lineWidth: 1
                )
        )
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
                statusLabel: "Confirmed"
            ),
            forAddress: "1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf"
        )
    }
}
