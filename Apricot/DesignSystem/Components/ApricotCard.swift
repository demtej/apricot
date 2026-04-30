import SwiftUI

struct ApricotCard<Content: View>: View {
    enum Style { case `default`, flat, elevated }

    let style: Style
    let content: Content

    init(style: Style = .default, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .padding(ApricotSpacing.s5)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: ApricotRadius.lg)
                    .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }

    private var background: Color {
        style == .flat ? .apricotBgSurface : .apricotBgElevated
    }

    private var shadowColor: Color {
        switch style {
        case .flat: .clear
        case .default: Color(red: 0.298, green: 0.212, blue: 0.11).opacity(0.04)
        case .elevated: Color(red: 0.298, green: 0.212, blue: 0.11).opacity(0.06)
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .flat: 0
        case .default: 1
        case .elevated: 8
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .flat: 0
        case .default: 1
        case .elevated: 6
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ApricotCard {
            Text("Default card").font(.apricotBody)
        }
        ApricotCard(style: .flat) {
            Text("Flat card").font(.apricotBody)
        }
        ApricotCard(style: .elevated) {
            Text("Elevated card").font(.apricotBody)
        }
    }
    .padding()
    .background(Color.apricotBgPage)
}
