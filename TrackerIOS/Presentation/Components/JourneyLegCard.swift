import SwiftUI

struct JourneyLegCard: View {
    let journey: Journey
    let onTrackLeg: (JourneyLeg) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(AppTheme.Colors.primary)
                Text("\(journey.duration) min total")
                    .font(AppTheme.Fonts.semiBold(15))
                    .foregroundColor(.primary)
                Spacer()
            }

            if !journey.legs.isEmpty {
                Divider()

                ForEach(Array(journey.legs.enumerated()), id: \.element.id) { index, leg in
                    if index > 0 { Divider() }
                    legRow(leg: leg, onTrack: { onTrackLeg(leg) })
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func legRow(leg: JourneyLeg, onTrack: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(leg.lineName.isEmpty ? leg.lineId.uppercased() : leg.lineName.uppercased())
                .font(AppTheme.Fonts.bold(13))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.primary)
                .cornerRadius(6)
                .fixedSize()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(leg.fromName)
                        .font(AppTheme.Fonts.medium(13))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(leg.toName)
                        .font(AppTheme.Fonts.medium(13))
                }
                .foregroundColor(.primary)
                Text("\(leg.duration) min")
                    .font(AppTheme.Fonts.regular(12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Use a plain Button + callback instead of NavigationLink(value:).
            // NavigationLink(value:) cannot reliably reach a navigationDestination(for:)
            // declared on a view higher up in the hierarchy when this card lives inside
            // a view pushed via navigationDestination(isPresented:) — an iOS 16 limitation.
            Button {
                onTrack()
            } label: {
                Text("Track")
                    .font(AppTheme.Fonts.semiBold(13))
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.primary, lineWidth: 1.5)
                    )
            }
        }
    }
}
