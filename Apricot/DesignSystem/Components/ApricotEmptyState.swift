import SwiftUI

struct ApricotEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "magnifyingglass"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: ApricotSpacing.s5) {
            ZStack {
                Circle()
                    .fill(Color.apricotAccentSoft)
                    .frame(width: 72, height: 72)
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.apricotAccent)
            }

            VStack(spacing: ApricotSpacing.s2) {
                Text(title)
                    .font(.apricotH3)
                    .foregroundStyle(Color.apricotFgPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.apricotCaption)
                    .foregroundStyle(Color.apricotFgSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.apricotPrimary)
            }
        }
        .padding(ApricotSpacing.s8)
    }
}

#Preview {
    ApricotEmptyState(
        title: "No transactions yet",
        message: "This address hasn't sent or received any Bitcoin.",
        systemImage: "arrow.left.arrow.right",
        actionTitle: "Search another address"
    ) {}
    .background(Color.apricotBgPage)
}
