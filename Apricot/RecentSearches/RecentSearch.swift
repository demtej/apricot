import Foundation

struct RecentSearch: Codable, Identifiable, Equatable {
    let id: UUID
    let address: String
    let searchedAt: Date

    init(address: String, searchedAt: Date = Date()) {
        self.id = UUID()
        self.address = address
        self.searchedAt = searchedAt
    }

    var displayDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(searchedAt) {
            return "Today"
        } else if calendar.isDateInYesterday(searchedAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: searchedAt)
        }
    }
}
