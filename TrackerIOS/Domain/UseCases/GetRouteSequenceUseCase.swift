import Foundation

final class GetRouteSequenceUseCase {
    private let repository: TrackerRepository

    init(repository: TrackerRepository) {
        self.repository = repository
    }

    func execute(lineId: String) async -> Result<[RouteStop], Error> {
        await repository.getRouteSequence(lineId: lineId)
    }
}
