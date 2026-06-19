import SwiftUI

// MARK: - Environment key for disabling animations (used in snapshot tests)

private struct ApricotAnimationsEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var apricotAnimationsEnabled: Bool {
        get { self[ApricotAnimationsEnabledKey.self] }
        set { self[ApricotAnimationsEnabledKey.self] = newValue }
    }
}

struct ApricotSearchField: View {
    @Binding var text: String
    var placeholder: String = "Filter address"
    var onSubmit: (() -> Void)?
    var onPaste: (() -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: ApricotSpacing.s3) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.apricotFgMuted)

            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .foregroundStyle(Color.apricotFgPrimary)
                .tint(Color.apricotAccent)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            if text.isEmpty, let onPaste {
                Button(action: onPaste) {
                    VStack(spacing: 0) {
                        Text("PASTE")
                        Text("ADDRESS")
                    }
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.apricotAccent)
                    .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            } else if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.apricotFgMuted)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, ApricotSpacing.s4)
        .frame(minHeight: 56)
        .contentShape(Capsule())
        .simultaneousGesture(TapGesture().onEnded { isFocused = true })
        .background(Color.apricotBgElevated)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                isFocused ? Color.apricotAccent : Color.apricotBorderDefault,
                lineWidth: 1
            )
        )
        .overlay {
            PulsingBorderGlow()
                .opacity(isFocused ? 0 : 1)
                .animation(.easeInOut(duration: 0.25), value: isFocused)
                .allowsHitTesting(false)
        }
        .shadow(
            color: Color(red: 0.298, green: 0.212, blue: 0.11).opacity(0.05),
            radius: 3,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.14), value: isFocused)
    }
}

// MARK: - Border glow

private struct PulsingBorderGlow: View {
    @Environment(\.apricotAnimationsEnabled) private var animationsEnabled

    var body: some View {
        ZStack {
            // Constant soft glow behind the moving arc
            Capsule()
                .stroke(Color.apricotAccent.opacity(0.18), lineWidth: 10)
                .blur(radius: 8)

            // Moving gradient arc: transparent → orange → transparent
            if animationsEnabled { TimelineView(.animation) { context in
                let period = 4.5
                let phase = CGFloat(
                    context.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: period) / period
                )
                // Glow layer — wider, softer
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let steps = 80
                    let halfWidth: CGFloat = 0.17

                    for i in 0 ..< steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        let next = CGFloat(i + 1) / CGFloat(steps)
                        let mid = (t + next) / 2

                        var dist = abs(mid - phase)
                        dist = min(dist, 1 - dist)
                        guard dist < halfWidth else { continue }

                        let normalized = 1 - dist / halfWidth
                        let opacity = Double(normalized * normalized) * 0.45

                        let seg = Capsule().trim(from: t, to: next).path(in: rect)
                        ctx.stroke(seg, with: .color(Color.apricotAccent.opacity(opacity)), lineWidth: 7)
                    }
                }
                .blur(radius: 5)
                // Sharp line on top
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let steps = 80
                    let halfWidth: CGFloat = 0.17

                    for i in 0 ..< steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        let next = CGFloat(i + 1) / CGFloat(steps)
                        let mid = (t + next) / 2

                        var dist = abs(mid - phase)
                        dist = min(dist, 1 - dist)
                        guard dist < halfWidth else { continue }

                        let normalized = 1 - dist / halfWidth
                        let opacity = Double(normalized * normalized)

                        let seg = Capsule().trim(from: t, to: next).path(in: rect)
                        ctx.stroke(seg, with: .color(Color.apricotAccent.opacity(opacity)), lineWidth: 1.5)
                    }
                }
            } } // TimelineView + if !reduceMotion
        }
    }
}

#Preview {
    @Previewable @State var query = ""
    VStack(spacing: 16) {
        ApricotSearchField(text: $query)
        ApricotSearchField(text: .constant("bc1qar0srrr7xfkvy5l643…"))
    }
    .padding()
    .background(Color.apricotBgPage)
}
