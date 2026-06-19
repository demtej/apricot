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

    init(
        observability: AppObservability = .noop,
        facade: IosAddressFacade? = nil
    ) {
        if let facade {
            self.facade = facade
        } else {
            let logger = observability.logger
            let analytics = observability.analytics
            self.facade = IosAddressFacade.companion.create(onCacheEvent: { eventName, resourceName, key in
                guard let resource = CacheResource(rawValue: resourceName) else { return }

                let preview = ObservabilityPrivacy.cacheKeyPreview(key, resource: resource)
                let event: ProductEvent
                switch eventName {
                case "cache_hit":
                    event = .cacheHit(resource: resource, keyPreview: preview)
                case "cache_miss":
                    event = .cacheMiss(resource: resource, keyPreview: preview)
                default:
                    logger.log(level: .debug, message: "Unknown cache event", metadata: [
                        "event_name": .string(eventName),
                        "resource": .string(resourceName)
                    ])
                    return
                }

                analytics.track(event)
                logger.log(level: .debug, message: "Cache event observed", metadata: event.properties)
            })
        }
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
            let txItems = transactions.map {
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
            shortAddress: BitcoinFormatter.shortAddress(address),
            confirmedBalanceBTC: BitcoinFormatter.btc(summary.balance),
            confirmedBalanceSats: BitcoinFormatter.sats(summary.balance),
            totalReceivedBTC: BitcoinFormatter.btc(summary.totalReceived),
            totalSentBTC: BitcoinFormatter.btc(summary.totalSent),
            transactionCount: Int(summary.transactionCount)
        )
    }

    private func mapTransaction(_ tx: BitcoinTransaction, address: String) -> TransactionItem {
        let txId = facade.transactionId(tx: tx)
        let netSats = facade.transactionNetAmountSats(tx: tx, forAddressString: address)
        let directionString = facade.transactionDirection(tx: tx, forAddressString: address)
        let direction = parseDirection(directionString)
        let isConfirmed = facade.isTransactionConfirmed(tx: tx)

        return TransactionItem(
            id: txId,
            shortId: BitcoinFormatter.shortTxId(txId),
            direction: direction,
            amountDisplay: BitcoinFormatter.btc(abs(netSats)),
            amountIsPositive: netSats >= 0,
            isConfirmed: isConfirmed,
            statusLabel: isConfirmed ? "Confirmed" : "Pending",
            counterpartyAddress: extractCounterpartyAddress(tx: tx, userAddress: address, direction: direction)
        )
    }

    private func extractCounterpartyAddress(
        tx: BitcoinTransaction,
        userAddress: String,
        direction: TransactionDirectionDisplay
    ) -> String? {
        switch direction {
        case .incoming:
            for i in 0 ..< Int(facade.inputCount(tx: tx)) {
                if let addr = facade.inputAddressAt(tx: tx, index: Int32(i)), addr != userAddress {
                    return addr
                }
            }
            return nil
        case .outgoing:
            for i in 0 ..< Int(facade.outputCount(tx: tx)) {
                if let addr = facade.outputAddressAt(tx: tx, index: Int32(i)), addr != userAddress {
                    return addr
                }
            }
            return nil
        case .mixed, .unknown:
            return nil
        }
    }

    private func parseDirection(_ raw: String) -> TransactionDirectionDisplay {
        switch raw {
        case "incoming": .incoming
        case "outgoing": .outgoing
        case "mixed": .mixed
        default: .unknown
        }
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
        let timestamp = blockTime.map { BitcoinFormatter.timestamp(epochSeconds: $0) }
        let netAmountDisplay = BitcoinFormatter.btc(abs(netSats))

        let inputs: [IOItem] = (0 ..< Int(facade.inputCount(tx: tx))).map { i in
            let address = facade.inputAddressAt(tx: tx, index: Int32(i))
            let sats = facade.inputAmountSatsAt(tx: tx, index: Int32(i))
            return IOItem(
                index: i,
                address: address,
                amountBTC: BitcoinFormatter.btc(sats),
                amountSats: BitcoinFormatter.sats(sats),
                isRelevantAddress: address == forAddress
            )
        }

        let outputs: [IOItem] = (0 ..< Int(facade.outputCount(tx: tx))).map { i in
            let address = facade.outputAddressAt(tx: tx, index: Int32(i))
            let sats = facade.outputAmountSatsAt(tx: tx, index: Int32(i))
            return IOItem(
                index: i,
                address: address,
                amountBTC: BitcoinFormatter.btc(sats),
                amountSats: BitcoinFormatter.sats(sats),
                isRelevantAddress: address == forAddress
            )
        }

        return TransactionDetailItem(
            id: txId,
            shortId: BitcoinFormatter.shortTxId(txId),
            direction: direction,
            status: status,
            confirmations: confirmations,
            blockHeight: blockHeight,
            timestamp: timestamp,
            feeBTC: BitcoinFormatter.btc(feeSats),
            feeSats: BitcoinFormatter.sats(feeSats),
            netAmountDisplay: netAmountDisplay,
            netAmountIsPositive: netSats >= 0,
            inputCount: inputs.count,
            outputCount: outputs.count,
            inputs: inputs,
            outputs: outputs
        )
    }

    private func classifyTransactionError(_ error: Error) -> TransactionDetailError {
        let description = error.localizedDescription
        if description.contains("not found") || description.contains("Not Found") ||
            description.contains("Resource not found")
        {
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
            description.contains("Resource not found")
        {
            return .notFound
        }
        if description.contains("decode") || description.contains("Decode") {
            return .decoding
        }
        return .network
    }
}
