import Foundation

struct JourneyResultDTO: Codable {
    let journeys: [JourneyDTO]?
    let fromLocationDisambiguation: DisambiguationDTO?
    let toLocationDisambiguation: DisambiguationDTO?
}

struct JourneyDTO: Codable {
    let duration: Int?
    let legs: [LegDTO]?
}

struct LegDTO: Codable {
    let duration: Int?
    let instruction: InstructionDTO?
    let departurePoint: PointDTO?
    let arrivalPoint: PointDTO?
    let routeOptions: [RouteOptionDTO]?
    let mode: ModeDTO?
}

struct InstructionDTO: Codable {
    let summary: String?
    let detailed: String?
}

struct PointDTO: Codable {
    let commonName: String?
    let lat: Double?
    let lon: Double?
}

struct ModeDTO: Codable {
    let id: String?
    let name: String?
}

struct RouteOptionDTO: Codable {
    let name: String?
    let lineIdentifier: LineIdentifierDTO?
}

struct LineIdentifierDTO: Codable {
    let id: String?
    let name: String?
}

struct DisambiguationDTO: Codable {
    let disambiguationOptions: [DisambiguationOptionDTO]?
}

struct DisambiguationOptionDTO: Codable {
    let place: DisambiguationPlaceDTO?
    let parameterValue: String?
}

struct DisambiguationPlaceDTO: Codable {
    let commonName: String?
    let placeType: String?
    let lat: Double?
    let lon: Double?
    let id: String?
}
