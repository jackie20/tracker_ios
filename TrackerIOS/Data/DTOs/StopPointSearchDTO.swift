import Foundation

struct StopPointSearchResponseDTO: Codable {
    let matches: [StopPointMatchDTO]?
    let total: Int?
}

struct StopPointMatchDTO: Codable {
    let id: String
    let name: String
    let lat: Double?
    let lon: Double?
}
