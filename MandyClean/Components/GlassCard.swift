import SwiftUI

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    var backgroundColor: Color?

    init(bg: Color? = nil, radius: CGFloat = MandyRadius.card, @ViewBuilder content: () -> Content) {
        self.backgroundColor = bg
        self.content = content()
    }

    var body: some View {
        content
            .neobrutalCard(bg: backgroundColor ?? Color.neoCardBackground(colorScheme))
    }
}
