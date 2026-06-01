import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .httpError(let code): return "Server error (HTTP \(code))."
        case .decodingError: return "Failed to parse server response."
        case .networkError(let err): return err.localizedDescription
        case .unknown: return "An unknown error occurred."
        }
    }
}
