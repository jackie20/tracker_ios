import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var state = SearchUiState()

    private let searchUseCase: SearchStopPointsUseCase
    private let planJourneyUseCase: PlanJourneyUseCase
    private var fromSuggestTask: Task<Void, Never>?
    private var toSuggestTask: Task<Void, Never>?

    init(deps: AppDependencies = .shared) {
        self.searchUseCase = deps.searchStopPointsUseCase
        self.planJourneyUseCase = deps.planJourneyUseCase
    }

    // MARK: - Input

    func updateFromQuery(_ query: String) {
        state.fromQuery = query
        state.resolvedFromId = nil
        fromSuggestTask?.cancel()
        guard query.count >= 2 else {
            state.fromSuggestions = []
            return
        }
        fromSuggestTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            let result = await searchUseCase.execute(query: query)
            if case .success(let stops) = result {
                state.fromSuggestions = Array(stops.prefix(5))
            }
        }
    }

    func updateToQuery(_ query: String) {
        state.toQuery = query
        state.resolvedToId = nil
        toSuggestTask?.cancel()
        guard query.count >= 2 else {
            state.toSuggestions = []
            return
        }
        toSuggestTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            let result = await searchUseCase.execute(query: query)
            if case .success(let stops) = result {
                state.toSuggestions = Array(stops.prefix(5))
            }
        }
    }

    func selectFromSuggestion(_ stop: StopPoint) {
        state.fromQuery = stop.name
        state.resolvedFromId = stop.id
        state.fromSuggestions = []
        fromSuggestTask?.cancel()
    }

    func selectToSuggestion(_ stop: StopPoint) {
        state.toQuery = stop.name
        state.resolvedToId = stop.id
        state.toSuggestions = []
        toSuggestTask?.cancel()
    }

    func planJourney() {
        let from = state.resolvedFromId ?? state.fromQuery
        let to = state.resolvedToId ?? state.toQuery
        state.isLoading = true
        state.error = nil
        state.journeyResults = nil
        Task {
            let result = await planJourneyUseCase.execute(from: from, to: to)
            handlePlanResult(result)
        }
    }

    func selectDisambiguationOption(_ stop: StopPoint) {
        guard let disambiguation = state.disambiguation else { return }
        state.disambiguation = nil
        switch disambiguation.field {
        case .from:
            state.fromQuery = stop.name
            state.resolvedFromId = stop.id
        case .to:
            state.toQuery = stop.name
            state.resolvedToId = stop.id
        }
        planJourney()
    }

    func dismissDisambiguation() {
        state.disambiguation = nil
        state.isLoading = false
    }

    func clearResults() {
        state.journeyResults = nil
        state.error = nil
    }

    // MARK: - Private

    private func handlePlanResult(_ result: JourneyPlanResult) {
        state.isLoading = false
        switch result {
        case .journeys(let journeys):
            state.journeyResults = journeys
        case .noResults(let message):
            state.error = message
        case .fromDisambiguation(let query, let options):
            state.disambiguation = DisambiguationState(field: .from, query: query, options: options)
        case .toDisambiguation(let query, let options):
            state.disambiguation = DisambiguationState(field: .to, query: query, options: options)
        case .error(let message):
            state.error = message
        }
    }
}
