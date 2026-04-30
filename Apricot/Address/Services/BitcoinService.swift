import Foundation
import shared

// MARK: - Protocol

protocol BitcoinServiceProtocol {
    func fetchAddressData(address: String) async throws -> AddressData
}

struct AddressData {
    let summary: AddressSummaryItem
    let transactions: [TransactionItem]
}

// MARK: - Live implementation

final class LiveBitcoinService: BitcoinServiceProtocol {

    private let facade: IosAddressFacade

    init(facade: IosAddressFacade = IosAddressFacade.companion.create()) {
        self.facade = facade
    }

    func fetchAddressData(address: String) async throws -> AddressData {
        // Fetch summary and transactions concurrently.
        // KMP @Throws suspend functions are auto-bridged by Swift to async throws.
        async let summaryTask = facade.getAddressSummary(addressString: address)
        async let transactionsTask = facade.getAddressTransactions(addressString: address)

        do {
            let (summary, transactions) = try await (summaryTask, transactionsTask)
            let summaryItem = mapSummary(summary, address: address)
            // Kotlin List<BitcoinTransaction> is bridged as NSArray<SharedBitcoinTransaction *>,
            // which arrives in Swift as [BitcoinTransaction].
            let txItems = (transactions as? [BitcoinTransaction] ?? []).map {
                mapTransaction($0, address: address)
            }
            return AddressData(summary: summaryItem, transactions: txItems)
        } catch {
            throw classifyError(error)
        }
    }

    // MARK: - Mappers

    private func mapSummary(_ summary: AddressSummary, address: String) -> AddressSummaryItem {
        // Satoshi is a Kotlin value class with Long underneath; it is unboxed to Int64 in ObjC.
        // Accessing summary.balance gives Int64 directly — no .amount needed.
        AddressSummaryItem(
            address: address,
            confirmedBalanceBTC: formatBTC(summary.balance),
            confirmedBalanceSats: formatSats(summary.balance),
            totalReceivedBTC: formatBTC(summary.totalReceived),
            totalSentBTC: formatBTC(summary.totalSent),
            transactionCount: Int(summary.transactionCount)
        )
    }

    private func mapTransaction(_ tx: BitcoinTransaction, address: String) -> TransactionItem {
        let txId = facade.transactionId(tx: tx)
        let netSats = facade.transactionNetAmountSats(tx: tx, forAddressString: address)
        let directionString = facade.transactionDirection(tx: tx, forAddressString: address)
        let isConfirmed = facade.isTransactionConfirmed(tx: tx)

        return TransactionItem(
            id: txId,
            shortId: String(txId.prefix(8)) + "…",
            direction: parseDirection(directionString),
            amountDisplay: formatBTC(abs(netSats)),
            amountIsPositive: netSats >= 0,
            isConfirmed: isConfirmed,
            statusLabel: isConfirmed ? "Confirmed" : "Pending"
        )
    }

    private func parseDirection(_ raw: String) -> TransactionDirectionDisplay {
        switch raw {
        case "incoming": return .incoming
        case "outgoing": return .outgoing
        case "mixed":    return .mixed
        default:         return .unknown
        }
    }

    // MARK: - Formatting

    private func formatBTC(_ sats: Int64) -> String {
        let btc = Double(sats) / 100_000_000.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8
        formatter.usesGroupingSeparator = false
        let number = formatter.string(from: NSNumber(value: btc)) ?? String(format: "%.8f", btc)
        return number + " BTC"
    }

    private func formatSats(_ sats: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        let number = formatter.string(from: NSNumber(value: sats)) ?? "\(sats)"
        return number + " sat"
    }

    // MARK: - Error classification

    private func classifyError(_ error: Error) -> AddressSearchError {
        // BitcoinRepositoryError.NotFound sets message "Resource not found"
        let description = error.localizedDescription
        if description.contains("not found") || description.contains("Not Found") ||
           description.contains("Resource not found") {
            return .notFound
        }
        if description.contains("decode") || description.contains("Decode") {
            return .decoding
        }
        return .network
    }
}
