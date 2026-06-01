import SwiftUI

enum AppTheme {
    enum Colors {
        static let primary = Color(red: 0/255, green: 54/255, blue: 136/255)       // TfL Blue #003688
        static let secondary = Color(red: 255/255, green: 211/255, blue: 41/255)   // TfL Yellow #FFD329
        static let error = Color(red: 225/255, green: 37/255, blue: 27/255)         // TfL Red #E1251B
        static let busStart = Color(red: 0/255, green: 128/255, blue: 0/255)
        static let busEnd = Color(red: 225/255, green: 37/255, blue: 27/255)
        static let busEnRoute = Color(red: 255/255, green: 211/255, blue: 41/255)
        static let routeLine = Color(red: 0/255, green: 54/255, blue: 136/255)
        static let cardBackground = Color(.systemBackground)
        static let surfaceVariant = Color(.secondarySystemBackground)
    }

    enum Fonts {
        static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold) }
        static func semiBold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
        static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
        static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
    }
}
