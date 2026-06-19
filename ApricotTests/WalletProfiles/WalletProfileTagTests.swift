@testable import Apricot
import SwiftData
import XCTest

@MainActor
final class WalletProfileTagTests: XCTestCase {
    private var container: ModelContainer!
    private var store: WalletProfileStore!

    override func setUp() async throws {
        container = try ModelContainer(
            for: WalletProfile.self, Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = WalletProfileStore(context: container.mainContext)
    }

    override func tearDown() async throws {
        container = nil
        store = nil
    }

    // MARK: - createTagIfNeeded

    func test_createTagIfNeeded_trimsWhitespace() {
        let tag = store.createTagIfNeeded(name: "  cold storage  ")
        XCTAssertEqual(tag.name, "COLD STORAGE")
    }

    func test_createTagIfNeeded_uppercases() {
        let tag = store.createTagIfNeeded(name: "dca")
        XCTAssertEqual(tag.name, "DCA")
    }

    func test_createTagIfNeeded_trimsAndUppercasesTogether() {
        let tag = store.createTagIfNeeded(name: "  exchange  ")
        XCTAssertEqual(tag.name, "EXCHANGE")
    }

    func test_createTagIfNeeded_deduplicatesSameName() {
        let t1 = store.createTagIfNeeded(name: "DCA")
        let t2 = store.createTagIfNeeded(name: "DCA")
        XCTAssertTrue(t1 === t2)
    }

    func test_createTagIfNeeded_deduplicatesAfterNormalization() {
        let t1 = store.createTagIfNeeded(name: "  dca  ")
        let t2 = store.createTagIfNeeded(name: "DCA")
        XCTAssertTrue(t1 === t2)
    }

    // MARK: - addTag / removeTag

    func test_addTag_attachesTagToProfile() {
        let profile = store.resolveProfile(for: "addr1", kind: .searched)
        let tag = store.createTagIfNeeded(name: "savings")
        store.addTag(tag, to: "addr1")
        XCTAssertEqual(profile.tags.count, 1)
        XCTAssertEqual(profile.tags.first?.name, "SAVINGS")
    }

    func test_addTag_doesNotDuplicateTag() {
        store.resolveProfile(for: "addr1", kind: .searched)
        let tag = store.createTagIfNeeded(name: "dca")
        store.addTag(tag, to: "addr1")
        store.addTag(tag, to: "addr1")
        XCTAssertEqual(store.profile(for: "addr1")?.tags.count, 1)
    }

    func test_removeTag_detachesTagFromProfile() {
        store.resolveProfile(for: "addr1", kind: .searched)
        let tag = store.createTagIfNeeded(name: "cold storage")
        store.addTag(tag, to: "addr1")
        store.removeTag(tag, from: "addr1")
        XCTAssertEqual(store.profile(for: "addr1")?.tags.count, 0)
    }

    func test_removeTag_doesNotDeleteGlobalTag() {
        store.resolveProfile(for: "addr1", kind: .searched)
        let tag = store.createTagIfNeeded(name: "exchange")
        store.addTag(tag, to: "addr1")
        store.removeTag(tag, from: "addr1")
        XCTAssertEqual(store.allTags().count, 1)
    }

    // MARK: - allTags

    func test_allTags_returnsAllCreatedTags() {
        _ = store.createTagIfNeeded(name: "a")
        _ = store.createTagIfNeeded(name: "b")
        _ = store.createTagIfNeeded(name: "c")
        XCTAssertEqual(store.allTags().count, 3)
    }

    func test_allTags_sharedTagCountsOnce() {
        store.resolveProfile(for: "addr1", kind: .searched)
        store.resolveProfile(for: "addr2", kind: .searched)
        let tag = store.createTagIfNeeded(name: "shared")
        store.addTag(tag, to: "addr1")
        store.addTag(tag, to: "addr2")
        XCTAssertEqual(store.allTags().count, 1)
    }
}
