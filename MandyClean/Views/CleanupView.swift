import SwiftUI

struct CleanupView: View {
    @ObservedObject var viewModel: CleanupViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if !viewModel.scanComplete && !viewModel.isScanning {
                    scanPrompt
                } else if viewModel.isScanning {
                    scanningIndicator
                } else {
                    scanResults
                }

                if let result = viewModel.cleanResult {
                    resultBanner(result)
                }

                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
        .alert("Confirm Cleanup", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clean Selected", role: .destructive) {
                viewModel.clean()
            }
        } message: {
            Text(
                "This will permanently delete \(viewModel.totalReclaimableFormatted) of data. This action cannot be undone."
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("System Cleanup")
                .mandySectionHeading()
                .foregroundStyle(Color.neoPrimaryText(colorScheme))

            Text("Scan and remove junk files to free up disk space")
                .mandyBody()
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("SCAN YOUR SYSTEM")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text(
                    "Find cached files, logs, browser data, and other items that can be safely removed."
                )
                .mandyBody()
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)

                MandyPrimaryButton("Start System Scan", icon: "sparkles") {
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

                Text("SCANNING SYSTEM...")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Analyzing caches, logs, and temporary files...")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Scan Results

    private var scanResults: some View {
        VStack(spacing: MandySpacing.lg) {
            // Summary bar
            GlassCard(bg: Color.neoYellow) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RECLAIMABLE SPACE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.black)
                        Text(viewModel.totalReclaimableFormatted)
                            .font(.system(size: 38, weight: .black))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    HStack(spacing: MandySpacing.md) {
                        MandyPillButton("Rescan") {
                            viewModel.scan()
                        }

                        if viewModel.isCleaning {
                            ProgressView()
                                .padding(.horizontal)
                        } else {
                            MandyDestructiveButton("Clean Selected", icon: "trash") {
                                showConfirmation = true
                            }
                        }
                    }
                }
                .padding(MandySpacing.lg)
            }

            // Category rows
            ForEach(viewModel.categories) { category in
                categoryRow(category)
            }
        }
    }

    private func categoryRow(_ category: CleanupCategory) -> some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            HStack(spacing: MandySpacing.md) {
                Button(action: { viewModel.toggleCategory(id: category.id) }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: MandyRadius.micro)
                            .fill(category.isSelected ? Color.neoCyan : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                        if category.isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.black)
                        }
                    }
                }
                .buttonStyle(.plain)

                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoPink.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Text(category.description)
                        .mandyMicro()
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    Text("\(category.items.count) items found")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }

                Spacer()

                Text(category.totalSizeFormatted)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
            }
            .padding(MandySpacing.md)
        }
    }

    // MARK: - Result Banner

    private func resultBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)
            Text(message)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.black)
        }
        .padding(MandySpacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .fill(Color.neoLime)
        )
        .overlay(
            RoundedRectangle(cornerRadius: MandyRadius.standard)
                .stroke(Color.black, lineWidth: 2.5)
        )
        .shadow(color: .black, radius: 0, x: 3, y: 3)
    }
}
