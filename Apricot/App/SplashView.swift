import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.apricotBgPage
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("ApricotFruit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                HStack(spacing: 0) {
                    ForEach(Array("Apricot".enumerated()), id: \.offset) { index, char in
                        ScrambleLetter(
                            target: char,
                            settleAfter: 0.15 + Double(index) * 0.1
                        )
                    }
                }
                .foregroundStyle(Color.apricotFgPrimary)
            }
        }
    }
}

private struct ScrambleLetter: View {
    let target: Character
    let settleAfter: Double

    @State private var current: Character = "0"
    @State private var isSettled = false

    /// All mono chars have identical width — no overflow, no layout jumps
    private static let pool = Array("01xbcJHP3")

    var body: some View {
        // Mono anchor: all scramble chars share this width, no shifts during animation
        Text(String(target))
            .font(.system(size: 48, weight: .regular, design: .monospaced))
            .hidden()
            .overlay {
                Text(String(current))
                    .font(isSettled
                        ? .system(size: 48, weight: .semibold, design: .rounded)
                        : .system(size: 48, weight: .regular, design: .monospaced))
                    .fixedSize()
            }
            .task {
                current = Self.pool.randomElement() ?? "0"
                let start = Date()
                while Date().timeIntervalSince(start) < settleAfter {
                    current = Self.pool.randomElement() ?? "0"
                    try? await Task.sleep(nanoseconds: 55_000_000)
                }
                current = target
                isSettled = true
            }
    }
}

#Preview {
    SplashView()
}
