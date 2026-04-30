import XCTest
@testable import Apricot

final class RecentSearchStoreTests: XCTestCase {

    private var store: RecentSearchStore!
    private var defaults: UserDefaults!

    private let suiteName = "apricot.tests.recentSearches"

    override func setUp() {
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        store = RecentSearchStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Initial state

    func test_initialState_isEmpty() {
        XCTAssertTrue(store.searches.isEmpty)
    }

    // MARK: - Adding

    func test_add_singleAddress_storesIt() {
        store.add(address: "bc1qtest")

        XCTAssertEqual(store.searches.count, 1)
        XCTAssertEqual(store.searches[0].address, "bc1qtest")
    }

    func test_add_multipleDistinctAddresses_storesAll() {
        store.add(address: "bc1qfirst")
        store.add(address: "bc1qsecond")
        store.add(address: "bc1qthird")

        XCTAssertEqual(store.searches.count, 3)
    }

    // MARK: - Ordering

    func test_add_latestAddressIsFirst() {
        store.add(address: "bc1qfirst")
        store.add(address: "bc1qsecond")

        XCTAssertEqual(store.searches[0].address, "bc1qsecond")
        XCTAssertEqual(store.searches[1].address, "bc1qfirst")
    }

    // MARK: - Deduplication

    func test_add_duplicate_movesToTop() {
        store.add(address: "bc1qfirst")
        store.add(address: "bc1qsecond")
        store.add(address: "bc1qfirst") // re-add the first

        XCTAssertEqual(store.searches.count, 2)
        XCTAssertEqual(store.searches[0].address, "bc1qfirst")
        XCTAssertEqual(store.searches[1].address, "bc1qsecond")
    }

    func test_add_duplicate_updatesTimestamp() throws {
        let before = Date()
        store.add(address: "bc1qsame")
        let firstTimestamp = try XCTUnwrap(store.searches.first).searchedAt

        store.add(address: "bc1qsame")
        let secondTimestamp = try XCTUnwrap(store.searches.first).searchedAt

        XCTAssertGreaterThanOrEqual(secondTimestamp, firstTimestamp)
        XCTAssertGreaterThanOrEqual(secondTimestamp, before)
    }

    func test_add_duplicate_onlyOneEntryExists() {
        store.add(address: "bc1qsame")
        store.add(address: "bc1qsame")
        store.add(address: "bc1qsame")

        XCTAssertEqual(store.searches.count, 1)
    }

    // MARK: - Max count

    func test_add_exceedsMaxCount_trimsToFive() {
        for i in 0..<7 {
            store.add(address: "bc1qaddr\(i)")
        }

        XCTAssertEqual(store.searches.count, 5)
    }

    func test_add_exceedsMaxCount_keepsNewest() {
        for i in 0..<7 {
            store.add(address: "bc1qaddr\(i)")
        }

        // The last 5 added are bc1qaddr2…bc1qaddr6, newest first
        XCTAssertEqual(store.searches[0].address, "bc1qaddr6")
        XCTAssertEqual(store.searches[4].address, "bc1qaddr2")
    }

    // MARK: - Persistence

    func test_persistence_survivesStoreRecreation() {
        store.add(address: "bc1qpersisted")
        store.add(address: "bc1qpersisted2")

        let newStore = RecentSearchStore(defaults: defaults)

        XCTAssertEqual(newStore.searches.count, 2)
        XCTAssertEqual(newStore.searches[0].address, "bc1qpersisted2")
        XCTAssertEqual(newStore.searches[1].address, "bc1qpersisted")
    }

    func test_persistence_emptyOnFreshDefaults() {
        let freshDefaults = UserDefaults(suiteName: "apricot.tests.fresh")!
        freshDefaults.removePersistentDomain(forName: "apricot.tests.fresh")
        let freshStore = RecentSearchStore(defaults: freshDefaults)

        XCTAssertTrue(freshStore.searches.isEmpty)

        freshDefaults.removePersistentDomain(forName: "apricot.tests.fresh")
    }

    func test_persistence_maxCountRespectedAfterReload() {
        for i in 0..<7 {
            store.add(address: "bc1qaddr\(i)")
        }

        let reloaded = RecentSearchStore(defaults: defaults)
        XCTAssertEqual(reloaded.searches.count, 5)
    }
}
