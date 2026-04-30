import SwiftUI

struct HomeView: View {
    private let makeAddressSearchViewModel: (RecentSearchStoring?) -> AddressSearchViewModel

    @State private var searchQuery = ""
    @State private var searchedAddress: String? = nil
    @EnvironmentObject private var recentSearchStore: RecentSearchStore

    init(makeAddressSearchViewModel: @escaping (RecentSearchStoring?) -> AddressSearchViewModel) {
        self.makeAddressSearchViewModel = makeAddressSearchViewModel
    }

    var body: some View {
        ZStack {
            Color.apricotBgPage.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brandHeader
                    heroSection
                    searchSection
                    recentSection
                }
            }
        }
        .navigationDestination(item: $searchedAddress) { address in
            AddressView(
                address: address,
                viewModel: makeAddressSearchViewModel(recentSearchStore)
            )
        }
    }

    // MARK: - Sections

    private var brandHeader: some View {
        HStack(spacing: 10) {
            ApricotLogo(size: 32)
            Text("Apricot")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.apricotFgPrimary)
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.vertical, ApricotSpacing.s3)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            Text("Look up a wallet\nor transaction")
                .font(.apricotH1)
                .tracking(-0.68)
                .foregroundStyle(Color.apricotFgPrimary)

            Text("Paste a Bitcoin address or transaction ID.\nWe'll explain what we find.")
                .font(.apricotCaption)
                .foregroundStyle(Color.apricotFgSecondary)
                .lineSpacing(3)
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.top, ApricotSpacing.s4)
        .padding(.bottom, ApricotSpacing.s4)
    }

    private var searchSection: some View {
        ApricotSearchField(
            text: $searchQuery,
            onSubmit: {
                let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                searchedAddress = trimmed
            }
        )
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.bottom, ApricotSpacing.s6)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
            Text("RECENT")
                .font(.apricotLabel)
                .tracking(.apricotTrackingWide)
                .foregroundStyle(Color.apricotFgSecondary)
                .padding(.horizontal, ApricotSpacing.s5)

            VStack(spacing: 8) {
                if recentSearchStore.searches.isEmpty {
                    recentEmptyState
                } else {
                    ForEach(recentSearchStore.searches) { item in
                        recentRow(item)
                    }
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
        }
    }

    // MARK: - Recent row

    private func recentRow(_ item: RecentSearch) -> some View {
        Button {
            searchedAddress = item.address
        } label: {
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

    // MARK: - Empty state

    private var recentEmptyState: some View {
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

#Preview {
    let store = RecentSearchStore()
    return NavigationStack {
        HomeView {
            AddressSearchViewModel(
                featureFlags: LocalFeatureFlags(addressInsightsEnabled: false),
                recentSearchStore: $0
            )
        }
    }
    .environmentObject(store)
}
