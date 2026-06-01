import Foundation

enum JourneyPlanResult {
    case journeys([Journey])
    case noResults(String)
    case fromDisambiguation(query: String, options: [StopPoint])
    case toDisambiguation(query: String, options: [StopPoint])
    case error(String)
}
