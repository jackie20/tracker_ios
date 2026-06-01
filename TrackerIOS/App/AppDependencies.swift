import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    private init() {}

    private(set) lazy var apiService = TflAPIService()

    private(set) lazy var arrivalMapper = ArrivalMapper()
    private(set) lazy var journeyMapper = JourneyMapper()
    private(set) lazy var routeSequenceMapper = RouteSequenceMapper()
    private(set) lazy var stopPointMapper = StopPointMapper()

    private(set) lazy var journeyRepository: JourneyRepository = JourneyRepositoryImpl(
        apiService: apiService,
        journeyMapper: journeyMapper,
        stopPointMapper: stopPointMapper
    )

    private(set) lazy var trackerRepository: TrackerRepository = TrackerRepositoryImpl(
        apiService: apiService,
        arrivalMapper: arrivalMapper,
        routeSequenceMapper: routeSequenceMapper
    )

    private(set) lazy var searchStopPointsUseCase = SearchStopPointsUseCase(repository: journeyRepository)
    private(set) lazy var planJourneyUseCase = PlanJourneyUseCase(repository: journeyRepository)
    private(set) lazy var getLiveArrivalsUseCase = GetLiveArrivalsUseCase(repository: trackerRepository)
    private(set) lazy var getRouteSequenceUseCase = GetRouteSequenceUseCase(repository: trackerRepository)

    private(set) lazy var positionEngine = VirtualBusPositionEngine()
}
