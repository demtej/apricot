import SwiftUI
import SwiftData

struct WalletFilterSection: View {
    let profiles: [WalletProfile]
    let onSelect: (WalletProfile) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
            Text("WALLETS")
                .font(.apricotLabel)
                .tracking(.apricotTrackingWide)
                .foregroundStyle(Color.apricotFgSecondary)
                .padding(.horizontal, ApricotSpacing.s5)

            VStack(spacing: 8) {
                if profiles.isEmpty {
                    WalletFilterEmptyState()
                } else {
                    ForEach(profiles) { profile in
                        WalletFilterRow(profile: profile) {
                            onSelect(profile)
                        }
                    }
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
        }
    }
}

private struct WalletFilterRow: View {
    let profile: WalletProfile
    let onTap: () -> Void

    @EnvironmentObject private var profileStore: WalletProfileStore

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(profile.color.color)
                        .frame(width: 32, height: 32)
                    Text(profileStore.displayBadge(for: profile.address))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.label)
                        .font(.apricotBodyStrong)
                        .foregroundStyle(Color.apricotFgPrimary)
                        .lineLimit(1)
                    Text(profile.address)
                        .apricotMono(.small)
                        .foregroundStyle(Color.apricotFgSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer()

                if !profile.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(profile.tags.prefix(2), id: \.name) { tag in
                            Text(tag.name)
                                .font(.apricotCaption)
                                .foregroundStyle(Color.apricotFgMuted)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.apricotBgSurface2)
                                .clipShape(Capsule())
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.apricotFgMuted)
            }
            .padding(14)
            .background(Color.apricotBgElevated)
            .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ApricotRadius.md)
                    .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct WalletFilterEmptyState: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.apricotBgSurface2)
                    .frame(width: 32, height: 32)
                Image(systemName: "wallet.bifold")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.apricotFgMuted)
            }
            Text("No wallets match your search")
                .font(.apricotCaption)
                .foregroundStyle(Color.apricotFgMuted)
            Spacer()
        }
        .padding(14)
        .background(Color.apricotBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.md)
                .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
        )
    }
}
