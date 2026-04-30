import SwiftUI

// MARK: - Search state

enum AddressSearchState: Equatable {
    case idle
    case loading
    case loaded(summary: AddressSummaryItem, transactions: [TransactionItem])
    case empty(summary: AddressSummaryItem)
    case failed(AddressSearchError)
}

// MARK: - Error

enum AddressSearchError: Equatable, Error {
    case notFound
    case network
    case decoding
    case unknown

    var title: String {
        switch self {
        case .notFound: return "Address Not Found"
        case .network:  return "Network Error"
        case .decoding: return "Data Error"
        case .unknown:  return "Something Went Wrong"
        }
    }

    var message: String {
        switch self {
        case .notFound:
            return "No data was found for this address. Check that it is a valid public Bitcoin address."
        case .network:
            return "Could not reach the network. Check your connection and try again."
        case .decoding:
            return "The response could not be read. Please try again later."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}

// MARK: - Address summary view model

struct AddressSummaryItem: Equatable {
    let address: String
    let confirmedBalanceBTC: String
    let confirmedBalanceSats: String
    let totalReceivedBTC: String
    let totalSentBTC: String
    let transactionCount: Int
}

// MARK: - Transaction view model

struct TransactionItem: Equatable, Identifiable {
    let id: String
    let shortId: String
    let direction: TransactionDirectionDisplay
    let amountDisplay: String
    let amountIsPositive: Bool
    let isConfirmed: Bool
    let statusLabel: String
}

enum TransactionDirectionDisplay: Equatable {
    case incoming
    case outgoing
    case mixed
    case unknown

    var label: String {
        switch self {
        case .incoming: return "Received"
        case .outgoing: return "Sent"
        case .mixed:    return "Mixed"
        case .unknown:  return "—"
        }
    }

    var badgeVariant: ApricotBadgeVariant {
        switch self {
        case .incoming: return .received
        case .outgoing: return .sent
        case .mixed, .unknown: return .neutral
        }
    }
}
