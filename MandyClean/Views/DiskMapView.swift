import SwiftUI

struct DiskMapView: View {
    @ObservedObject var viewModel: DiskMapViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if viewModel.rootNode == nil && !viewModel.isScanning {
                    scanPrompt
                } else if viewModel.isScanning {
                    scanningIndicator
                } else if let root = viewModel.rootNode {
                    treeMapView(root)
                }

                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Visuelle Speicher-Map")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Interaktives Neobrutalismus Treemap-Diagramm des Benutzerordners")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            if viewModel.rootNode != nil {
                MandyPrimaryButton("Neu Scannen", icon: "arrow.clockwise") {
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
                        .fill(Color.neoCyan)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 3))
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("SPEICHER-MAP GENERIEREN")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Analysiert rekursiv alle Unterordner und stellt die Speicherbelegung als Treemap dar.")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                MandyPrimaryButton("Treemap Scannen", icon: "sparkles") {
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

                Text("ANALYSIRIE ORDNERSTRUKTUR...")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Berechne Ordnergrößen für Treemap Visualisierung...")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private func treeMapView(_ root: DiskNode) -> some View {
        VStack(alignment: .leading, spacing: MandySpacing.lg) {
            GlassCard(bg: Color.neoYellow) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HOME DIRECTORY TOTAL")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.black)
                        Text(root.sizeFormatted)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(MandySpacing.lg)
            }

            if let children = root.children, !children.isEmpty {
                GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                    VStack(alignment: .leading, spacing: MandySpacing.md) {
                        Text("TOP DIRECTORIES (TREEMAP BLOCKS)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))

                        Rectangle()
                            .fill(Color.neoBorder(colorScheme))
                            .frame(height: 2)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MandySpacing.md) {
                            ForEach(children.prefix(8)) { child in
                                treemapBlock(child)
                            }
                        }
                    }
                    .padding(MandySpacing.lg)
                }
            }
        }
    }

    private func treemapBlock(_ node: DiskNode) -> some View {
        VStack(alignment: .leading, spacing: MandySpacing.xs) {
            HStack {
                Text(node.name)
                    .font(.system(size: 16, weight: .black))
                    .lineLimit(1)
                    .foregroundColor(.black)
                Spacer()
            }

            Text(node.sizeFormatted)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.black)

            Text(node.path)
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(MandySpacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .fill(Color.black)
                    .offset(x: 3, y: 3)
                RoundedRectangle(cornerRadius: MandyRadius.standard)
                    .fill(node.color)
            }
        )
        .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.black, lineWidth: 2))
    }
}
