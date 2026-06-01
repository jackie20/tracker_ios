import Foundation

final class GetLiveArrivalsUseCase {
    private let repository: TrackerRepository

    init(repository: TrackerRepository) {
        self.repository = repository
    }

    func execute(lineId: String) async -> Result<[BusArrival], Error> {
        await repository.getLiveArrivals(lineId: lineId)
    }
}
