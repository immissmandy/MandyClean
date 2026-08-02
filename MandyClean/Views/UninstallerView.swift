import SwiftUI

struct UninstallerView: View {
    @ObservedObject var viewModel: UninstallerViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmation = false

    var body: some View {
        HStack(spacing: 0) {
            // App List
            appList
                .frame(minWidth: 320, maxWidth: 400)

            Rectangle()
                .fill(Color.neoBorder(colorScheme))
                .frame(width: 2)

            // Detail Panel
            if let app = viewModel.selectedApp {
                appDetail(app)
            } else {
                emptyState
            }
        }
        .background(Color.neoBackground(colorScheme))
        .alert(
            "Uninstall \(viewModel.selectedApp?.name ?? "")?",
            isPresented: $showConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Move to Trash", role: .destructive) {
                viewModel.uninstallSelected()
            }
        } message: {
            Text("The app and selected related files will be moved to the Trash.")
        }
    }

    // MARK: - App List

    private var appList: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Installed Apps")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                Spacer()
                Text("\(viewModel.filteredApps.count)")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.neoYellow))
                    .overlay(Capsule().stroke(Color.neoBorder(colorScheme), lineWidth: 1.5))
            }
            .padding(.horizontal, MandySpacing.md)
            .padding(.top, MandySpacing.md)
            .padding(.bottom, MandySpacing.sm)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    .font(.system(size: 13, weight: .bold))
                TextField("Search apps…", text: $viewModel.searchText)
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
            .padding(.horizontal, MandySpacing.md)
            .padding(.bottom, MandySpacing.sm)

            Rectangle()
                .fill(Color.neoBorder(colorScheme))
                .frame(height: 2)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(viewModel.filteredApps) { app in
                            appRow(app)
                        }
                    }
                    .padding(.vertical, MandySpacing.xs)
                    .padding(.horizontal, MandySpacing.xs)
                }
            }
        }
    }

    private func appRow(_ app: InstalledApp) -> some View {
        let isSelected = viewModel.selectedApp?.id == app.id

        return HStack(spacing: MandySpacing.sm) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 14, weight: .black))
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .black : Color.neoPrimaryText(colorScheme))

                Text(app.appSizeFormatted)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isSelected ? Color.black.opacity(0.8) : Color.neoSecondaryText(colorScheme))
            }

            Spacer()
        }
        .padding(.horizontal, MandySpacing.md)
        .padding(.vertical, MandySpacing.sm)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .fill(Color.neoYellow)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .stroke(Color.neoBorder(colorScheme), lineWidth: 2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectApp(app)
        }
    }

    // MARK: - App Detail

    private func appDetail(_ app: InstalledApp) -> some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                // App Header
                GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                    VStack(spacing: MandySpacing.md) {
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 72, height: 72)
                            .shadow(color: .black, radius: 0, x: 3, y: 3)

                        Text(app.name)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))

                        Text(app.bundleIdentifier)
                            .mandyMicro()
                            .foregroundStyle(Color.neoSecondaryText(colorScheme))

                        HStack {
                            Text("Total Size:")
                                .font(.system(size: 14, weight: .bold))
                            Text(app.totalSizeFormatted)
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.neoLime))
                                .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
                        }
                    }
                    .padding(MandySpacing.lg)
                    .frame(maxWidth: .infinity)
                }

                // Related Files
                if !app.relatedFiles.isEmpty {
                    GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                        VStack(alignment: .leading, spacing: MandySpacing.sm) {
                            HStack {
                                Text("RELATED FILES & CACHES")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                                Spacer()
                                Text("\(app.relatedFiles.count) found")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                            }

                            Rectangle()
                                .fill(Color.neoBorder(colorScheme))
                                .frame(height: 2)

                            ForEach(app.relatedFiles) { file in
                                relatedFileRow(file)
                            }
                        }
                        .padding(MandySpacing.md)
                    }
                }

                // Uninstall Button
                if viewModel.isUninstalling {
                    ProgressView("UNINSTALLING...")
                        .font(.system(size: 14, weight: .black))
                } else {
                    MandyDestructiveButton("Uninstall \(app.name)", icon: "trash") {
                        showConfirmation = true
                    }
                }

                if let result = viewModel.uninstallResult {
                    Text(result)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(result.contains("Failed") ? Color.red : Color.green)
                }

                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
            .frame(maxWidth: .infinity)
        }
    }

    private func relatedFileRow(_ file: RelatedFile) -> some View {
        HStack(spacing: MandySpacing.sm) {
            Button(action: { viewModel.toggleRelatedFile(id: file.id) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.micro)
                        .fill(file.isSelected ? Color.neoCyan : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                    if file.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(file.name)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                Text(file.path)
                    .mandyMicro()
                    .lineLimit(1)
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            Text(file.sizeFormatted)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: MandySpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.neoYellow)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 3))
                Image(systemName: "app.dashed")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.black)
            }

            Text("SELECT AN APP")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))

            Text(
                "Choose an application from the list on the left to view details and related files."
            )
            .mandyCaptionBold()
            .foregroundStyle(Color.neoSecondaryText(colorScheme))
            .multilineTextAlignment(.center)
            .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
