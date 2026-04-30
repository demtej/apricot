import SwiftUI

struct AddressSummaryCard: View {
    let summary: AddressSummaryItem

    var body: some View {
        ApricotCard(style: .elevated) {
            VStack(alignment: .leading, spacing: ApricotSpacing.s5) {
                addressSection
                Divider().overlay(Color.apricotBorderSubtle)
                balanceSection
                Divider().overlay(Color.apricotBorderSubtle)
                statsRow
            }
        }
    }

    // MARK: - Sections

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            sectionLabel("ADDRESS")
            MonoChip(text: summary.address)
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
    AddressSummaryCard(summary: AddressSummaryItem(
        address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz",
        confirmedBalanceBTC: "0.05000000 BTC",
        confirmedBalanceSats: "5,000,000 sat",
        totalReceivedBTC: "0.10000000 BTC",
        totalSentBTC: "0.05000000 BTC",
        transactionCount: 12
    ))
    .padding()
    .background(Color.apricotBgPage)
}
