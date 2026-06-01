import Foundation

final class TflAPIService {
    private let baseURL = "https://api.tfl.gov.uk"
    private let session: URLSession
    private let decoder = JSONDecoder()

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func searchStopPoints(query: String) async throws -> StopPointSearchResponseDTO {
        let url = try buildURL(path: "StopPoint/Search/\(query)", queryItems: [
            URLQueryItem(name: "modes", value: "bus")
        ])
        let (data, _) = try await fetch(url: url)
        return try decode(StopPointSearchResponseDTO.self, from: data)
    }

    func planJourney(from: String, to: String) async throws -> (statusCode: Int, dto: JourneyResultDTO) {
        let path = "Journey/JourneyResults/\(from)/to/\(to)"
        let url = try buildURL(path: path, queryItems: [
            URLQueryItem(name: "mode", value: "bus")
        ])
        let (data, response) = try await fetch(url: url)
        let statusCode = (response as! HTTPURLResponse).statusCode
        let dto = try decode(JourneyResultDTO.self, from: data)
        return (statusCode, dto)
    }

    func getArrivals(lineId: String) async throws -> [ArrivalDTO] {
        let url = try buildURL(path: "Line/\(lineId)/Arrivals", queryItems: [])
        let (data, _) = try await fetch(url: url)
        return try decode([ArrivalDTO].self, from: data)
    }

    func getRouteSequence(lineId: String) async throws -> RouteSequenceDTO {
        let url = try buildURL(path: "Line/\(lineId)/Route/Sequence/outbound", queryItems: [])
        let (data, _) = try await fetch(url: url)
        return try decode(RouteSequenceDTO.self, from: data)
    }

    // MARK: - Private helpers

    private func buildURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/\(path)") else {
            throw APIError.invalidURL
        }
        var items = queryItems
        let apiKey = Config.tflApiKey
        if !apiKey.isEmpty {
            items.append(URLQueryItem(name: "app_key", value: apiKey))
        }
        components.queryItems = items
        guard let url = components.url else { throw APIError.invalidURL }
        return url
    }

    private func fetch(url: URL) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await session.data(from: url)
            let code = (response as! HTTPURLResponse).statusCode
            // Allow 200 (success) and 300 (disambiguation) through
            guard code == 200 || code == 300 else {
                throw APIError.httpError(code)
            }
            return (data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
