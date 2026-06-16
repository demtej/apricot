import Foundation

private let kDefaultsKey = "apricot.recentSearches"

/// Protocol allows swapping UserDefaults for a mock in tests.
protocol RecentSearchStoring: AnyObject {
    var searches: [RecentSearch] { get }
    func add(address: String)
}

final class RecentSearchStore: ObservableObject, RecentSearchStoring {
    @Published private(set) var searches: [RecentSearch] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    /// Inserts address at the top. Moves it there if it already exists.
    /// Trims the list to kMaxCount after inserting.
    func add(address: String) {
        var updated = searches.filter { $0.address != address }
        updated.insert(RecentSearch(address: address), at: 0)
        searches = updated
        persist()
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = defaults.data(forKey: kDefaultsKey),
            let decoded = try? JSONDecoder().decode([RecentSearch].self, from: data)
        else { return }
        searches = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(searches) else { return }
        defaults.set(data, forKey: kDefaultsKey)
    }
}
