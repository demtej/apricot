import SwiftUI

struct DisclaimerSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let supportURL = URL(string: "https://demtej.github.io/apricot/support")

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.apricotBgPage.ignoresSafeArea()

            VStack(alignment: .leading, spacing: ApricotSpacing.s5) {
                HStack(spacing: ApricotSpacing.s3) {
                    ApricotLogo(size: 36)

                    Text("About Apricot")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.apricotFgPrimary)
                }

                Text(
                    "Apricot displays publicly available Bitcoin blockchain data. Not financial advice. No wallet connection. No private keys."
                )
                .font(.apricotBody)
                .foregroundStyle(Color.apricotFgSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(Color.apricotBorderSubtle)

                if let supportURL {
                    Link(destination: supportURL) {
                        HStack(spacing: ApricotSpacing.s2) {
                            Text("More info")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.apricotAccent)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.apricotAccent)
                            Spacer()
                        }
                    }
                }

                Spacer()
            }
            .padding(ApricotSpacing.s5)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.apricotFgMuted)
                    .padding(7)
                    .background(Color.apricotBgSurface2)
                    .clipShape(Circle())
            }
            .padding(.top, ApricotSpacing.s4)
            .padding(.trailing, ApricotSpacing.s5)
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .presentationBackground(Color.apricotBgPage)
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        DisclaimerSheet()
    }
}
