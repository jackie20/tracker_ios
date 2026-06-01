import Foundation

struct BusArrival: Identifiable, Equatable {
    let id: String
    let vehicleId: String
    let naptanId: String
    let stationName: String
    let lineId: String
    let timeToStation: Int
    let towards: String
    let direction: String

    init(vehicleId: String, naptanId: String, stationName: String,
         lineId: String, timeToStation: Int, towards: String, direction: String) {
        self.id = vehicleId + naptanId
        self.vehicleId = vehicleId
        self.naptanId = naptanId
        self.stationName = stationName
        self.lineId = lineId
        self.timeToStation = timeToStation
        self.towards = towards
        self.direction = direction
    }
}
