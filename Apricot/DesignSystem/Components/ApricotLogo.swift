import SwiftUI

/// SVG-faithful recreation of the Apricot brand mark (fruit + leaf + highlight).
struct ApricotLogo: View {
    var size: CGFloat = 28

    var body: some View {
        Canvas { ctx, canvasSize in
            let s = canvasSize.width / 56 // scale to viewBox 56×56

            // Fruit body: cx=26 cy=32 r=18
            let bodyRect = CGRect(x: 8 * s, y: 14 * s, width: 36 * s, height: 36 * s)
            ctx.fill(
                Circle().path(in: bodyRect),
                with: .color(Color(red: 0.957, green: 0.635, blue: 0.42))
            )

            // Leaf: SVG path M26 14 C26 14 30 18 32 22 C28 24 24 22 22 18 C23 16 26 14 26 14 Z
            var leaf = Path()
            leaf.move(to: CGPoint(x: 26 * s, y: 14 * s))
            leaf.addCurve(
                to: CGPoint(x: 32 * s, y: 22 * s),
                control1: CGPoint(x: 26 * s, y: 14 * s),
                control2: CGPoint(x: 30 * s, y: 18 * s)
            )
            leaf.addCurve(
                to: CGPoint(x: 22 * s, y: 18 * s),
                control1: CGPoint(x: 28 * s, y: 24 * s),
                control2: CGPoint(x: 24 * s, y: 22 * s)
            )
            leaf.addCurve(
                to: CGPoint(x: 26 * s, y: 14 * s),
                control1: CGPoint(x: 23 * s, y: 16 * s),
                control2: CGPoint(x: 26 * s, y: 14 * s)
            )
            leaf.closeSubpath()
            ctx.fill(leaf, with: .color(Color(red: 0.42, green: 0.557, blue: 0.306)))

            // Highlight: cx=20 cy=30 r=3
            let hlRect = CGRect(x: 17 * s, y: 27 * s, width: 6 * s, height: 6 * s)
            ctx.fill(
                Circle().path(in: hlRect),
                with: .color(Color(red: 1, green: 0.91, blue: 0.824).opacity(0.7))
            )
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        ApricotLogo(size: 24)
        ApricotLogo(size: 32)
        ApricotLogo(size: 48)
    }
    .padding()
}
