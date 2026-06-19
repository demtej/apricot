import Foundation
import SwiftData

/// A user-defined tag that can be attached to wallet profiles.
/// Tags are global and deduped by name; the same tag can be shared across multiple profiles.
@Model
final class Tag {
    @Attribute(.unique) var name: String
    var createdAt: Date

    init(name: String) {
        self.name = name
        self.createdAt = .now
    }
}
