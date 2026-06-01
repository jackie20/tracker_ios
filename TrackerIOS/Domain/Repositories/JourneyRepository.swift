import Foundation

protocol JourneyRepository {
    func searchStopPoints(query: String) async -> Result<[StopPoint], Error>
    func planJourney(from: String, to: String) async -> JourneyPlanResult
}
