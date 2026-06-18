import SwiftUI

// MARK: - Search state

enum AddressSearchState: Equatable {
    case idle
    case loading
    case loaded(summary: AddressSummaryItem, transactions: [TransactionItem], showsInsights: Bool)
    case empty(summary: AddressSummaryItem, showsInsights: Bool)
    case failed(AddressSearchError)

    var isLoaded: Bool {
        switch self {
        case .loaded, .empty: true
        default: false
        }
    }
}

// MARK: - Error

enum AddressSearchError: Equatable, Error {
    case notFound
    case network
    case decoding
    case unknown

    var title: String {
        switch self {
        case .notFound: "Address Not Found"
        case .network: "Network Error"
        case .decoding: "Data Error"
        case .unknown: "Something Went Wrong"
        }
    }

    var message: String {
        switch self {
        case .notFound:
            "No data was found for this address. Check that it is a valid public Bitcoin address."
        case .network:
            "Could not reach the network. Check your connection and try again."
        case .decoding:
            "The response could not be read. Please try again later."
        case .unknown:
            "An unexpected error occurred. Please try again."
        }
    }

    var analyticsCategory: String {
        switch self {
        case .notFound:
            "not_found"
        case .network:
            "network"
        case .decoding:
            "decoding"
        case .unknown:
            "unknown"
        }
    }
}

// MARK: - Address summary view model

struct AddressSummaryItem: Equatable {
    let address: String
    let shortAddress: String
    let confirmedBalanceBTC: String
    let confirmedBalanceSats: String
    let totalReceivedBTC: String
    let totalSentBTC: String
    let transactionCount: Int
}

// MARK: - Transaction view model

struct TransactionItem: Equatable, Hashable, Identifiable {
    let id: String
    let shortId: String
    let direction: TransactionDirectionDisplay
    let amountDisplay: String
    let amountIsPositive: Bool
    let isConfirmed: Bool
    let statusLabel: String
    let counterpartyAddress: String?

    var signedAmountDisplay: String {
        (amountIsPositive ? "+" : "−") + amountDisplay
    }

    var counterpartyShortAddress: String? {
        counterpartyAddress.map { BitcoinFormatter.shortAddress($0) }
    }
}

enum TransactionDirectionDisplay: Equatable {
    case incoming
    case outgoing
    case mixed
    case unknown

    var label: String {
        switch self {
        case .incoming: "Received"
        case .outgoing: "Sent"
        case .mixed: "Mixed"
        case .unknown: "—"
        }
    }

    var badgeVariant: ApricotBadgeVariant {
        switch self {
        case .incoming: .received
        case .outgoing: .sent
        case .mixed, .unknown: .neutral
        }
    }
}
