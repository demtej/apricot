import SwiftUI

// MARK: - Button styles

struct ApricotPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(-0.15)
            .foregroundStyle(Color.apricotFgOnAccent)
            .padding(.horizontal, 22)
            .frame(minHeight: 48)
            .background(
                Color.apricotAccent
                    .brightness(configuration.isPressed ? -0.05 : 0)
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct ApricotSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(-0.15)
            .foregroundStyle(Color.apricotFgPrimary)
            .padding(.horizontal, 22)
            .frame(minHeight: 48)
            .background(
                configuration.isPressed ? Color.apricotBgSurface : Color.apricotBgElevated
            )
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.apricotBorderDefault, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct ApricotGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(-0.15)
            .foregroundStyle(Color.apricotFgPrimary)
            .padding(.horizontal, 22)
            .frame(minHeight: 48)
            .background(
                configuration.isPressed ? Color.apricotBgSurface2 : Color.clear
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct ApricotSoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(-0.15)
            .foregroundStyle(Color.Apricot.scale700)
            .padding(.horizontal, 22)
            .frame(minHeight: 48)
            .background(
                configuration.isPressed ? Color.Apricot.scale200 : Color.apricotAccentSoft
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// Convenience extension so call sites read: .buttonStyle(.apricotPrimary)
extension ButtonStyle where Self == ApricotPrimaryButtonStyle {
    static var apricotPrimary: ApricotPrimaryButtonStyle {
        .init()
    }
}

extension ButtonStyle where Self == ApricotSecondaryButtonStyle {
    static var apricotSecondary: ApricotSecondaryButtonStyle {
        .init()
    }
}

extension ButtonStyle where Self == ApricotGhostButtonStyle {
    static var apricotGhost: ApricotGhostButtonStyle {
        .init()
    }
}

extension ButtonStyle where Self == ApricotSoftButtonStyle {
    static var apricotSoft: ApricotSoftButtonStyle {
        .init()
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("Search Address") {}
            .buttonStyle(.apricotPrimary)
        Button("View Details") {}
            .buttonStyle(.apricotSecondary)
        Button("Go back") {}
            .buttonStyle(.apricotGhost)
        Button("Explore") {}
            .buttonStyle(.apricotSoft)
    }
    .padding()
    .background(Color.apricotBgPage)
}
