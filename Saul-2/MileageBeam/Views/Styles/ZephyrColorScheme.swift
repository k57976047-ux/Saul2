import SwiftUI

struct ZephyrColorScheme {
    static let primaryTextZephyr = Color(hex: "#FFFFFF")
    static let titleZephyr = Color(hex: "#FFD93D")
    static let categoryZephyr = Color(hex: "#FFA500")
    static let activeFilterZephyr = Color(hex: "#FFD93D")
    static let selectedFilterZephyr = Color(hex: "#FF3F3F")
    static let buttonZephyr = Color(hex: "#FFD93D")
    static let backgroundDarkZephyr = Color(hex: "#111827")
    static let backgroundLightZephyr = Color(hex: "#4B5563")
    static let secondaryBackgroundZephyr = Color(hex: "#1E293B")
    static let shadowZephyr = Color.black.opacity(0.4)
    
    static var gradientBackgroundZephyr: LinearGradient {
        LinearGradient(
            colors: [backgroundDarkZephyr, backgroundLightZephyr],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



