import SwiftUI

/// Forces a view to a single line, truncating with "…" in the middle if it doesn't fit.
/// Font size is preserved; if the content fits, nothing changes.
struct MiddleTruncatedSingleLine: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .truncationMode(.middle)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func middleTruncatedSingleLine() -> some View {
        modifier(MiddleTruncatedSingleLine())
    }
}
