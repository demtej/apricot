import SwiftUI

// MARK: - Type scale

// Mirrors --text-* CSS tokens using SF Pro (system font, closest to Geist on iOS).
// Monospace slots use .monospaced design (SF Mono / Menlo fallback).

extension Font {
    static var apricotDisplay: Font {
        .system(size: 44, weight: .semibold)
    }

    static var apricotH1: Font {
        .system(size: 34, weight: .semibold)
    }

    static var apricotH2: Font {
        .system(size: 28, weight: .semibold)
    }

    static var apricotH3: Font {
        .system(size: 24, weight: .semibold)
    }

    static var apricotTitle: Font {
        .system(size: 17, weight: .semibold)
    }

    static var apricotBody: Font {
        .system(size: 15, weight: .regular)
    }

    static var apricotBodyStrong: Font {
        .system(size: 15, weight: .medium)
    }

    static var apricotCaption: Font {
        .system(size: 13, weight: .regular)
    }

    static var apricotLabel: Font {
        .system(size: 12, weight: .medium)
    }

    /// Blockchain-specific — monospace only for addresses, tx IDs, amounts, fees
    static var apricotMono: Font {
        .system(size: 15, design: .monospaced)
    }

    static var apricotMonoSm: Font {
        .system(size: 13, design: .monospaced)
    }

    static var apricotMonoNum: Font {
        .system(size: 28, weight: .medium, design: .monospaced)
    }
}

// MARK: - Tracking constants

// Approximate em-to-pt conversion at common sizes (tracking-tight: -0.02em, mono: -0.01em)

extension CGFloat {
    static let apricotTrackingTight: CGFloat = -0.68 // -0.02em @ 34px
    static let apricotTrackingSnug: CGFloat = -0.34 // -0.01em @ 34px
    static let apricotTrackingWide: CGFloat = 0.24 //  0.02em @ 12px (labels)
    static let apricotTrackingMono: CGFloat = -0.15 // -0.01em @ 15px
}

// MARK: - Mono text modifier

struct ApricotMonoModifier: ViewModifier {
    enum Size { case regular, small, number }
    let size: Size

    func body(content: Content) -> some View {
        content
            .font(font)
            .monospacedDigit()
            .tracking(tracking)
    }

    private var font: Font {
        switch size {
        case .regular: .apricotMono
        case .small: .apricotMonoSm
        case .number: .apricotMonoNum
        }
    }

    private var tracking: CGFloat {
        switch size {
        case .regular: -0.15
        case .small: -0.13
        case .number: -0.28
        }
    }
}

extension View {
    func apricotMono(_ size: ApricotMonoModifier.Size = .regular) -> some View {
        modifier(ApricotMonoModifier(size: size))
    }
}

#Preview("Type Scale") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Display").font(.apricotDisplay)
        Text("Heading 1").font(.apricotH1)
        Text("Heading 2").font(.apricotH2)
        Text("Heading 3").font(.apricotH3)
        Text("Title").font(.apricotTitle)
        Text("Body").font(.apricotBody)
        Text("Body strong").font(.apricotBodyStrong)
        Text("Caption").font(.apricotCaption)
        Text("LABEL").font(.apricotLabel).tracking(.apricotTrackingWide)
    }
    .padding()
    .background(Color.apricotBgPage)
}

#Preview("Mono Styles") {
    VStack(alignment: .leading, spacing: 12) {
        Text("bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq").apricotMono(.regular)
        Text("a1075db55d416d3ca…").apricotMono(.small)
        Text("0.00142836").apricotMono(.number)
    }
    .padding()
    .background(Color.apricotBgPage)
}
