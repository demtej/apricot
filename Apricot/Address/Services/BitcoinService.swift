import Foundation
import shared

// MARK: - Protocol

protocol BitcoinServiceProtocol {
    func fetchAddressData(address: String) async throws -> AddressData
    func fetchTransactionDetail(txId: String, forAddress: String) async throws -> TransactionDetailItem
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

    func fetchTransactionDetail(txId: String, forAddress: String) async throws -> TransactionDetailItem {
        do {
            let tx = try await facade.getTransactionDetail(txId: txId)
            return mapTransactionDetail(tx, txId: txId, forAddress: forAddress)
        } catch {
            throw classifyTransactionError(error)
        }
    }

    // MARK: - Transaction detail mapper

    private func mapTransactionDetail(
        _ tx: BitcoinTransaction,
        txId: String,
        forAddress: String
    ) -> TransactionDetailItem {
        let netSats = facade.transactionNetAmountSats(tx: tx, forAddressString: forAddress)
        let directionStr = facade.transactionDirection(tx: tx, forAddressString: forAddress)
        let isConfirmed = facade.isTransactionConfirmed(tx: tx)
        let feeSats = facade.transactionFeeSats(tx: tx)

        let blockHeight: Int? = isConfirmed ? Int(facade.transactionBlockHeight(tx: tx)) : nil
        let confirmations: Int? = isConfirmed ? Int(facade.transactionConfirmations(tx: tx)) : nil
        let blockTime: Int64? = isConfirmed ? facade.transactionBlockTimeEpochSeconds(tx: tx) : nil

        let status: TransactionStatusDisplay = isConfirmed ? .confirmed : .pending
        let direction = parseDirection(directionStr)
        let timestamp = blockTime.map { formatTimestamp(epochSeconds: $0) }
        let netAmountDisplay = formatBTC(abs(netSats))

        let inputs: [IOItem] = (0..<Int(facade.inputCount(tx: tx))).map { i in
            let address = facade.inputAddressAt(tx: tx, index: Int32(i))
            let sats = facade.inputAmountSatsAt(tx: tx, index: Int32(i))
            return IOItem(
                index: i,
                address: address,
                amountBTC: formatBTC(sats),
                amountSats: formatSats(sats),
                isRelevantAddress: address == forAddress
            )
        }

        let outputs: [IOItem] = (0..<Int(facade.outputCount(tx: tx))).map { i in
            let address = facade.outputAddressAt(tx: tx, index: Int32(i))
            let sats = facade.outputAmountSatsAt(tx: tx, index: Int32(i))
            return IOItem(
                index: i,
                address: address,
                amountBTC: formatBTC(sats),
                amountSats: formatSats(sats),
                isRelevantAddress: address == forAddress
            )
        }

        return TransactionDetailItem(
            id: txId,
            shortId: String(txId.prefix(8)) + "…",
            summary: buildSummary(
                direction: direction,
                status: status,
                netAmountBTC: netAmountDisplay,
                isPositive: netSats >= 0
            ),
            direction: direction,
            status: status,
            confirmations: confirmations,
            blockHeight: blockHeight,
            timestamp: timestamp,
            feeBTC: formatBTC(feeSats),
            feeSats: formatSats(feeSats),
            netAmountDisplay: netAmountDisplay,
            netAmountIsPositive: netSats >= 0,
            inputCount: inputs.count,
            outputCount: outputs.count,
            inputs: inputs,
            outputs: outputs
        )
    }

    private func buildSummary(
        direction: TransactionDirectionDisplay,
        status: TransactionStatusDisplay,
        netAmountBTC: String,
        isPositive: Bool
    ) -> String {
        let statusWord = status == .pending ? "pending" : "confirmed"
        switch direction {
        case .incoming:
            return "You received \(netAmountBTC) in this \(statusWord) transaction."
        case .outgoing:
            return "You sent \(netAmountBTC) in this \(statusWord) transaction."
        case .mixed:
            return "This \(statusWord) transaction both spent and received funds for this address."
        case .unknown:
            return "Transaction details for this address."
        }
    }

    private func formatTimestamp(epochSeconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochSeconds))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func classifyTransactionError(_ error: Error) -> TransactionDetailError {
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
