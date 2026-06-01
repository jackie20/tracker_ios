import Foundation
import Combine

struct RecentSearch: Identifiable, Equatable {
    let id: UUID
    let from: String
    let to: String

    init(from: String, to: String) {
        self.id = UUID()
        self.from = from
        self.to = to
    }
}

final class HomeViewModel: ObservableObject {
    @Published private(set) var recentSearches: [RecentSearch] = []

    private let maxRecent = 5

    func addRecentSearch(from: String, to: String) {
        recentSearches.removeAll { $0.from == from && $0.to == to }
        recentSearches.insert(RecentSearch(from: from, to: to), at: 0)
        if recentSearches.count > maxRecent {
            recentSearches = Array(recentSearches.prefix(maxRecent))
        }
    }
}
