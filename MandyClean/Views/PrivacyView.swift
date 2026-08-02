import SwiftUI

struct PrivacyView: View {
    @ObservedObject var viewModel: PrivacyViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.resultMessage {
                    resultBanner(msg)
                }

                summaryBar
                itemList
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Privacy & Trace Cleaner")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Clean terminal histories, QuickLook caches, and clipboard data")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            MandyPrimaryButton("Scan Privacy Spuren", icon: "arrow.clockwise") {
                viewModel.loadItems()
            }
        }
    }

    private var summaryBar: some View {
        GlassCard(bg: Color.neoYellow) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SELECTED PRIVACY DATA")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                    Text(viewModel.selectedTotalSizeFormatted)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.black)
                }

                Spacer()

                MandyDestructiveButton("Clean Selected Traces", icon: "trash") {
                    viewModel.cleanSelected()
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private var itemList: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text("PRIVACY ITEMS")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    Text("\(viewModel.items.count) items")
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
                } else if viewModel.items.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.neoLime)
                        Text("No sensitive traces found")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.items) { item in
                            itemRow(item)
                        }
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func itemRow(_ item: PrivacyItem) -> some View {
        HStack(spacing: MandySpacing.md) {
            Button(action: { viewModel.toggleItem(item) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.micro)
                        .fill(item.isSelected ? Color.neoCyan : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                    if item.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
            }
            .buttonStyle(.plain)

            Image(systemName: item.category.icon)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                Text(item.description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            Text(item.sizeFormatted)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
        }
        .padding(MandySpacing.md)
        .background(RoundedRectangle(cornerRadius: MandyRadius.standard).fill(Color.neoBackground(colorScheme).opacity(0.5)))
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.neoBorder(colorScheme).opacity(0.4), lineWidth: 1))
    }

    private func resultBanner(_ msg: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
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
