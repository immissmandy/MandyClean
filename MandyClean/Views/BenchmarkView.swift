import SwiftUI

struct BenchmarkView: View {
    @ObservedObject var viewModel: BenchmarkViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header

                if viewModel.isRunning {
                    runningIndicator
                } else if let res = viewModel.result {
                    scoreCard(res)
                } else {
                    startPrompt
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
                Text("Mac Performance Benchmark")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("CPU compute stress test and memory throughput scorecard")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            Spacer()
        }
    }

    private var startPrompt: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.neoYellow)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 3))
                    Image(systemName: "gauge.with.dots.needle.bottom.100percent")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("STRESS TEST & SCORECARD")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Run multi-core CPU compute tests and memory throughput benchmarks to measure your Mac's speed in NEO-POINTS.")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                MandyPrimaryButton("Start Benchmark Test", icon: "play.fill") {
                    viewModel.runTest()
                }
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private var runningIndicator: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: MandySpacing.lg) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 40)

                Text("COMPUTING STRESS TEST...")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Testing Single-Core, Multi-Core, and RAM Throughput...")
                    .mandyCaptionBold()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private func scoreCard(_ res: BenchmarkResult) -> some View {
        VStack(spacing: MandySpacing.lg) {
            GlassCard(bg: Color.neoYellow) {
                VStack(spacing: MandySpacing.sm) {
                    Text("TOTAL SCORE")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.black)
                    Text(res.scoreFormatted)
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(.black)
                }
                .padding(MandySpacing.xl)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: MandySpacing.lg) {
                metricCard("Single-Core Score", "\(res.singleCoreScore)", .neoCyan)
                metricCard("Multi-Core Score", "\(res.multiCoreScore)", .neoPink)
                metricCard("RAM Throughput", String(format: "%.1f GB/s", res.memoryThroughputGBs), .neoLime)
            }

            MandyPrimaryButton("Run Benchmark Again", icon: "arrow.clockwise") {
                viewModel.runTest()
            }
        }
    }

    private func metricCard(_ title: String, _ value: String, _ color: Color) -> some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            .padding(MandySpacing.lg)
            .frame(maxWidth: .infinity)
        }
    }
}
