@testable import Apricot
import Foundation
import XCTest

enum SnapshotFixtures {
    static let address = "bc1q7z4n7m3x4r6j8f0qqp2u9r6m5a4c3n2p1z8wxy"
    static let transactionId = "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"

    static let summary = AddressSummaryItem(
        address: address,
        shortAddress: "bc1q7z4n…z8wxy",
        confirmedBalanceBTC: "0.14250000 BTC",
        confirmedBalanceSats: "14,250,000 sat",
        totalReceivedBTC: "0.58000000 BTC",
        totalSentBTC: "0.43750000 BTC",
        transactionCount: 12
    )

    static let addressTransactions = [
        TransactionItem(
            id: transactionId,
            shortId: "a1075db5…d48d",
            direction: .incoming,
            amountDisplay: "0.02500000 BTC",
            amountIsPositive: true,
            isConfirmed: true,
            statusLabel: "Confirmed",
            counterpartyAddress: "bc1qsender000000000000000000000000000000000"
        ),
        TransactionItem(
            id: "bb88e1f9c4416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5ab22",
            shortId: "bb88e1f9…ab22",
            direction: .outgoing,
            amountDisplay: "0.01040000 BTC",
            amountIsPositive: false,
            isConfirmed: false,
            statusLabel: "Pending",
            counterpartyAddress: "bc1qrecipient111111111111111111111111111111"
        ),
        TransactionItem(
            id: "cc77e1f9c4416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5cc33",
            shortId: "cc77e1f9…cc33",
            direction: .mixed,
            amountDisplay: "0.00230000 BTC",
            amountIsPositive: true,
            isConfirmed: true,
            statusLabel: "Confirmed",
            counterpartyAddress: nil
        )
    ]

    static let detail = TransactionDetailItem(
        id: transactionId,
        shortId: "a1075db5…d48d",
        direction: .incoming,
        status: .confirmed,
        confirmations: 6,
        blockHeight: 845_321,
        timestamp: "Apr 29, 2026 at 12:00 PM",
        feeBTC: "0.00001200 BTC",
        feeSats: "1,200 sat",
        netAmountDisplay: "0.02500000 BTC",
        netAmountIsPositive: true,
        inputCount: simpleInputs.count,
        outputCount: simpleOutputs.count,
        inputs: simpleInputs,
        outputs: simpleOutputs
    )

    static let simpleInputs = [
        IOItem(
            index: 0,
            address: "bc1qsender000000000000000000000000000000000",
            amountBTC: "0.01500000 BTC",
            amountSats: "1,500,000 sat",
            isRelevantAddress: false
        ),
        IOItem(
            index: 1,
            address: "bc1qsender111111111111111111111111111111111",
            amountBTC: "0.01001200 BTC",
            amountSats: "1,001,200 sat",
            isRelevantAddress: false
        )
    ]

    static let simpleOutputs = [
        IOItem(
            index: 0,
            address: address,
            amountBTC: "0.02500000 BTC",
            amountSats: "2,500,000 sat",
            isRelevantAddress: true
        ),
        IOItem(
            index: 1,
            address: "bc1qchange222222222222222222222222222222222",
            amountBTC: "0.00000000 BTC",
            amountSats: "0 sat",
            isRelevantAddress: false
        )
    ]

    static let complexInputs = (0 ..< 10).map { index in
        IOItem(
            index: index,
            address: "bc1qcomplexinput\(index)00000000000000000000000",
            amountBTC: "0.00500000 BTC",
            amountSats: "500,000 sat",
            isRelevantAddress: index == 0
        )
    }

    static let complexOutputs = (0 ..< 11).map { index in
        IOItem(
            index: index,
            address: "bc1qcomplexoutput\(index)000000000000000000000",
            amountBTC: "0.00450000 BTC",
            amountSats: "450,000 sat",
            isRelevantAddress: index == 1
        )
    }

    static func makeRecentSearchStore() -> RecentSearchStore {
        let suiteName = "ApricotTests.Snapshots.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Unable to create UserDefaults suite for snapshot tests")
        }
        defaults.removePersistentDomain(forName: suiteName)
        return RecentSearchStore(defaults: defaults)
    }
}

final class SnapshotBitcoinService: BitcoinServiceProtocol {
    func fetchAddressData(address _: String) async throws -> AddressData {
        XCTFail("Snapshot service should not perform address fetches")
        throw AddressSearchError.unknown
    }

    func fetchTransactionDetail(txId _: String, forAddress _: String) async throws -> TransactionDetailItem {
        XCTFail("Snapshot service should not perform transaction fetches")
        throw TransactionDetailError.unknown
    }
}
