import Foundation

struct StopPoint: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
}
