import Foundation

struct BusPosition: Identifiable, Equatable {
    let id: String
    let vehicleId: String
    let lat: Double
    let lon: Double
    let timeToStation: Int
    let nextStopName: String
    let nextNaptanId: String

    init(vehicleId: String, lat: Double, lon: Double,
         timeToStation: Int, nextStopName: String, nextNaptanId: String) {
        self.id = vehicleId
        self.vehicleId = vehicleId
        self.lat = lat
        self.lon = lon
        self.timeToStation = timeToStation
        self.nextStopName = nextStopName
        self.nextNaptanId = nextNaptanId
    }
}
