import SwiftUI

struct ExtensionsView: View {
    @ObservedObject var viewModel: ExtensionsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.statusMessage {
                    statusBanner(msg)
                }

                categoryTabs
                extensionList
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Extensions Manager")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Manage Preference Panes, QuickLook & Spotlight plugins")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            MandyPrimaryButton("Refresh List", icon: "arrow.clockwise") {
                viewModel.loadItems()
            }
        }
    }

    private var categoryTabs: some View {
        HStack(spacing: 8) {
            ForEach(ExtensionCategory.allCases) { cat in
                let isSelected = viewModel.selectedCategory == cat
                Button(action: { viewModel.selectedCategory = cat }) {
                    HStack(spacing: 6) {
                        Image(systemName: cat.icon)
                            .font(.system(size: 13, weight: .bold))
                        Text(cat.rawValue)
                            .font(.system(size: 13, weight: .black))
                    }
                    .foregroundColor(isSelected ? .black : Color.neoPrimaryText(colorScheme))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            if isSelected {
                                Capsule().fill(Color.neoYellow)
                            } else {
                                Capsule().fill(Color.neoCardBackground(colorScheme))
                            }
                        }
                    )
                    .overlay(Capsule().stroke(Color.neoBorder(colorScheme), lineWidth: isSelected ? 2 : 1))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private var extensionList: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text(viewModel.selectedCategory.rawValue.uppercased())
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    Text("\(viewModel.filteredItems.count) items")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 2)

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                } else if viewModel.filteredItems.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "puzzlepiece.fill")
                            .font(.system(size: 32, weight: .bold))
                        Text("No extensions found in this category")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredItems) { item in
                            extensionRow(item)
                        }
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func extensionRow(_ item: SystemExtensionItem) -> some View {
        HStack(spacing: MandySpacing.md) {
            Image(systemName: item.category.icon)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                Text(item.path)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            Text(item.sizeFormatted)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))

            Button(action: { viewModel.deleteExtension(item) }) {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.red)
                    .padding(8)
                    .background(Circle().fill(Color.red.opacity(0.15)))
            }
            .buttonStyle(.plain)
        }
        .padding(MandySpacing.md)
        .background(RoundedRectangle(cornerRadius: MandyRadius.standard).fill(Color.neoBackground(colorScheme).opacity(0.5)))
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.neoBorder(colorScheme).opacity(0.4), lineWidth: 1))
    }

    private func statusBanner(_ msg: String) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .bold))
            Text(msg)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(.black)
        .padding(MandySpacing.md)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: MandyRadius.standard).fill(Color.neoLime))
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.black, lineWidth: 2))
    }
}
