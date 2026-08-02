import SwiftUI

struct TopBarView: View {
    @Binding var selection: NavigationItem
    @Environment(\.colorScheme) var colorScheme
    @State private var activeCategory: NavigationCategory = .overview

    var body: some View {
        VStack(spacing: 0) {
            // Upper Header Bar
            HStack(spacing: 16) {
                // App Logo Badge
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: MandyRadius.micro)
                            .fill(Color.neoRed)
                            .frame(width: 32, height: 32)
                            .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.black, lineWidth: 2))
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.white)
                    }

                    Text("MandyClean")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Text("RED PRO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: MandyRadius.micro)
                                    .fill(Color.black)
                                    .offset(x: 2, y: 2)
                                RoundedRectangle(cornerRadius: MandyRadius.micro)
                                    .fill(Color.neoRed)
                            }
                        )
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.black, lineWidth: 1.5))
                }

                Spacer()

                // Category Tabs
                HStack(spacing: 8) {
                    ForEach(NavigationCategory.allCases, id: \.rawValue) { cat in
                        categoryTabButton(cat)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Rectangle()
                .fill(Color.neoBorder(colorScheme))
                .frame(height: 2)
                .padding(.horizontal, 20)

            // Sub-Module Horizontal Pills Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(NavigationItem.allCases.filter { $0.category == activeCategory }) { item in
                        modulePillButton(item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .background(Color.neoBackground(colorScheme).opacity(0.6))

            Rectangle()
                .fill(Color.neoBorder(colorScheme).opacity(0.3))
                .frame(height: 1)
        }
        .background(Color.neoCardBackground(colorScheme))
    }

    private func categoryTabButton(_ cat: NavigationCategory) -> some View {
        let isSelected = activeCategory == cat
        return Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                activeCategory = cat
                // Select first module in category
                if let first = NavigationItem.allCases.first(where: { $0.category == cat }) {
                    selection = first
                }
            }
        }) {
            Text(cat.rawValue)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(isSelected ? .white : Color.neoPrimaryText(colorScheme))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule().fill(Color.neoRed)
                        } else {
                            Capsule().fill(Color.neoBackground(colorScheme))
                        }
                    }
                )
                .overlay(
                    Capsule().stroke(Color.neoBorder(colorScheme), lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func modulePillButton(_ item: NavigationItem) -> some View {
        let isSelected = selection == item
        return Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                selection = item
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.system(size: 12, weight: .black))
                Text(item.rawValue)
                    .font(.system(size: 13, weight: .black))
            }
            .foregroundColor(isSelected ? .black : Color.neoPrimaryText(colorScheme))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: MandyRadius.standard)
                            .fill(Color.neoShadowColor(colorScheme))
                            .offset(x: 2.5, y: 2.5)
                        RoundedRectangle(cornerRadius: MandyRadius.standard)
                            .fill(Color.neoRed.opacity(0.85))
                    } else {
                        RoundedRectangle(cornerRadius: MandyRadius.standard)
                            .fill(Color.neoCardBackground(colorScheme))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .stroke(Color.neoBorder(colorScheme), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
