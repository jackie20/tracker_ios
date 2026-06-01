import Foundation

enum TrackerUiState {
    case loading
    case loadingArrivals(stops: [RouteStop])
    case active(stops: [RouteStop], arrivals: [BusArrival], positions: [BusPosition])
    case empty(stops: [RouteStop])
    case error(String)
}
