import SwiftUI

struct JourneyResultsView: View {
    let journeys: [Journey]
    let fromQuery: String
    let toQuery: String
    let onSelectLeg: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(journeys) { journey in
                    JourneyLegCard(journey: journey) { leg in
                        onSelectLeg(leg.lineId)
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.Colors.surfaceVariant)
        .navigationTitle("Journey Options")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
