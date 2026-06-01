import SwiftUI

struct TrackerView: View {
    let lineId: String
    @StateObject private var viewModel: TrackerViewModel

    init(lineId: String) {
        self.lineId = lineId
        self._viewModel = StateObject(wrappedValue: TrackerViewModel(lineId: lineId))
    }

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                loadingView(message: "Loading route…")

            case .loadingArrivals(let stops):
                trackerContent(stops: stops, arrivals: [], positions: [], isLoadingArrivals: true)

            case .active(let stops, let arrivals, let positions):
                trackerContent(stops: stops, arrivals: arrivals, positions: positions, isLoadingArrivals: false)

            case .empty(let stops):
                trackerContent(stops: stops, arrivals: [], positions: [], isLoadingArrivals: false)

            case .error(let message):
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Error",
                    subtitle: message
                )
            }
        }
        .navigationTitle("Line \(lineId.uppercased())")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    private func trackerContent(
        stops: [RouteStop],
        arrivals: [BusArrival],
        positions: [BusPosition],
        isLoadingArrivals: Bool
    ) -> some View {
        VStack(spacing: 0) {
            BusTrackerMapView(stops: stops, positions: positions)
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.55)

            Divider()

            if isLoadingArrivals {
                loadingView(message: "Loading arrivals…")
                    .frame(maxHeight: .infinity)
            } else if arrivals.isEmpty {
                EmptyStateView(
                    icon: "bus",
                    title: "No buses tracked",
                    subtitle: "No buses are currently tracked on this route."
                )
                .frame(maxHeight: .infinity)
            } else {
                List(arrivals) { arrival in
                    BusArrivalItem(arrival: arrival)
                        .listRowBackground(Color(.systemBackground))
                }
                .listStyle(.plain)
            }
        }
    }

    private func loadingView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(AppTheme.Colors.primary)
            Text(message)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
