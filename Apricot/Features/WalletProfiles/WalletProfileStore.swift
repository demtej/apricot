import Foundation
import SwiftData
import SwiftUI

/// Default color (hex, no #) assigned to newly created profiles, before the
/// user customizes it.
let kDefaultWalletProfileColorHex = String(format: "%06X", Color.Apricot.scale400Hex)

/// Aliases longer than this are abbreviated to their first 3 characters for
/// compact badges (e.g. RecentSearchRow's icon).
private let kBadgeMaxLength = 3

/// Protocol allows swapping the SwiftData-backed store for a mock in tests.
protocol WalletProfileStoring: AnyObject {
    func profile(for address: String) -> WalletProfile?
    func resolveProfile(for address: String, kind: WalletProfileKind) -> WalletProfile
    func rename(address: String, to label: String)
    func recolor(address: String, to colorHex: String)
    func setNotes(address: String, to notes: String)
    func displayBadge(for address: String) -> String
}

extension WalletProfileStoring {
    /// A compact badge for `address`: the label with spaces removed, capped at 3 characters.
    /// e.g. "AL RIO" → "ALR", "S1" → "S1", "Savings" → "SAV"
    func displayBadge(for address: String) -> String {
        guard let label = profile(for: address)?.label else { return "" }
        let compact = label.filter { !$0.isWhitespace }.uppercased()
        return String(compact.prefix(kBadgeMaxLength))
    }
}

/// Manages user-defined info (label, color, notes) for Bitcoin addresses, backed by SwiftData.
@MainActor
final class WalletProfileStore: ObservableObject, WalletProfileStoring {
    @Published private(set) var profiles: [WalletProfile] = []

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func profile(for address: String) -> WalletProfile? {
        profiles.first { $0.address == address }
    }

    /// Returns the existing profile for `address`, or creates one with the next
    /// sequential label for `kind` (e.g. "S3", "C12").
    ///
    /// An address keeps whichever label it was first assigned: if it was seen
    /// as a counterparty (e.g. "C4") before being searched directly, a later
    /// direct search does not overwrite it with an "S" label.
    @discardableResult
    func resolveProfile(for address: String, kind: WalletProfileKind) -> WalletProfile {
        if let existing = profile(for: address) {
            return existing
        }
        let next = nextSequenceNumber(for: kind)
        let created = WalletProfile(
            address: address,
            label: "\(kind.labelPrefix)\(next)",
            colorHex: kDefaultWalletProfileColorHex,
            kind: kind,
            sequenceNumber: next
        )
        context.insert(created)
        refresh()
        return created
    }

    func rename(address: String, to label: String) {
        guard let existing = profile(for: address) else { return }
        existing.label = label
        refresh()
    }

    func recolor(address: String, to colorHex: String) {
        guard let existing = profile(for: address) else { return }
        existing.colorHex = colorHex
        refresh()
    }

    func setNotes(address: String, to notes: String) {
        guard let existing = profile(for: address) else { return }
        existing.notes = notes
        refresh()
    }

    // MARK: - Private

    private func nextSequenceNumber(for kind: WalletProfileKind) -> Int {
        let highest = profiles
            .filter { $0.kind == kind }
            .map(\.sequenceNumber)
            .max() ?? 0
        return highest + 1
    }

    /// Re-reads profiles from the context. `ModelContext` autosaves to disk on
    /// its own schedule (we don't call `save()` explicitly), but pending
    /// inserts/edits are reflected in fetches within the same context.
    private func refresh() {
        let descriptor = FetchDescriptor<WalletProfile>(sortBy: [SortDescriptor(\.createdAt)])
        profiles = (try? context.fetch(descriptor)) ?? []
    }
}

#if DEBUG
extension WalletProfileStore {
    /// An in-memory store for previews and tests.
    static func preview() -> WalletProfileStore {
        let container = try! ModelContainer(
            for: WalletProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return WalletProfileStore(context: container.mainContext)
    }
}
#endif
