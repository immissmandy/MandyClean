import SwiftUI

enum NeoThemePreset: String, CaseIterable, Identifiable {
    case cyberLime = "Cyber Lime & Dark"
    case neonMagenta = "Neon Magenta & Paper"
    case electricCyan = "Electric Cyan & Midnight"
    case retroMonochrome = "Retro Monochrome"

    var id: String { rawValue }

    var primaryAccent: Color {
        switch self {
        case .cyberLime: return .neoLime
        case .neonMagenta: return .neoPink
        case .electricCyan: return .neoCyan
        case .retroMonochrome: return .white
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .cyberLime: return .neoYellow
        case .neonMagenta: return .neoCyan
        case .electricCyan: return .neoPink
        case .retroMonochrome: return Color(white: 0.8)
        }
    }
}
