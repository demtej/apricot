import Foundation
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {
    private let observability: AppObservability
    private let readClipboard: () -> String?
    @Published private(set) var clipboardBitcoinAddress: String?

    init(
        observability: AppObservability = .noop,
        readClipboard: @escaping () -> String? = { UIPasteboard.general.string }
    ) {
        self.observability = observability
        self.readClipboard = readClipboard
    }

    func checkClipboard() {
        guard !FeatureFlagFactory.isRunningTests else { return }
        clipboardBitcoinAddress = readClipboard().flatMap { s in
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            return Self.looksLikeBitcoinAddress(trimmed) ? trimmed : nil
        }
    }

    func submitSearch(query: String) -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    static func looksLikeBitcoinAddress(_ s: String) -> Bool {
        let legacy = #"^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"#
        let bech32 = #"^bc1[ac-hj-np-z02-9]{6,87}$"#
        return s.range(of: legacy, options: .regularExpression) != nil
            || s.range(of: bech32, options: [.regularExpression, .caseInsensitive]) != nil
    }

    func selectRecentSearch(_ item: RecentSearch) -> String {
        observability.analytics.track(.recentSearchSelected(
            addressPreview: ObservabilityPrivacy.addressPreview(item.address)
        ))
        return item.address
    }
}
