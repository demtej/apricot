import SwiftUI

struct TransactionUTXOView: View {
    let detail: TransactionDetailItem

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: ApricotSpacing.s4, pinnedViews: []) {
                    headerCapsule
                        .padding(.top, ApricotSpacing.s4)

                    ioSection(title: "INPUTS", subtitle: "Unspent outputs consumed", items: detail.inputs)
                    ioSection(title: "OUTPUTS", subtitle: "New unspent outputs created", items: detail.outputs)
                }
                .padding(.horizontal, ApricotSpacing.s5)
                .padding(.bottom, ApricotSpacing.s10)
            }
        }
        .navigationTitle("UTXOs")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCapsule: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            Text(detail.id)
                .apricotMono(.small)
                .foregroundStyle(Color.apricotFgSecondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail.signedNetAmountDisplay)
                .apricotMono(.small)
                .foregroundStyle(detail.netAmountIsPositive ? Color.apricotInFg : Color.apricotOutFg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ApricotSpacing.s4)
        .padding(.vertical, ApricotSpacing.s3)
        .background(Color.apricotBgSurface2)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
    }

    // MARK: - Sections

    private func ioSection(title: String, subtitle: String, items: [IOItem]) -> some View {
        LazyVStack(alignment: .leading, spacing: ApricotSpacing.s2, pinnedViews: []) {
            Section {
                ForEach(items) { item in
                    utxoRow(item: item)
                }
            } header: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.apricotLabel)
                            .tracking(.apricotTrackingWide)
                            .foregroundStyle(Color.apricotFgSecondary)
                        Spacer()
                        Text("\(items.count)")
                            .font(.apricotLabel)
                            .foregroundStyle(Color.apricotFgMuted)
                    }
                    Text(subtitle)
                        .font(.apricotCaption)
                        .foregroundStyle(Color.apricotFgMuted)
                }
                .padding(.top, ApricotSpacing.s2)
                .padding(.bottom, ApricotSpacing.s1)
                .background(Color.apricotBgPage)
            }
        }
    }

    // MARK: - Row

    private func utxoRow(item: IOItem) -> some View {
        HStack(alignment: .top, spacing: ApricotSpacing.s3) {
            VStack(alignment: .leading, spacing: 2) {
                if let address = item.address {
                    Text(address)
                        .apricotMono(.small)
                        .foregroundStyle(item.isRelevantAddress ? Color.apricotFgPrimary : Color.apricotFgSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Coinbase / Unknown")
                        .font(.apricotCaption)
                        .italic()
                        .foregroundStyle(Color.apricotFgMuted)
                }
            }

            Spacer(minLength: ApricotSpacing.s3)

            VStack(alignment: .trailing, spacing: 2) {
                MonoText(text: item.amountBTC, size: .small)
                Text(item.amountSats)
                    .apricotMono(.small)
                    .foregroundStyle(Color.apricotFgMuted)
            }
        }
        .padding(14)
        .background(item.isRelevantAddress ? Color.apricotAccentSoft : Color.apricotBgElevated)
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
}

#Preview {
    NavigationStack {
        TransactionUTXOView(
            detail: TransactionDetailItem(
                id: "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d",
                shortId: "a1075db5…d48d",
                direction: .incoming,
                status: .confirmed,
                confirmations: 6,
                blockHeight: 800_000,
                timestamp: "Apr 29, 2026 at 12:00 PM",
                feeBTC: "0.00001200 BTC",
                feeSats: "1,200 sat",
                netAmountDisplay: "0.02500000 BTC",
                netAmountIsPositive: true,
                inputCount: 2,
                outputCount: 2,
                inputs: [
                    IOItem(index: 0, address: "bc1qsender000000000000000000000000000000000",
                           amountBTC: "0.01500000 BTC", amountSats: "1,500,000 sat", isRelevantAddress: false),
                    IOItem(index: 1, address: "bc1qsender111111111111111111111111111111111",
                           amountBTC: "0.01001200 BTC", amountSats: "1,001,200 sat", isRelevantAddress: false)
                ],
                outputs: [
                    IOItem(index: 0, address: "bc1qreceiver0000000000000000000000000000000",
                           amountBTC: "0.02500000 BTC", amountSats: "2,500,000 sat", isRelevantAddress: true),
                    IOItem(index: 1, address: "bc1qchange222222222222222222222222222222222",
                           amountBTC: "0.00000000 BTC", amountSats: "0 sat", isRelevantAddress: false)
                ]
            )
        )
    }
}
