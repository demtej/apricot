import SwiftUI

// Inline monospaced text for blockchain values (addresses, tx IDs, amounts, fees).
// Apply .apricotMono() modifier to any Text, or use MonoText directly.

struct MonoText: View {
    let text: String
    var size: ApricotMonoModifier.Size = .regular
    var color: Color?

    var body: some View {
        Text(text)
            .apricotMono(size)
            .foregroundStyle(color ?? .apricotFgPrimary)
    }
}

/// Inline code chip for hashes / addresses embedded in prose.
struct MonoChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.apricotMonoSm)
            .tracking(.apricotTrackingMono)
            .foregroundStyle(Color.apricotFgPrimary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.apricotBgSurface2)
            .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.xs))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        MonoText(text: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq")
        MonoText(text: "0.00142836", size: .number, color: .apricotInFg)
        MonoText(text: "a1075db55d416d3ca…", size: .small, color: .apricotFgSecondary)
        MonoChip(text: "bc1q…59gz")
    }
    .padding()
    .background(Color.apricotBgPage)
}
