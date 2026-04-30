@testable import Apricot
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
    func test_submitSearch_trimsWhitespace() {
        let viewModel = HomeViewModel()

        XCTAssertEqual(viewModel.submitSearch(query: "  bc1qtest  "), "bc1qtest")
    }

    func test_submitSearch_withOnlyWhitespace_returnsNil() {
        let viewModel = HomeViewModel()

        XCTAssertNil(viewModel.submitSearch(query: "   "))
    }

    func test_selectRecentSearch_tracksRecentSelection() {
        let analytics = TestAnalyticsTracker()
        let viewModel = HomeViewModel(
            observability: AppObservability(
                analytics: analytics,
                logger: TestLogger()
            )
        )
        let item = RecentSearch(
            address: "bc1qrecentsearch12345",
            searchedAt: Date(timeIntervalSince1970: 0)
        )

        let selected = viewModel.selectRecentSearch(item)

        XCTAssertEqual(selected, item.address)
        XCTAssertEqual(analytics.events, [
            .recentSearchSelected(addressPreview: "bc1qrecent…")
        ])
    }
}
