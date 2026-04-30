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
        Text(transaction.signedAmountDisplay)
            .apricotMono(.small)
            .foregroundStyle(transaction.amountIsPositive ? Color.apricotInFg : Color.apricotOutFg)
    }
}

#Preview {
    VStack(spacing: 8) {
        TransactionRow(transaction: TransactionItem(
            id: "abc123def456789abcdef",
            shortId: "abc123de…cdef",
            direction: .incoming,
            amountDisplay: "0.01 BTC",
            amountIsPositive: true,
            isConfirmed: true,
            statusLabel: "Confirmed"
        ))
        TransactionRow(transaction: TransactionItem(
            id: "def456abc123789defabc",
            shortId: "def456ab…fabc",
            direction: .outgoing,
            amountDisplay: "0.005 BTC",
            amountIsPositive: false,
            isConfirmed: false,
            statusLabel: "Pending"
        ))
        TransactionRow(transaction: TransactionItem(
            id: "999888777666555444333222111000abc",
            shortId: "99988877…0abc",
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
