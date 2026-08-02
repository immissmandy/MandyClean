import SwiftUI

// MARK: - Red Neobrutalism Color Palette

extension Color {
    // Red Neobrutalism Primary Colors
    static let neoRed = Color(red: 1.0, green: 0.09, blue: 0.27)         // #FF1744 Vibrant Crimson Red
    static let neoDarkRed = Color(red: 0.83, green: 0.0, blue: 0.0)      // #D50000 Deep Red
    static let neoSoftPink = Color(red: 1.0, green: 0.82, blue: 0.86)    // #FFD1DC Rose Soft
    static let neoYellow = Color(red: 1.0, green: 0.86, blue: 0.0)      // #FFDC00 Electric Gold
    static let neoCyan = Color(red: 0.0, green: 0.82, blue: 1.0)        // #00D2FF Cyan Accent
    static let neoLime = Color(red: 0.20, green: 0.84, blue: 0.29)      // #32D74B Lime Green
    static let neoPink = Color(red: 1.0, green: 0.20, blue: 0.47)       // #FF3278 Hot Pink
    static let neoOrange = Color(red: 1.0, green: 0.58, blue: 0.0)      // #FF9500 Vivid Orange
    static let neoPurple = Color(red: 0.75, green: 0.35, blue: 0.95)    // #BF5AF2 Vibrant Violet

    // Base Colors
    static let neoPaper = Color(red: 0.97, green: 0.96, blue: 0.94)     // #F7F4EF Paper White
    static let neoCream = Color(red: 1.0, green: 0.99, blue: 0.97)      // #FFFDF9 Cream White
    static let neoDark = Color(red: 0.08, green: 0.08, blue: 0.09)      // #141416 Deep Dark
    static let neoDarkCard = Color(red: 0.13, green: 0.13, blue: 0.15)  // #212126 Dark Card

    // Dynamic Helpers
    static func neoBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? neoDark : neoPaper
    }

    static func neoCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? neoDarkCard : neoCream
    }

    static func neoBorder(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }

    static func neoShadowColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.8) : Color.black
    }

    static func neoPrimaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }

    static func neoSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.75) : Color(white: 0.3)
    }
}

// MARK: - Radius & Spacing

struct MandyRadius {
    static let micro: CGFloat = 6
    static let standard: CGFloat = 12
    static let card: CGFloat = 16
    static let large: CGFloat = 16
}

struct MandySpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - View Modifiers

struct NeobrutalCardModifier: ViewModifier {
    let bg: Color
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.card)
                        .fill(Color.neoShadowColor(colorScheme))
                        .offset(x: 4, y: 4)

                    RoundedRectangle(cornerRadius: MandyRadius.card)
                        .fill(bg)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: MandyRadius.card)
                    .stroke(Color.neoBorder(colorScheme), lineWidth: 2.5)
            )
    }
}

extension View {
    func neobrutalCard(bg: Color = .white) -> some View {
        modifier(NeobrutalCardModifier(bg: bg))
    }

    func mandySectionHeading() -> some View {
        self.font(.system(size: 26, weight: .black, design: .default))
    }

    func mandyCardTitle() -> some View {
        self.font(.system(size: 18, weight: .black, design: .default))
    }

    func mandyBody() -> some View {
        self.font(.system(size: 14, weight: .bold, design: .default))
    }

    func mandyCaptionBold() -> some View {
        self.font(.system(size: 12, weight: .black, design: .default))
    }

    func mandyMicro() -> some View {
        self.font(.system(size: 11, weight: .bold, design: .default))
    }
}
