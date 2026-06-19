import SwiftUI

struct DisclaimerTicker: View {
    let onComplete: () -> Void

    private let text = "Apricot displays publicly available Bitcoin blockchain data. Not financial advice. No wallet connection. No private keys."
    private let speed: CGFloat = 70 // points per second

    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var didStart = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Hidden copy to measure natural text width
                Text(text)
                    .font(.apricotLabel)
                    .lineLimit(1)
                    .fixedSize()
                    .hidden()
                    .background(
                        GeometryReader { textGeo in
                            Color.clear.onAppear {
                                textWidth = textGeo.size.width
                                containerWidth = geo.size.width
                                maybeStart()
                            }
                        }
                    )

                Text(text)
                    .font(.apricotLabel)
                    .foregroundStyle(Color.apricotFgMuted)
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: offset)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.18),
                                .init(color: .black, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .clipped()
        }
    }

    private func maybeStart() {
        guard !didStart, textWidth > 0, containerWidth > 0 else { return }
        didStart = true
        offset = containerWidth
        let distance = containerWidth + textWidth
        let duration = Double(distance) / Double(speed)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: duration)) {
                offset = -textWidth
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onComplete()
            }
        }
    }
}
