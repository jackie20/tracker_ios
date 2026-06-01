import SwiftUI

struct AppRootView: View {
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            HomeView(viewModel: homeViewModel)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .search:
                        SearchView(
                            onAddRecentSearch: { from, to in
                                homeViewModel.addRecentSearch(from: from, to: to)
                            }
                        )
                    case .tracker(let lineId):
                        TrackerView(lineId: lineId)
                    }
                }
        }
        .tint(AppTheme.Colors.primary)
    }
}

enum AppRoute: Hashable {
    case search
    case tracker(lineId: String)
}
