import Foundation

struct DisambiguationState {
    enum Field { case from, to }
    let field: Field
    let query: String
    let options: [StopPoint]
}

struct SearchUiState {
    var fromQuery: String = ""
    var toQuery: String = ""
    var resolvedFromId: String? = nil
    var resolvedToId: String? = nil
    var isLoading: Bool = false
    var error: String? = nil
    var disambiguation: DisambiguationState? = nil
    var journeyResults: [Journey]? = nil
    var fromSuggestions: [StopPoint] = []
    var toSuggestions: [StopPoint] = []
}
