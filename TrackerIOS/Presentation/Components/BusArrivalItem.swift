import SwiftUI

struct BusArrivalItem: View {
    let arrival: BusArrival

    private var minutesText: String {
        let mins = arrival.timeToStation / 60
        return mins <= 0 ? "Due" : "\(mins) min\(mins == 1 ? "" : "s")"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(arrival.stationName)
                    .font(AppTheme.Fonts.semiBold(14))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("→ \(arrival.towards.isEmpty ? arrival.direction : arrival.towards)")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text("Vehicle \(arrival.vehicleId)")
                    .font(AppTheme.Fonts.regular(11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(minutesText)
                .font(AppTheme.Fonts.bold(14))
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.Colors.secondary)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}
