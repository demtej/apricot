import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionItem
    let showsDirectionClassification: Bool
    var counterpartyAlias: String? = nil
    var showsRealAddress: Bool = false

    var body: some View {
        HStack(spacing: ApricotSpacing.s3) {
            if showsDirectionClassification {
                directionBadge
            }
            mainColumn
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

    private var mainColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Primary: counterparty alias/address when available, tx ID otherwise
            Text(primaryText)
                .apricotMono(.small)
                .foregroundStyle(Color.apricotFgPrimary)
                .lineLimit(1)

            if !transaction.isConfirmed {
                ApricotBadge(label: transaction.statusLabel, variant: .pending, showDot: true)
            }

            // Secondary: tx ID when counterparty is shown as primary
            if transaction.counterpartyAddress != nil {
                Text(transaction.shortId)
                    .apricotMono(.small)
                    .foregroundStyle(Color.apricotFgMuted)
                    .lineLimit(1)
            }
        }
    }

    private var amountColumn: some View {
        Text(transaction.signedAmountDisplay)
            .apricotMono(.small)
            .foregroundStyle(transaction.amountIsPositive ? Color.apricotInFg : Color.apricotOutFg)
    }

    // MARK: - Helpers

    private var primaryText: String {
        guard transaction.counterpartyAddress != nil else {
            return transaction.shortId
        }
        if !showsRealAddress, let alias = counterpartyAlias {
            return alias
        }
        return transaction.counterpartyShortAddress ?? transaction.shortId
    }
}

#Preview {
    VStack(spacing: 8) {
        // Has alias, showing alias mode
        TransactionRow(
            transaction: TransactionItem(
                id: "e45bbee6aa41000000000000",
                shortId: "e45bbee6…aa41",
                direction: .incoming,
                amountDisplay: "0.01 BTC",
                amountIsPositive: true,
                isConfirmed: true,
                statusLabel: "Confirmed",
                counterpartyAddress: "1SochiWw123RPxyz"
            ),
            showsDirectionClassification: true,
            counterpartyAlias: "C5",
            showsRealAddress: false
        )
        // Has alias, showing real address mode
        TransactionRow(
            transaction: TransactionItem(
                id: "e45bbee6aa41000000000000",
                shortId: "e45bbee6…aa41",
                direction: .incoming,
                amountDisplay: "0.01 BTC",
                amountIsPositive: true,
                isConfirmed: true,
                statusLabel: "Confirmed",
                counterpartyAddress: "1SochiWw123RPxyz"
            ),
            showsDirectionClassification: true,
            counterpartyAlias: "C5",
            showsRealAddress: true
        )
        // No alias (no profile yet)
        TransactionRow(
            transaction: TransactionItem(
                id: "0a59443b4773000000000000",
                shortId: "0a59443b…4773",
                direction: .incoming,
                amountDisplay: "5.00 BTC",
                amountIsPositive: true,
                isConfirmed: true,
                statusLabel: "Confirmed",
                counterpartyAddress: "1Bbj32pwfxNtmu"
            ),
            showsDirectionClassification: true,
            counterpartyAlias: nil,
            showsRealAddress: false
        )
        // Mixed — no counterparty, shows tx ID only
        TransactionRow(
            transaction: TransactionItem(
                id: "999888777666555abc",
                shortId: "99988877…0abc",
                direction: .mixed,
                amountDisplay: "0.00001234 BTC",
                amountIsPositive: true,
                isConfirmed: false,
                statusLabel: "Pending",
                counterpartyAddress: nil
            ),
            showsDirectionClassification: false
        )
    }
    .padding()
    .background(Color.apricotBgPage)
}
