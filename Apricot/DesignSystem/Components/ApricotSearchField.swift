import SwiftUI

struct ApricotSearchField: View {
    @Binding var text: String
    var placeholder: String = "bc1q…  or  a1075db5…"
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.apricotFgMuted)
                .frame(width: 52)

            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .foregroundStyle(Color.apricotFgPrimary)
                .tint(Color.apricotAccent)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
        }
        .frame(minHeight: 56)
        .background(Color.apricotBgElevated)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                isFocused ? Color.apricotAccent : Color.apricotBorderDefault,
                lineWidth: 1
            )
        )
        .shadow(
            color: Color(red: 0.298, green: 0.212, blue: 0.11).opacity(0.05),
            radius: 3,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.14), value: isFocused)
    }
}

#Preview {
    @Previewable @State var query = ""
    VStack(spacing: 16) {
        ApricotSearchField(text: $query)
        ApricotSearchField(text: .constant("bc1qar0srrr7xfkvy5l643…"))
    }
    .padding()
    .background(Color.apricotBgPage)
}
