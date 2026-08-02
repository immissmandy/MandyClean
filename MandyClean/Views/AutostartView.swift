import SwiftUI

struct AutostartView: View {
    @ObservedObject var viewModel: AutostartViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.statusMessage {
                    statusBanner(msg)
                }

                filterBar
                itemList
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Autostart Manager")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Manage login items, launch agents, and background daemons")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            MandyPrimaryButton("Refresh List", icon: "arrow.clockwise") {
                viewModel.loadItems()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: MandySpacing.md) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                TextField("Search autostart items…", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .fill(Color.neoCyan.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .stroke(Color.neoBorder(colorScheme), lineWidth: 2)
            )

            // Type Filter Capsules
            HStack(spacing: 6) {
                typeFilterButton(nil, title: "All")
                ForEach(LaunchItemType.allCases) { type in
                    typeFilterButton(type, title: type.rawValue)
                }
            }
        }
    }

    private func typeFilterButton(_ type: LaunchItemType?, title: String) -> some View {
        let isSelected = viewModel.selectedType == type
        return Button(action: { viewModel.selectedType = type }) {
            Text(title)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(isSelected ? .black : Color.neoPrimaryText(colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule().fill(Color.neoYellow)
                        } else {
                            Capsule().fill(Color.neoCardBackground(colorScheme))
                        }
                    }
                )
                .overlay(
                    Capsule().stroke(Color.neoBorder(colorScheme), lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Item List

    private var itemList: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text("LAUNCH ITEMS")
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
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 32, weight: .bold))
                        Text("No autostart items found")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredItems) { item in
                            itemRow(item)
                        }
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func itemRow(_ item: LaunchItem) -> some View {
        HStack(spacing: MandySpacing.md) {
            // Enable / Disable Toggle
            Toggle("", isOn: Binding(
                get: { item.isEnabled },
                set: { _ in viewModel.toggleItem(item) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Text(item.type.rawValue.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(typeColor(item.type)))
                        .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                }

                Text(item.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))

                if let path = item.programPath {
                    Text(path)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                        .foregroundStyle(Color.neoSecondaryText(colorScheme).opacity(0.7))
                }
            }

            Spacer()

            Button(action: { viewModel.deleteItem(item) }) {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.red)
                    .padding(8)
                    .background(Circle().fill(Color.red.opacity(0.15)))
            }
            .buttonStyle(.plain)
        }
        .padding(MandySpacing.md)
        .background(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .fill(Color.neoBackground(colorScheme).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .stroke(Color.neoBorder(colorScheme).opacity(0.4), lineWidth: 1)
        )
    }

    private func statusBanner(_ text: String) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .bold))
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(.black)
        .padding(MandySpacing.md)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: MandyRadius.standard).fill(Color.neoLime))
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.black, lineWidth: 2))
    }

    private func typeColor(_ type: LaunchItemType) -> Color {
        switch type {
        case .userAgent: return .neoYellow
        case .systemAgent: return .neoCyan
        case .systemDaemon: return .neoPink
        }
    }
}
