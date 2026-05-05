@testable import Apricot
import XCTest

final class PostHogAnalyticsTrackerTests: XCTestCase {
    private var captured: [(name: String, properties: [String: Any])] = []
    private var tracker: PostHogAnalyticsTracker?

    override func setUp() {
        super.setUp()
        captured = []
        tracker = PostHogAnalyticsTracker { [weak self] name, props in
            self?.captured.append((name, props))
        }
    }

    func test_track_addressSearchStarted() {
        tracker?.track(.addressSearchStarted(addressPreview: "bc1qtest…"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "address_search_started")
        XCTAssertEqual(captured[0].properties["address_preview"] as? String, "bc1qtest…")
    }

    func test_track_addressSearchSucceeded() {
        tracker?.track(.addressSearchSucceeded(addressPreview: "bc1qtest…", resultCount: 3, durationMs: 120))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "address_search_succeeded")
        XCTAssertEqual(captured[0].properties["address_preview"] as? String, "bc1qtest…")
        XCTAssertEqual(captured[0].properties["result_count"] as? Int, 3)
        XCTAssertEqual(captured[0].properties["duration_ms"] as? Int, 120)
    }

    func test_track_addressSearchFailed() {
        tracker?.track(.addressSearchFailed(addressPreview: "bc1qtest…", errorCategory: "network", durationMs: 50))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "address_search_failed")
        XCTAssertEqual(captured[0].properties["address_preview"] as? String, "bc1qtest…")
        XCTAssertEqual(captured[0].properties["error_category"] as? String, "network")
        XCTAssertEqual(captured[0].properties["duration_ms"] as? Int, 50)
    }

    func test_track_transactionOpened() {
        tracker?.track(.transactionOpened(txIdPreview: "abc123de…6789", addressPreview: "bc1qtest…"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "transaction_opened")
        XCTAssertEqual(captured[0].properties["tx_id_preview"] as? String, "abc123de…6789")
        XCTAssertEqual(captured[0].properties["address_preview"] as? String, "bc1qtest…")
    }

    func test_track_transactionDetailLoaded() {
        tracker?.track(.transactionDetailLoaded(txIdPreview: "abc123de…6789", durationMs: 200))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "transaction_detail_loaded")
        XCTAssertEqual(captured[0].properties["tx_id_preview"] as? String, "abc123de…6789")
        XCTAssertEqual(captured[0].properties["duration_ms"] as? Int, 200)
    }

    func test_track_transactionDetailFailed() {
        tracker?.track(.transactionDetailFailed(
            txIdPreview: "abc123de…6789",
            errorCategory: "not_found",
            durationMs: 30
        ))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "transaction_detail_failed")
        XCTAssertEqual(captured[0].properties["tx_id_preview"] as? String, "abc123de…6789")
        XCTAssertEqual(captured[0].properties["error_category"] as? String, "not_found")
        XCTAssertEqual(captured[0].properties["duration_ms"] as? Int, 30)
    }

    func test_track_transactionGraphViewed() {
        tracker?.track(.transactionGraphViewed(txIdPreview: "abc123de…6789"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "transaction_graph_viewed")
        XCTAssertEqual(captured[0].properties["tx_id_preview"] as? String, "abc123de…6789")
    }

    func test_track_recentSearchSelected() {
        tracker?.track(.recentSearchSelected(addressPreview: "bc1qtest…"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "recent_search_selected")
        XCTAssertEqual(captured[0].properties["address_preview"] as? String, "bc1qtest…")
    }

    func test_track_cacheHit() {
        tracker?.track(.cacheHit(resource: .addressSummary, keyPreview: "bc1qtest…"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "cache_hit")
        XCTAssertEqual(captured[0].properties["resource"] as? String, "address_summary")
        XCTAssertEqual(captured[0].properties["key_preview"] as? String, "bc1qtest…")
    }

    func test_track_cacheMiss() {
        tracker?.track(.cacheMiss(resource: .transactionDetail, keyPreview: "abc123de…6789"))

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].name, "cache_miss")
        XCTAssertEqual(captured[0].properties["resource"] as? String, "transaction_detail")
        XCTAssertEqual(captured[0].properties["key_preview"] as? String, "abc123de…6789")
    }

    func test_track_multipleEvents_capturesAll() {
        tracker?.track(.addressSearchStarted(addressPreview: "bc1qtest…"))
        tracker?.track(.addressSearchSucceeded(addressPreview: "bc1qtest…", resultCount: 1, durationMs: 100))

        XCTAssertEqual(captured.count, 2)
        XCTAssertEqual(captured[0].name, "address_search_started")
        XCTAssertEqual(captured[1].name, "address_search_succeeded")
    }
}
