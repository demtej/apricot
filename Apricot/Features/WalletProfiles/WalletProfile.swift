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

/// User-assigned info (label, color, notes, tags) for a Bitcoin address.
///
/// Persisted locally so the same address is shown consistently everywhere
/// in the app, whether it was searched directly or seen as a transaction
/// counterparty. The user can rename the label, change the color, add
/// free-form notes, and attach tags; the underlying address is never modified.
@Model
final class WalletProfile {
    @Attribute(.unique) var address: String
    var label: String
    /// SwiftData backing store for the color — stored as enum raw value string.
    /// The default value here is required for lightweight migration when this attribute is new
    /// to an existing store. Legacy hex strings (e.g. "F4A26B") fall back to `.apricot` via `color`.
    var colorHex: String = WalletProfileColor.apricot.rawValue
    var notes: String
    var kindRaw: String
    var sequenceNumber: Int
    var createdAt: Date
    @Relationship var tags: [Tag] = []

    /// Typed accessor; falls back to `.apricot` for unrecognized raw values (legacy hex data).
    var color: WalletProfileColor {
        get { WalletProfileColor(rawValue: colorHex) ?? .apricot }
        set { colorHex = newValue.rawValue }
    }

    var kind: WalletProfileKind {
        WalletProfileKind(rawValue: kindRaw) ?? .searched
    }

    init(
        address: String,
        label: String,
        color: WalletProfileColor = .apricot,
        notes: String = "",
        kind: WalletProfileKind,
        sequenceNumber: Int,
        createdAt: Date = .now
    ) {
        self.address = address
        self.label = label
        self.colorHex = color.rawValue
        self.notes = notes
        kindRaw = kind.rawValue
        self.sequenceNumber = sequenceNumber
        self.createdAt = createdAt
    }
}
