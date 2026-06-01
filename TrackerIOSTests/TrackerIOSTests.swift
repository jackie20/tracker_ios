import XCTest
@testable import TrackerIOS

final class TrackerIOSTests: XCTestCase {
    func testSearchStopPointsUseCaseSkipsShortQuery() async {
        let repo = MockJourneyRepository()
        let useCase = SearchStopPointsUseCase(repository: repo)
        let result = await useCase.execute(query: "a")
        if case .success(let stops) = result {
            XCTAssertTrue(stops.isEmpty)
        } else {
            XCTFail("Expected success")
        }
    }
}

private class MockJourneyRepository: JourneyRepository {
    func searchStopPoints(query: String) async -> Result<[StopPoint], Error> { .success([]) }
    func planJourney(from: String, to: String) async -> JourneyPlanResult { .noResults("mock") }
}
