import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionItem

    var body: some View {
        HStack(spacing: ApricotSpacing.s3) {
            directionBadge
            idColumn
            Spacer()
            amountColumn
        }
        .padding(14)
        .background(Color.apricotBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.md)
                .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Sub-views

    private var directionBadge: some View {
        ApricotBadge(
            label: transaction.direction.label,
            variant: transaction.direction.badgeVariant
        )
    }

    private var idColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(transaction.shortId)
                .apricotMono(.small)
                .foregroundStyle(Color.apricotFgPrimary)
            if !transaction.isConfirmed {
                ApricotBadge(label: transaction.statusLabel, variant: .pending, showDot: true)
            }
        }
    }

    private var amountColumn: some View {
        let prefix = transaction.amountIsPositive ? "+" : "−"
        let color: Color = transaction.amountIsPositive ? .apricotInFg : .apricotOutFg
        return Text(prefix + transaction.amountDisplay)
            .apricotMono(.small)
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: 8) {
        TransactionRow(transaction: TransactionItem(
            id: "abc123def456789abcdef",
            shortId: "abc123de…",
            direction: .incoming,
            amountDisplay: "0.01000000 BTC",
            amountIsPositive: true,
            isConfirmed: true,
            statusLabel: "Confirmed"
        ))
        TransactionRow(transaction: TransactionItem(
            id: "def456abc123789defabc",
            shortId: "def456ab…",
            direction: .outgoing,
            amountDisplay: "0.00500000 BTC",
            amountIsPositive: false,
            isConfirmed: false,
            statusLabel: "Pending"
        ))
        TransactionRow(transaction: TransactionItem(
            id: "999888777666555444333",
            shortId: "99988877…",
            direction: .mixed,
            amountDisplay: "0.00001234 BTC",
            amountIsPositive: true,
            isConfirmed: true,
            statusLabel: "Confirmed"
        ))
    }
    .padding()
    .background(Color.apricotBgPage)
}
