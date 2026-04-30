import SwiftUI

struct ApricotStatCard: View {
    let label: String
    let value: String
    var unit: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s1) {
            Text(label.uppercased())
                .font(.apricotLabel)
                .tracking(.apricotTrackingWide)
                .foregroundStyle(Color.apricotFgSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.apricotMonoNum)
                    .monospacedDigit()
                    .tracking(.apricotTrackingMono)
                    .foregroundStyle(Color.apricotFgPrimary)

                if let unit {
                    Text(unit)
                        .font(.apricotMonoSm)
                        .monospacedDigit()
                        .foregroundStyle(Color.apricotFgSecondary)
                }
            }
        }
        .padding(.vertical, ApricotSpacing.s4)
        .padding(.horizontal, ApricotSpacing.s5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apricotBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.lg)
                .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible())],
        spacing: 8
    ) {
        ApricotStatCard(label: "Balance", value: "0.0142", unit: "BTC")
        ApricotStatCard(label: "Transactions", value: "47")
        ApricotStatCard(label: "Total received", value: "1.4382", unit: "BTC")
        ApricotStatCard(label: "Total sent", value: "1.4240", unit: "BTC")
    }
    .padding()
    .background(Color.apricotBgPage)
}
