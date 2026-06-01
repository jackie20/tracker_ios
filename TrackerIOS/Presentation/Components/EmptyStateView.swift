import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            Text(title)
                .font(AppTheme.Fonts.semiBold(18))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
