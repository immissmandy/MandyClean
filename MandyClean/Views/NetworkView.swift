import SwiftUI

struct NetworkView: View {
    @ObservedObject var viewModel: NetworkViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                trafficCards
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Echtzeit-Netzwerk-Monitor")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Live network bandwidth & throughput monitoring")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            Spacer()
        }
    }

    private var trafficCards: some View {
        HStack(spacing: MandySpacing.lg) {
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(spacing: MandySpacing.md) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(Color.neoCyan)

                    Text(viewModel.stats.downloadFormatted)
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Text("DOWNLOAD RATE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }
                .padding(MandySpacing.xl)
                .frame(maxWidth: .infinity)
            }

            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(spacing: MandySpacing.md) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(Color.neoLime)

                    Text(viewModel.stats.uploadFormatted)
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Text("UPLOAD RATE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }
                .padding(MandySpacing.xl)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
