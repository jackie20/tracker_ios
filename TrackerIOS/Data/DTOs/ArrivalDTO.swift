import Foundation

struct ArrivalDTO: Codable {
    let vehicleId: String?
    let naptanId: String?
    let stationName: String?
    let lineId: String?
    let platformName: String?
    let direction: String?
    let destinationName: String?
    let timeToStation: Int?
    let towards: String?

    enum CodingKeys: String, CodingKey {
        case vehicleId, naptanId, stationName, lineId
        case platformName, direction, destinationName
        case timeToStation, towards
    }
}
