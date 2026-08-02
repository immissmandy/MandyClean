import SwiftUI

struct ThemeCustomizerView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPreset: NeoThemePreset = .cyberLime

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                presetGrid
                themePreviewCard
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Theme Engine & Skin Customizer")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Custom Neobrutalism color palettes and UI styling")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            Spacer()
        }
    }

    private var presetGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MandySpacing.lg) {
            ForEach(NeoThemePreset.allCases) { preset in
                presetCard(preset)
            }
        }
    }

    private func presetCard(_ preset: NeoThemePreset) -> some View {
        let isSelected = selectedPreset == preset
        return Button(action: { selectedPreset = preset }) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Text(preset.rawValue)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.black)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.black)
                    }
                }

                HStack(spacing: 8) {
                    Circle().fill(preset.primaryAccent).frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                    Circle().fill(preset.secondaryAccent).frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                }
            }
            .padding(MandySpacing.lg)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.black)
                        .offset(x: 3, y: 3)
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(isSelected ? preset.primaryAccent : Color.white)
                }
            )
            .overlay(RoundedRectangle(cornerRadius: MandyRadius.standard).stroke(Color.black, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var themePreviewCard: some View {
        GlassCard(bg: selectedPreset.primaryAccent) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                Text("THEME PREVIEW")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.black)

                Text("MandyClean Neobrutalism System Active Theme")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)

                HStack(spacing: MandySpacing.md) {
                    MandyPrimaryButton("Primary Action", icon: "sparkles") {}
                    MandyDestructiveButton("Secondary Action", icon: "trash") {}
                }
            }
            .padding(MandySpacing.xl)
        }
    }
}
