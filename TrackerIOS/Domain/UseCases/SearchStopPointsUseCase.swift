import Foundation

final class SearchStopPointsUseCase {
    private let repository: JourneyRepository

    init(repository: JourneyRepository) {
        self.repository = repository
    }

    func execute(query: String) async -> Result<[StopPoint], Error> {
        guard query.count >= 2 else { return .success([]) }
        return await repository.searchStopPoints(query: query.trimmingCharacters(in: .whitespaces))
    }
}
