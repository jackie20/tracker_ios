import SwiftUI
import MapKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            MapBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    searchBarButton

                    if !viewModel.recentSearches.isEmpty {
                        recentSearchesList
                    }
                }
                .background(Color(.systemBackground).opacity(0.95))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("London Bus Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("London Bus Tracker")
                    .font(AppTheme.Fonts.bold(17))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(AppTheme.Colors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var searchBarButton: some View {
        NavigationLink(value: AppRoute.search) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                Text("Where to?")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.surfaceVariant)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var recentSearchesList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent searches")
                .font(AppTheme.Fonts.semiBold(13))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)

            ForEach(viewModel.recentSearches) { recent in
                NavigationLink(value: AppRoute.search) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recent.from)
                                .font(AppTheme.Fonts.medium(14))
                                .foregroundColor(.primary)
                            Text("→ \(recent.to)")
                                .font(AppTheme.Fonts.regular(13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
            Divider().padding(.bottom, 8)
        }
    }
}

private struct MapBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        mapView.showsUserLocation = false
        mapView.mapType = .standard
        let london = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        let region = MKCoordinateRegion(center: london,
                                        latitudinalMeters: 15000,
                                        longitudinalMeters: 15000)
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
