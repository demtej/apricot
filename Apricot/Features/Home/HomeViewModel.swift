import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let observability: AppObservability

    init(observability: AppObservability = .noop) {
        self.observability = observability
    }

    func submitSearch(query: String) -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    func selectRecentSearch(_ item: RecentSearch) -> String {
        observability.analytics.track(.recentSearchSelected(
            addressPreview: ObservabilityPrivacy.addressPreview(item.address)
        ))
        return item.address
    }
}
