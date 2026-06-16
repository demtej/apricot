import SwiftUI

enum ApricotBadgeVariant {
    case received, sent, pending, pendingReceived, pendingSent, info, neutral
}

struct ApricotBadge: View {
    var variant: ApricotBadgeVariant = .neutral

    var body: some View {
        ZStack {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: 26, height: 26)
                .background(background)
                .clipShape(Circle())

            // Small clock pip in the corner for pending-directional variants
            if variant == .pendingReceived || variant == .pendingSent {
                Image(systemName: "clock.fill")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(Color.apricotPendingFg)
                    .frame(width: 11, height: 11)
                    .background(Color.apricotPendingBg)
                    .clipShape(Circle())
                    .offset(x: 8, y: 8)
            }
        }
        .frame(width: 26, height: 26)
    }

    private var iconName: String {
        switch variant {
        case .received: "arrow.down"
        case .sent: "arrow.up"
        case .pending: "clock"
        case .pendingReceived: "arrow.down"
        case .pendingSent: "arrow.up"
        case .info: "info"
        case .neutral: "circle.fill"
        }
    }

    private var background: Color {
        switch variant {
        case .received: .apricotInBg
        case .sent: .apricotOutBg
        case .pending: .apricotPendingBg
        case .pendingReceived: .apricotInBg.opacity(0.5)
        case .pendingSent: .apricotOutBg.opacity(0.5)
        case .info: .apricotInfoBg
        case .neutral: .apricotBgSurface2
        }
    }

    private var foreground: Color {
        switch variant {
        case .received: .apricotInFg
        case .sent: .apricotOutFg
        case .pending: .apricotPendingFg
        case .pendingReceived: .apricotInFg.opacity(0.6)
        case .pendingSent: .apricotOutFg.opacity(0.6)
        case .info: .apricotInfoFg
        case .neutral: .apricotFgSecondary
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ApricotBadge(variant: .received)
        ApricotBadge(variant: .sent)
        ApricotBadge(variant: .pending)
        ApricotBadge(variant: .info)
        ApricotBadge(variant: .neutral)
    }
    .padding()
    .background(Color.apricotBgPage)
}
