import Foundation
import SwiftData

/// Where an address was first encountered, determining its default label prefix.
enum WalletProfileKind: String, Codable, Sendable {
    /// The user searched for this address directly.
    case searched
    /// The address was first seen as a counterparty in a transaction.
    case counterparty

    var labelPrefix: String {
        switch self {
        case .searched: return "S"
        case .counterparty: return "C"
        }
    }
}

/// User-assigned info (label, color, notes) for a Bitcoin address.
///
/// Persisted locally so the same address is shown consistently everywhere
/// in the app, whether it was searched directly or seen as a transaction
/// counterparty. The user can rename the label, change the color, and add
/// free-form notes; the underlying address is never modified.
@Model
final class WalletProfile {
    @Attribute(.unique) var address: String
    var label: String
    var colorHex: String
    var notes: String
    var kindRaw: String
    var sequenceNumber: Int
    var createdAt: Date

    var kind: WalletProfileKind {
        WalletProfileKind(rawValue: kindRaw) ?? .searched
    }

    init(
        address: String,
        label: String,
        colorHex: String,
        notes: String = "",
        kind: WalletProfileKind,
        sequenceNumber: Int,
        createdAt: Date = .now
    ) {
        self.address = address
        self.label = label
        self.colorHex = colorHex
        self.notes = notes
        kindRaw = kind.rawValue
        self.sequenceNumber = sequenceNumber
        self.createdAt = createdAt
    }
}
