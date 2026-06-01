import Foundation

final class PlanJourneyUseCase {
    private let repository: JourneyRepository

    init(repository: JourneyRepository) {
        self.repository = repository
    }

    func execute(from: String, to: String) async -> JourneyPlanResult {
        let trimFrom = from.trimmingCharacters(in: .whitespaces)
        let trimTo = to.trimmingCharacters(in: .whitespaces)
        guard !trimFrom.isEmpty, !trimTo.isEmpty else {
            return .error("Please enter both a start and end location.")
        }
        return await repository.planJourney(from: trimFrom, to: trimTo)
    }
}
