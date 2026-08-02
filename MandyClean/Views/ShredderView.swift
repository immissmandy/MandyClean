import SwiftUI
import UniformTypeIdentifiers

struct ShredderView: View {
    @ObservedObject var viewModel: ShredderViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isTargeted = false

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if let msg = viewModel.statusMessage {
                    statusBanner(msg)
                }

                dropZone
                fileList
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Dateivernichter (File Shredder)")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Multi-pass DOD standard file destruction")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            if !viewModel.itemsToShred.isEmpty {
                MandyDestructiveButton("Permanently Shred All", icon: "flame.fill") {
                    viewModel.shredAll()
                }
            }
        }
    }

    private var dropZone: some View {
        GlassCard(bg: isTargeted ? Color.neoPink.opacity(0.3) : Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.neoPink)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2.5))
                    Image(systemName: "trash.slash.fill")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(.white)
                }

                Text("DRAG & DROP FILES TO SHRED")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Files will be overwritten multiple times with random bytes before permanent deletion.")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            viewModel.addFile(at: url.path)
                        }
                    }
                }
            }
            return true
        }
    }

    private var fileList: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text("QUEUED FOR DESTRUCTION")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    Text("\(viewModel.itemsToShred.count) files")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 2)

                if viewModel.isShredding {
                    HStack {
                        Spacer()
                        ProgressView()
                        Text("Overwriting binary blocks...")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                    }
                    .padding()
                } else if viewModel.itemsToShred.isEmpty {
                    Text("No files added to shredder queue")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.itemsToShred) { item in
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundStyle(Color.neoPink)
                                Text(item.name)
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                                Text(item.sizeFormatted)
                                    .font(.system(size: 12, weight: .black))
                                Button(action: { viewModel.removeItem(item) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.neoBackground(colorScheme).opacity(0.4)))
                        }
                    }
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func statusBanner(_ msg: String) -> some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .bold))
            Text(msg)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(MandySpacing.md)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: MandyRadius.standard).fill(Color.neoPink))
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.black, lineWidth: 2))
    }
}
