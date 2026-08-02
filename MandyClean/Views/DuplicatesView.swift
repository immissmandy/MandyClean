import SwiftUI

struct DuplicatesView: View {
    @ObservedObject var viewModel: DuplicatesViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.resultMessage {
                    resultBanner(msg)
                }

                if viewModel.groups.isEmpty && !viewModel.isScanning {
                    scanPrompt
                } else if viewModel.isScanning {
                    scanningIndicator
                } else {
                    summaryBar
                    groupList
                }

                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
        .alert("Confirm Deletion", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Selected", role: .destructive) {
                viewModel.deleteSelected()
            }
        } message: {
            Text("This will delete \(viewModel.totalSelectedFormatted) of duplicate files. Copies marked for deletion will be permanently removed.")
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Duplicate Finder")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Find & remove duplicate files with SHA256 Smart Select")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            if !viewModel.groups.isEmpty {
                MandyPrimaryButton("Rescan", icon: "arrow.clockwise") {
                    viewModel.scan()
                }
            }
        }
    }

    private var scanPrompt: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.neoYellow)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 3))
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("SCAN FOR DUPLICATES")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Scan Downloads, Documents, Pictures, and Movies for exact duplicate files using SHA256 checksums.")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                MandyPrimaryButton("Start Duplicate Scan", icon: "sparkles") {
                    viewModel.scan()
                }
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private var scanningIndicator: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()

                Text("SCANNING FOR DUPLICATES...")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Comparing file hashes across user directories...")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private var summaryBar: some View {
        GlassCard(bg: Color.neoYellow) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECLAIMABLE DUPLICATE SPACE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                    Text(viewModel.totalSelectedFormatted)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.black)
                }

                Spacer()

                MandyDestructiveButton("Delete Selected Duplicates", icon: "trash") {
                    showConfirmation = true
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private var groupList: some View {
        VStack(spacing: MandySpacing.lg) {
            ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { gIdx, group in
                GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                    VStack(alignment: .leading, spacing: MandySpacing.sm) {
                        HStack {
                            Text("Duplicate Group (\(group.files.count) copies)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(Color.neoPrimaryText(colorScheme))
                            Spacer()
                            Text("Wasted: \(group.totalWastedFormatted)")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(Color.neoPink)
                        }

                        Rectangle()
                            .fill(Color.neoBorder(colorScheme))
                            .frame(height: 1.5)

                        ForEach(Array(group.files.enumerated()), id: \.element.id) { fIdx, file in
                            HStack(spacing: MandySpacing.md) {
                                Button(action: { viewModel.toggleFileSelection(groupIndex: gIdx, fileIndex: fIdx) }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: MandyRadius.micro)
                                            .fill(file.isSelected ? Color.neoCyan : Color.clear)
                                            .frame(width: 20, height: 20)
                                            .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                                        if file.isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .black))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(file.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                                    Text(file.path)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                                }

                                Spacer()

                                Text(file.sizeFormatted)
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                            }
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.neoBackground(colorScheme).opacity(0.4)))
                        }
                    }
                    .padding(MandySpacing.md)
                }
            }
        }
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
