import Foundation

final class JourneyRepositoryImpl: JourneyRepository {
    private let apiService: TflAPIService
    private let journeyMapper: JourneyMapper
    private let stopPointMapper: StopPointMapper

    init(apiService: TflAPIService, journeyMapper: JourneyMapper, stopPointMapper: StopPointMapper) {
        self.apiService = apiService
        self.journeyMapper = journeyMapper
        self.stopPointMapper = stopPointMapper
    }

    func searchStopPoints(query: String) async -> Result<[StopPoint], Error> {
        do {
            let dto = try await apiService.searchStopPoints(query: query)
            let stops = stopPointMapper.mapList(dtos: dto.matches ?? [])
            return .success(stops)
        } catch {
            return .failure(error)
        }
    }

    func planJourney(from: String, to: String) async -> JourneyPlanResult {
        do {
            let (statusCode, dto) = try await apiService.planJourney(from: from, to: to)

            if statusCode == 300 {
                return resolveDisambiguation(from: from, to: to, dto: dto)
            }

            if let journeyDTOs = dto.journeys, !journeyDTOs.isEmpty {
                let journeys = journeyMapper.mapList(dtos: journeyDTOs)
                if journeys.isEmpty {
                    return .noResults("No bus routes found for this journey.")
                }
                return .journeys(journeys)
            }

            // No journeys but status 200 — check disambiguation
            if dto.fromLocationDisambiguation != nil || dto.toLocationDisambiguation != nil {
                return resolveDisambiguation(from: from, to: to, dto: dto)
            }

            return .noResults("No routes found for this journey.")
        } catch {
            return .error(error.localizedDescription)
        }
    }

    private func resolveDisambiguation(from: String, to: String, dto: JourneyResultDTO) -> JourneyPlanResult {
        if let fromDisamb = dto.fromLocationDisambiguation,
           let options = fromDisamb.disambiguationOptions, !options.isEmpty {
            let stops = stopPointMapper.mapDisambiguationOptions(dtos: options)
            if !stops.isEmpty {
                return .fromDisambiguation(query: from, options: stops)
            }
        }
        if let toDisamb = dto.toLocationDisambiguation,
           let options = toDisamb.disambiguationOptions, !options.isEmpty {
            let stops = stopPointMapper.mapDisambiguationOptions(dtos: options)
            if !stops.isEmpty {
                return .toDisambiguation(query: to, options: stops)
            }
        }
        return .noResults("Location could not be resolved.")
    }
}
