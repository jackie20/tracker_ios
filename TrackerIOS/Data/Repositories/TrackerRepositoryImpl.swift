import Foundation

final class TrackerRepositoryImpl: TrackerRepository {
    private let apiService: TflAPIService
    private let arrivalMapper: ArrivalMapper
    private let routeSequenceMapper: RouteSequenceMapper

    init(apiService: TflAPIService, arrivalMapper: ArrivalMapper, routeSequenceMapper: RouteSequenceMapper) {
        self.apiService = apiService
        self.arrivalMapper = arrivalMapper
        self.routeSequenceMapper = routeSequenceMapper
    }

    func getLiveArrivals(lineId: String) async -> Result<[BusArrival], Error> {
        do {
            let dtos = try await apiService.getArrivals(lineId: lineId)
            return .success(arrivalMapper.mapList(dtos: dtos))
        } catch {
            return .failure(error)
        }
    }

    func getRouteSequence(lineId: String) async -> Result<[RouteStop], Error> {
        do {
            let dto = try await apiService.getRouteSequence(lineId: lineId)
            return .success(routeSequenceMapper.map(dto: dto))
        } catch {
            return .failure(error)
        }
    }
}
