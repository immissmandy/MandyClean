import SwiftUI

// MARK: - Primary Red Neobrutal CTA Button (Crimson Red / White Text)

struct MandyPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var isPressed = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoShadowColor(colorScheme))
                        .offset(x: isPressed ? 1 : 3, y: isPressed ? 1 : 3)

                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoRed)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .stroke(Color.black, lineWidth: 2)
            )
            .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Neobrutal Pill Button (Dark Red / White text)

struct MandyPillButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var isPressed = false

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        Capsule()
                            .fill(Color.neoShadowColor(colorScheme))
                            .offset(x: isPressed ? 1 : 3, y: isPressed ? 1 : 3)

                        Capsule()
                            .fill(Color.neoDarkRed)
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 2)
                )
                .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Neobrutal Destructive Button (Black / White text)

struct MandyDestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var isPressed = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoRed)
                        .offset(x: isPressed ? 1 : 3, y: isPressed ? 1 : 3)

                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.black)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .stroke(Color.neoRed, lineWidth: 2)
            )
            .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}
