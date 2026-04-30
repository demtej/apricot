import SwiftUI

struct ApricotErrorState: View {
    let title: String
    let message: String
    var retryTitle: String = "Try again"
    var onRetry: (() -> Void)?
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: ApricotSpacing.s5) {
            ZStack {
                Circle()
                    .fill(Color.apricotOutBg)
                    .frame(width: 72, height: 72)
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.apricotOutFg)
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

            VStack(spacing: ApricotSpacing.s2) {
                if let onRetry {
                    Button(retryTitle, action: onRetry)
                        .buttonStyle(.apricotPrimary)
                }
                if let onBack {
                    Button("Go back", action: onBack)
                        .buttonStyle(.apricotGhost)
                }
            }
        }
        .padding(ApricotSpacing.s8)
    }
}

#Preview {
    ApricotErrorState(
        title: "We can't reach the network",
        message: "Check your connection and try again. We've kept your search safe.",
        onRetry: {},
        onBack: {}
    )
    .background(Color.apricotBgPage)
}
