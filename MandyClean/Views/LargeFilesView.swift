import SwiftUI

struct LargeFilesView: View {
    @ObservedObject var viewModel: LargeFilesViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.resultMessage {
                    resultBanner(msg)
                }

                if viewModel.items.isEmpty && !viewModel.isScanning {
                    scanPrompt
                } else if viewModel.isScanning {
                    scanningIndicator
                } else {
                    filterBar
                    summaryBar
                    fileList
                }

                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
        .alert("Confirm Deletion", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Permanently", role: .destructive) {
                viewModel.deleteSelected()
            }
        } message: {
            Text("This will permanently delete the selected files (\(viewModel.selectedTotalSizeFormatted)). This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Large & Old Files")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Find forgotten space-consuming files in your home folder")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            if !viewModel.items.isEmpty {
                MandyPrimaryButton("Rescan", icon: "arrow.clockwise") {
                    viewModel.scan()
                }
            }
        }
    }

    // MARK: - Scan Prompt

    private var scanPrompt: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.neoYellow)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 3))
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("FIND LARGE FILES")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Scan your home directory for videos, archives, disk images, and documents exceeding 100 MB.")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                MandyPrimaryButton("Start Scan (> 100 MB)", icon: "sparkles") {
                    viewModel.scan()
                }
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Scanning Indicator

    private var scanningIndicator: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()

                Text("SCANNING HOME DIRECTORY...")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Searching Downloads, Documents, Movies, and Caches...")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
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
                TextField("Search files…", text: $viewModel.searchText)
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

            // Category Filter Capsules
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(FileCategory.allCases) { cat in
                        categoryFilterButton(cat)
                    }
                }
            }
        }
    }

    private func categoryFilterButton(_ cat: FileCategory) -> some View {
        let isSelected = viewModel.selectedCategory == cat
        return Button(action: { viewModel.selectedCategory = cat }) {
            HStack(spacing: 4) {
                Image(systemName: cat.icon)
                    .font(.system(size: 11, weight: .bold))
                Text(cat.rawValue)
                    .font(.system(size: 12, weight: .black))
            }
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

    // MARK: - Summary Bar

    private var summaryBar: some View {
        GlassCard(bg: Color.neoYellow) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SELECTED FILES SIZE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                    Text(viewModel.selectedTotalSizeFormatted)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.black)
                }

                Spacer()

                HStack(spacing: MandySpacing.md) {
                    Button("Select All") { viewModel.selectAll(true) }
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)

                    Button("Deselect All") { viewModel.selectAll(false) }
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)

                    MandyDestructiveButton("Delete Selected", icon: "trash") {
                        showConfirmation = true
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    // MARK: - File List

    private var fileList: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text("FILES FOUND")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    Text("\(viewModel.filteredItems.count) files")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 2)

                LazyVStack(spacing: 6) {
                    ForEach(viewModel.filteredItems) { item in
                        fileRow(item)
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func fileRow(_ item: LargeFileItem) -> some View {
        HStack(spacing: MandySpacing.md) {
            Button(action: { viewModel.toggleItemSelection(item) }) {
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
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .black))
                    .lineLimit(1)
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text(item.path)
                    .mandyMicro()
                    .lineLimit(1)
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.sizeFormatted)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text(item.dateFormatted)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
        }
        .padding(MandySpacing.md)
        .background(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .fill(Color.neoBackground(colorScheme).opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .stroke(Color.neoBorder(colorScheme).opacity(0.3), lineWidth: 1)
        )
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
