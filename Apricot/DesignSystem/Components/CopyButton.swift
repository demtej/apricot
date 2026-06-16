import SwiftUI

struct CopyButton: View {
    let value: String

    @State private var copied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = value
            withAnimation(.easeInOut(duration: 0.15)) { copied = true }
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                withAnimation(.easeInOut(duration: 0.2)) { copied = false }
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 14, weight: copied ? .semibold : .regular))
                .foregroundStyle(copied ? Color.apricotInFg : Color.apricotAccent)
                .contentTransition(.symbolEffect(.replace))
        }
    }
}
