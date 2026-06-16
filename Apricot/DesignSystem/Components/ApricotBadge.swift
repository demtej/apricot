import SwiftUI

enum ApricotBadgeVariant {
    case received, sent, pending, info, neutral
}

struct ApricotBadge: View {
    var variant: ApricotBadgeVariant = .neutral

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: 26, height: 26)
            .background(background)
            .clipShape(Circle())
    }

    private var iconName: String {
        switch variant {
        case .received: "arrow.down"
        case .sent: "arrow.up"
        case .pending: "clock"
        case .info: "info"
        case .neutral: "circle.fill"
        }
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
