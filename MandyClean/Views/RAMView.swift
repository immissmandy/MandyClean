import SwiftUI
import Charts

struct RAMView: View {
    @EnvironmentObject var monitor: SystemMonitorService
    @ObservedObject var viewModel: RAMViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                ramOverview
                memoryChart
                memoryBreakdown
                processTable
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
                Text("RAM Monitor")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Real-time memory stats & process management")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if viewModel.isCleaningRAM {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Cleaning RAM...")
                            .font(.system(size: 13, weight: .black))
                    }
                } else {
                    MandyPrimaryButton("Deep Clean RAM", icon: "wand.and.stars") {
                        viewModel.deepClean()
                    }
                }

                if let result = viewModel.cleanResult {
                    Text(result)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(result.contains("success") ? Color.green : Color.neoOrange)
                }
            }
        }
    }

    // MARK: - RAM Overview

    private var ramOverview: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            HStack(spacing: MandySpacing.xxl) {
                CircularGauge(
                    value: monitor.ramInfo.usagePercent,
                    label: "Used",
                    detail: RAMInfo.formatBytes(monitor.ramInfo.used),
                    color: gaugeColor(for: monitor.ramInfo.usagePercent),
                    size: 140,
                    lineWidth: 12
                )

                VStack(alignment: .leading, spacing: MandySpacing.md) {
                    Text("Memory Status")
                        .mandyCardTitle()
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    HStack(spacing: MandySpacing.xl) {
                        memoryStatColumn("Total RAM", RAMInfo.formatBytes(monitor.ramInfo.total))
                        memoryStatColumn("Used RAM", RAMInfo.formatBytes(monitor.ramInfo.used))
                        memoryStatColumn("Free RAM", RAMInfo.formatBytes(monitor.ramInfo.free))
                    }
                }

                Spacer()
            }
            .padding(MandySpacing.xl)
        }
    }

    // MARK: - Memory Chart (60s)

    private var memoryChart: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.sm) {
                HStack {
                    Label("60-Second Memory Usage Trend", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    Text("\(Int(monitor.ramInfo.usagePercent * 100))%")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.neoYellow)
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 1.5)

                Chart(monitor.ramHistory) { point in
                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("RAM %", point.value)
                    )
                    .foregroundStyle(Color.neoYellow.opacity(0.35))

                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("RAM %", point.value)
                    )
                    .foregroundStyle(Color.neoYellow)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .chartYScale(domain: 0...100)
                .chartXAxis(.hidden)
                .frame(height: 110)
            }
            .padding(MandySpacing.md)
        }
    }

    // MARK: - Memory Breakdown

    private var memoryBreakdown: some View {
        HStack(spacing: MandySpacing.lg) {
            memoryCard("Active", monitor.ramInfo.active, .neoLime)
            memoryCard("Wired", monitor.ramInfo.wired, .neoPink)
            memoryCard("Compressed", monitor.ramInfo.compressed, .neoCyan)
            memoryCard("Inactive", monitor.ramInfo.inactive, .neoYellow)
        }
    }

    private func memoryCard(_ label: String, _ bytes: UInt64, _ blockColor: Color) -> some View {
        VStack(spacing: MandySpacing.xs) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: MandyRadius.micro).fill(blockColor))
                    .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.black, lineWidth: 1.5))
                Spacer()
            }

            Text(RAMInfo.formatBytes(bytes))
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))

            Text(label)
                .mandyCaptionBold()
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
        }
        .padding(MandySpacing.md)
        .neobrutalCard(bg: Color.neoCardBackground(colorScheme))
        .frame(maxWidth: .infinity)
    }

    // MARK: - Process Table

    private var processTable: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Label("Running Processes", systemImage: "list.bullet")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Spacer()

                    // Search box
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))
                            .font(.system(size: 12, weight: .bold))
                        TextField("Search processes…", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 180)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: MandyRadius.standard)
                            .fill(Color.neoCyan.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MandyRadius.standard)
                            .stroke(Color.neoBorder(colorScheme), lineWidth: 2)
                    )

                    Button(action: { viewModel.loadProcesses() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(.black)
                            .padding(6)
                            .background(Circle().fill(Color.neoYellow))
                            .overlay(Circle().stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 2)

                if viewModel.isLoadingProcesses {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                } else {
                    // Table Header
                    HStack {
                        Text("PROCESS")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("PID")
                            .frame(width: 60, alignment: .trailing)
                        Text("MEMORY")
                            .frame(width: 80, alignment: .trailing)
                        Text("CPU")
                            .frame(width: 60, alignment: .trailing)
                        Text("ACTION")
                            .frame(width: 65, alignment: .trailing)
                    }
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    .padding(.horizontal, 8)

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(
                                Array(viewModel.filteredProcesses.prefix(100))
                            ) { process in
                                processRow(process)
                            }
                        }
                    }
                    .frame(maxHeight: 320)
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private func processRow(_ process: SystemProcess) -> some View {
        HStack {
            Text(process.name)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(process.pid)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
                .frame(width: 60, alignment: .trailing)

            Text(process.memoryFormatted)
                .font(.system(size: 13, weight: .black))
                .frame(width: 80, alignment: .trailing)

            Text(process.cpuFormatted)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
                .frame(width: 60, alignment: .trailing)

            // Force Quit Button
            Button(action: { viewModel.killProcess(process) }) {
                Text("Kill")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.neoPink))
                    .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .frame(width: 65, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: MandyRadius.micro)
                .fill(Color.neoBackground(colorScheme).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: MandyRadius.micro)
                .stroke(Color.neoBorder(colorScheme).opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func memoryStatColumn(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
            Text(label)
                .mandyCaptionBold()
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
        }
    }

    private func gaugeColor(for value: Double) -> Color {
        if value < 0.6 { return .neoCyan }
        if value < 0.85 { return .neoYellow }
        return .neoPink
    }
}
