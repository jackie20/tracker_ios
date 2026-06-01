import Foundation

protocol TrackerRepository {
    func getLiveArrivals(lineId: String) async -> Result<[BusArrival], Error>
    func getRouteSequence(lineId: String) async -> Result<[RouteStop], Error>
}
