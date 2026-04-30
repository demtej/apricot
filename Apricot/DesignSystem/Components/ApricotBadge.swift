import SwiftUI

enum ApricotBadgeVariant {
    case received, sent, pending, info, neutral
}

struct ApricotBadge: View {
    let label: String
    var variant: ApricotBadgeVariant = .neutral
    var showDot: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            if showDot {
                Circle()
                    .fill(foreground)
                    .opacity(0.85)
                    .frame(width: 6, height: 6)
            }
            Text(label)
                .font(.apricotLabel)
                .foregroundStyle(foreground)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(background)
        .clipShape(Capsule())
    }

    private var background: Color {
        switch variant {
        case .received: .apricotInBg
        case .sent: .apricotOutBg
        case .pending: .apricotPendingBg
        case .info: .apricotInfoBg
        case .neutral: .apricotBgSurface2
        }
    }

    private var foreground: Color {
        switch variant {
        case .received: .apricotInFg
        case .sent: .apricotOutFg
        case .pending: .apricotPendingFg
        case .info: .apricotInfoFg
        case .neutral: .apricotFgSecondary
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ApricotBadge(label: "Received", variant: .received)
        ApricotBadge(label: "Sent", variant: .sent)
        ApricotBadge(label: "Pending", variant: .pending)
        ApricotBadge(label: "Info", variant: .info)
        ApricotBadge(label: "Neutral", variant: .neutral)
    }
    .padding()
    .background(Color.apricotBgPage)
}
