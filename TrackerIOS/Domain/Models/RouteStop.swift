import Foundation

struct RouteStop: Identifiable, Equatable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let sequenceNumber: Int
}
