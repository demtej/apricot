import SwiftUI

struct AddressSummaryCard: View {
    let summary: AddressSummaryItem
    var alias: String?
    @Binding var showsRealAddress: Bool
    var showsInsights: Bool = true

    var body: some View {
        ApricotCard(style: .elevated) {
            VStack(alignment: .leading, spacing: ApricotSpacing.s5) {
                addressSection
                Divider().overlay(Color.apricotBorderSubtle)
                balanceSection
                if showsInsights {
                    Divider().overlay(Color.apricotBorderSubtle)
                    statsRow
                }
            }
        }
    }

    // MARK: - Sections

    private var addressSection: some View {
        let displaysAlias = alias != nil && !showsRealAddress

        return VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            sectionLabel(displaysAlias ? "ALIAS" : "ADDRESS")
            HStack(spacing: ApricotSpacing.s2) {
                Group {
                    if displaysAlias, let alias {
                        Text(alias)
                            .apricotMono(.small)
                            .foregroundStyle(Color.apricotFgPrimary)
                            .lineLimit(1)
                    } else {
                        MonoChip(text: summary.address)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .truncationMode(.middle)
                    }
                }
                .id(displaysAlias)
                .transition(.opacity.combined(with: .modifier(
                    active: BlurModifier(radius: 8),
                    identity: BlurModifier(radius: 0)
                )))
                Spacer(minLength: 0)
                if alias != nil {
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
                CopyButton(value: summary.address)
            }
        }
    }

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            sectionLabel("BALANCE")
            Text(summary.confirmedBalanceBTC)
                .font(.apricotMonoNum)
                .tracking(.apricotTrackingMono)
                .foregroundStyle(Color.apricotFgPrimary)
            Text(summary.confirmedBalanceSats)
                .font(.apricotMonoSm)
                .foregroundStyle(Color.apricotFgSecondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(label: "RECEIVED", value: summary.totalReceivedBTC)
            separator
            statCell(label: "SENT", value: summary.totalSentBTC)
            separator
            statCell(label: "TXS", value: "\(summary.transactionCount)")
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.apricotBorderSubtle)
            .frame(width: 1, height: 36)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.apricotLabel)
            .tracking(.apricotTrackingWide)
            .foregroundStyle(Color.apricotFgSecondary)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            sectionLabel(label)
            Text(value)
                .apricotMono(.small)
                .foregroundStyle(Color.apricotFgPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ApricotSpacing.s3)
    }
}

#Preview {
    AddressSummaryCard(
        summary: AddressSummaryItem(
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
            shortAddress: "bc1qar0s…59gtzz",
            confirmedBalanceBTC: "0.05 BTC",
            confirmedBalanceSats: "5,000,000 sats",
            totalReceivedBTC: "0.10 BTC",
            totalSentBTC: "0.05 BTC",
            transactionCount: 12
        ),
        alias: "S1",
        showsRealAddress: .constant(false)
    )
    .padding()
    .background(Color.apricotBgPage)
}
