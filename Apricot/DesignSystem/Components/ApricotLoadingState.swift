import SwiftUI

// MARK: - Skeleton block

struct SkeletonView: View {
    var cornerRadius: CGFloat = ApricotRadius.sm
    @State private var opacity: Double = 1.0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.apricotBgSurface2)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.9)
                        .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.4
                }
            }
    }
}

// MARK: - Full-screen loading placeholder

struct ApricotLoadingState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s4) {
            // Address card skeleton
            ApricotCard {
                VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                    SkeletonView().frame(width: 100, height: 11)
                    SkeletonView().frame(width: 200, height: 12)
                    SkeletonView().frame(maxWidth: .infinity).frame(height: 36)
                    SkeletonView().frame(width: 100, height: 12)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 8
                    ) {
                        ForEach(0 ..< 4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 6) {
                                SkeletonView().frame(width: 60, height: 10)
                                SkeletonView().frame(width: 80, height: 14)
                            }
                            .padding(10)
                            .background(Color.apricotBgSurface)
                            .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
                        }
                    }
                }
            }

            // Transaction row skeletons
            ForEach(0 ..< 3, id: \.self) { _ in
                txRowSkeleton
            }
        }
        .padding(.horizontal, ApricotSpacing.s4)
    }

    private var txRowSkeleton: some View {
        HStack(spacing: 12) {
            SkeletonView(cornerRadius: ApricotRadius.full)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 6) {
                SkeletonView().frame(width: 160, height: 12)
                SkeletonView().frame(width: 100, height: 10)
            }
            Spacer()
            SkeletonView().frame(width: 70, height: 14)
        }
        .padding(ApricotSpacing.s4)
        .background(Color.apricotBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.md)
                .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        ApricotLoadingState()
            .padding(.top, ApricotSpacing.s4)
    }
    .background(Color.apricotBgPage)
}
