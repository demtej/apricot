import SwiftUI

struct RecentSearchesSection: View {
    let searches: [RecentSearch]
    let onSelect: (RecentSearch) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
            Text("RECENT")
                .font(.apricotLabel)
                .tracking(.apricotTrackingWide)
                .foregroundStyle(Color.apricotFgSecondary)
                .padding(.horizontal, ApricotSpacing.s5)

            VStack(spacing: 8) {
                if searches.isEmpty {
                    RecentSearchEmptyState()
                } else {
                    ForEach(searches) { item in
                        RecentSearchRow(item: item) {
                            onSelect(item)
                        }
                    }
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
        }
    }
}

private struct RecentSearchRow: View {
    let item: RecentSearch
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.apricotAccentSoft)
                        .frame(width: 32, height: 32)
                    Text("bc")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.Apricot.scale700)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.address)
                        .apricotMono(.small)
                        .foregroundStyle(Color.apricotFgPrimary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(item.displayDate)
                        .font(.apricotLabel)
                        .foregroundStyle(Color.apricotFgSecondary)
                }

                Spacer()

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

private struct RecentSearchEmptyState: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.apricotBgSurface2)
                    .frame(width: 32, height: 32)
                Image(systemName: "clock")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.apricotFgMuted)
            }
            Text("No recent searches yet")
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

#Preview("Empty") {
    ZStack {
        Color.apricotBgPage.ignoresSafeArea()
        RecentSearchesSection(searches: [], onSelect: { _ in })
    }
}

#Preview("With recent searches") {
    let searches = [
        RecentSearch(address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh", searchedAt: Date()),
        RecentSearch(address: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy", searchedAt: Date().addingTimeInterval(-3600)),
        RecentSearch(address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", searchedAt: Date().addingTimeInterval(-86400))
    ]

    ZStack {
        Color.apricotBgPage.ignoresSafeArea()
        RecentSearchesSection(searches: searches, onSelect: { _ in })
    }
}
