import SwiftUI

// MARK: - Internal hex helpers

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    static func adaptive(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) }
    }

    static func adaptive(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

// MARK: - Hex color initializer (used by wallet profile color swatches)

extension Color {
    /// Creates a Color from a 6-digit hex string without '#' (e.g. "F4A26B").
    init(profileHex hex: String) {
        let value = UInt32(hex, radix: 16) ?? 0xF4A26B
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

// MARK: - Brand palette (fixed, not adaptive)

extension Color {
    enum Apricot {
        static let scale50 = Color(UIColor(hex: 0xFFF6EE))
        static let scale100 = Color(UIColor(hex: 0xFFE8D2))
        static let scale200 = Color(UIColor(hex: 0xFBD3AE))
        static let scale300 = Color(UIColor(hex: 0xF7B884))
        static let scale400Hex: UInt32 = 0xF4A26B // brand primary
        static let scale400 = Color(UIColor(hex: scale400Hex))
        static let scale500 = Color(UIColor(hex: 0xEE8A4E))
        static let scale600 = Color(UIColor(hex: 0xD9703A))
        static let scale700 = Color(UIColor(hex: 0xB0552A))
        static let scale800 = Color(UIColor(hex: 0x7E3C1E))
        static let scale900 = Color(UIColor(hex: 0x4A2412))

        static let sage100 = Color(UIColor(hex: 0xE4EDD9))
        static let sage300 = Color(UIColor(hex: 0xB4C99A))
        static let sage600 = Color(UIColor(hex: 0x6B8E4E))

        static let rose100 = Color(UIColor(hex: 0xF4DCD8))
        static let rose300 = Color(UIColor(hex: 0xD9A09A))
        static let rose600 = Color(UIColor(hex: 0x9B5048))

        static let amber100 = Color(UIColor(hex: 0xFBE8C2))
        static let amber600 = Color(UIColor(hex: 0xA06A1F))

        static let sky100 = Color(UIColor(hex: 0xDCE8F0))
        static let sky600 = Color(UIColor(hex: 0x3F6A86))
    }
}

// MARK: - Semantic adaptive tokens

extension Color {
    /// Backgrounds
    static var apricotBgPage: Color {
        Color(UIColor.adaptive(light: 0xFFFDFA, dark: 0x1A1612))
    }

    static var apricotBgSurface: Color {
        Color(UIColor.adaptive(light: 0xFAF6F0, dark: 0x221D17))
    }

    static var apricotBgSurface2: Color {
        Color(UIColor.adaptive(light: 0xF2EBE0, dark: 0x2C2620))
    }

    static var apricotBgElevated: Color {
        Color(UIColor.adaptive(light: 0xFFFFFF, dark: 0x2C2620))
    }

    /// Foreground
    static var apricotFgPrimary: Color {
        Color(UIColor.adaptive(light: 0x3A352C, dark: 0xE6DCCB))
    }

    static var apricotFgSecondary: Color {
        Color(UIColor.adaptive(light: 0x7C7261, dark: 0xA89C86))
    }

    static var apricotFgMuted: Color {
        Color(UIColor.adaptive(light: 0xA89C86, dark: 0x7C7261))
    }

    static let apricotFgOnAccent = Color.white

    /// Borders
    static var apricotBorderSubtle: Color {
        Color(UIColor.adaptive(light: 0xE6DCCB, dark: 0x3A332B))
    }

    static var apricotBorderDefault: Color {
        Color(UIColor.adaptive(light: 0xD2C5AF, dark: 0x4D4438))
    }

    static var apricotBorderStrong: Color {
        Color(UIColor.adaptive(light: 0xA89C86, dark: 0x7C7261))
    }

    /// Accent
    static var apricotAccent: Color {
        Color(UIColor.adaptive(light: 0xF4A26B, dark: 0xF7B884))
    }

    static var apricotAccentHover: Color {
        Color(UIColor.adaptive(light: 0xEE8A4E, dark: 0xFBD3AE))
    }

    // Light: apricot-100; Dark: apricot-400 at 12% opacity
    static var apricotAccentSoft: Color {
        Color(UIColor.adaptive(
            light: UIColor(hex: 0xFFE8D2),
            dark: UIColor(hex: 0xF4A26B, alpha: 0.12)
        ))
    }

    /// Transaction direction
    static var apricotInBg: Color {
        Color(UIColor.adaptive(light: 0xE4EDD9, dark: 0x2E3A26))
    }

    static var apricotInFg: Color {
        Color(UIColor.adaptive(light: 0x6B8E4E, dark: 0xB4C99A))
    }

    static var apricotOutBg: Color {
        Color(UIColor.adaptive(light: 0xF4DCD8, dark: 0x3A2622))
    }

    static var apricotOutFg: Color {
        Color(UIColor.adaptive(light: 0x9B5048, dark: 0xD9A09A))
    }

    static var apricotPendingBg: Color {
        Color(UIColor.adaptive(light: 0xFBE8C2, dark: 0x3A2D14))
    }

    static var apricotPendingFg: Color {
        Color(UIColor.adaptive(light: 0xA06A1F, dark: 0xE8B973))
    }

    static var apricotInfoBg: Color {
        Color(UIColor.adaptive(light: 0xDCE8F0, dark: 0x1E2C36))
    }

    static var apricotInfoFg: Color {
        Color(UIColor.adaptive(light: 0x3F6A86, dark: 0x9CC0D6))
    }
}

#Preview("Backgrounds & Foregrounds") {
    VStack(alignment: .leading, spacing: 8) {
        swatch("apricotBgPage", .apricotBgPage)
        swatch("apricotBgSurface", .apricotBgSurface)
        swatch("apricotBgSurface2", .apricotBgSurface2)
        swatch("apricotBgElevated", .apricotBgElevated)
        swatch("apricotFgPrimary", .apricotFgPrimary)
        swatch("apricotFgSecondary", .apricotFgSecondary)
        swatch("apricotFgMuted", .apricotFgMuted)
        swatch("apricotAccent", .apricotAccent)
        swatch("apricotAccentSoft", .apricotAccentSoft)
        swatch("apricotBorderDefault", .apricotBorderDefault)
    }
    .padding()
    .background(Color.apricotBgPage)
}

#Preview("Transaction Direction Tokens") {
    VStack(alignment: .leading, spacing: 8) {
        swatch("apricotInBg / apricotInFg", .apricotInBg, fg: .apricotInFg)
        swatch("apricotOutBg / apricotOutFg", .apricotOutBg, fg: .apricotOutFg)
        swatch("apricotPendingBg / apricotPendingFg", .apricotPendingBg, fg: .apricotPendingFg)
        swatch("apricotInfoBg / apricotInfoFg", .apricotInfoBg, fg: .apricotInfoFg)
    }
    .padding()
    .background(Color.apricotBgPage)
}

private func swatch(_ name: String, _ bg: Color, fg: Color = .apricotFgPrimary) -> some View {
    HStack {
        RoundedRectangle(cornerRadius: 6)
            .fill(bg)
            .frame(width: 32, height: 32)
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.apricotBorderDefault, lineWidth: 1))
        Text(name)
            .font(.apricotCaption)
            .foregroundStyle(fg)
    }
}
