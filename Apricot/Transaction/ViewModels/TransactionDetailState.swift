import SwiftUI

// MARK: - State

enum TransactionDetailState: Equatable {
    case idle
    case loading
    case loaded(TransactionDetailItem)
    case failed(TransactionDetailError)
}

// MARK: - Error

enum TransactionDetailError: Equatable, Error {
    case notFound
    case network
    case decoding
    case unknown

    var title: String {
        switch self {
        case .notFound: return "Transaction Not Found"
        case .network:  return "Network Error"
        case .decoding: return "Data Error"
        case .unknown:  return "Something Went Wrong"
        }
    }

    var message: String {
        switch self {
        case .notFound:
            return "No data was found for this transaction ID."
        case .network:
            return "Could not reach the network. Check your connection and try again."
        case .decoding:
            return "The response could not be read. Please try again later."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}

// MARK: - Display model

struct TransactionDetailItem: Equatable {
    let id: String
    let shortId: String
    let summary: String
    let direction: TransactionDirectionDisplay
    let status: TransactionStatusDisplay
    let confirmations: Int?
    let blockHeight: Int?
    let timestamp: String?
    let feeBTC: String
    let feeSats: String
    let netAmountDisplay: String
    let netAmountIsPositive: Bool
    let inputCount: Int
    let outputCount: Int
    let inputs: [IOItem]
    let outputs: [IOItem]
}

// MARK: - Status

enum TransactionStatusDisplay: Equatable {
    case confirmed
    case pending

    var label: String {
        switch self {
        case .confirmed: return "Confirmed"
        case .pending:   return "Pending"
        }
    }

    var badgeVariant: ApricotBadgeVariant {
        switch self {
        case .confirmed: return .info
        case .pending:   return .pending
        }
    }
}

// MARK: - IO item

struct IOItem: Equatable, Identifiable {
    let index: Int
    let address: String?
    let amountBTC: String
    let amountSats: String
    let isRelevantAddress: Bool

    var id: Int { index }
}
