import Foundation

@MainActor
final class TrackerViewModel: ObservableObject {
    @Published private(set) var uiState: TrackerUiState = .loading

    private let lineId: String
    private let getLiveArrivalsUseCase: GetLiveArrivalsUseCase
    private let getRouteSequenceUseCase: GetRouteSequenceUseCase
    private let positionEngine: VirtualBusPositionEngine

    private var pollingTask: Task<Void, Never>?
    private var cachedStops: [RouteStop] = []

    init(lineId: String, deps: AppDependencies = .shared) {
        self.lineId = lineId
        self.getLiveArrivalsUseCase = deps.getLiveArrivalsUseCase
        self.getRouteSequenceUseCase = deps.getRouteSequenceUseCase
        self.positionEngine = deps.positionEngine
    }

    func onAppear() {
        Task { await loadRouteAndStartPolling() }
    }

    func onDisappear() {
        stopPolling()
    }

    // MARK: - Private

    private func loadRouteAndStartPolling() async {
        uiState = .loading
        let result = await getRouteSequenceUseCase.execute(lineId: lineId)
        switch result {
        case .success(let stops):
            cachedStops = stops
            uiState = .loadingArrivals(stops: stops)
            startPolling()
        case .failure(let error):
            uiState = .error(error.localizedDescription)
        }
    }

    private func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await fetchArrivals()
                try? await Task.sleep(nanoseconds: 30_000_000_000)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchArrivals() async {
        let result = await getLiveArrivalsUseCase.execute(lineId: lineId)
        switch result {
        case .success(let arrivals):
            let filtered = filterToOutbound(arrivals: arrivals)
            let positions = positionEngine.derivePositions(arrivals: filtered, routeStops: cachedStops)
            let sorted = filtered.sorted { $0.timeToStation < $1.timeToStation }
            if sorted.isEmpty {
                uiState = .empty(stops: cachedStops)
            } else {
                uiState = .active(stops: cachedStops, arrivals: sorted, positions: positions)
            }
        case .failure(let error):
            uiState = .error(error.localizedDescription)
        }
    }

    private func filterToOutbound(arrivals: [BusArrival]) -> [BusArrival] {
        let stopIds = Set(cachedStops.map { $0.id })
        return arrivals.filter { stopIds.contains($0.naptanId) }
    }
}
