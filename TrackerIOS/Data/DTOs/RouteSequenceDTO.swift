import Foundation

struct RouteSequenceDTO: Codable {
    let lineId: String?
    let direction: String?
    let stopPointSequences: [StopPointSequenceDTO]?
}

struct StopPointSequenceDTO: Codable {
    let branchId: Int?
    let direction: String?
    let stopPoint: [RouteStopDTO]?
}

struct RouteStopDTO: Codable {
    let id: String?
    let name: String?
    let lat: Double?
    let lon: Double?
    let sequenceNumber: Int?
}
