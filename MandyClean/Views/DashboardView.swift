import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var monitor: SystemMonitorService
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                gaugesRow
                chartsRow
                infoCards
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
                HStack(spacing: 10) {
                    Text("Dashboard")
                        .mandySectionHeading()
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Text("LIVE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: MandyRadius.micro)
                                    .fill(Color.neoShadowColor(colorScheme))
                                    .offset(x: 2, y: 2)
                                RoundedRectangle(cornerRadius: MandyRadius.micro)
                                    .fill(Color.neoLime)
                            }
                        )
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 1.5))
                }

                Text("System overview and real-time statistics")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Gauges

    private var gaugesRow: some View {
        HStack(spacing: MandySpacing.lg) {
            // RAM Gauge
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(spacing: MandySpacing.md) {
                    CircularGauge(
                        value: monitor.ramInfo.usagePercent,
                        label: "RAM",
                        detail: "\(RAMInfo.formatBytes(monitor.ramInfo.used)) / \(RAMInfo.formatBytes(monitor.ramInfo.total))",
                        color: gaugeColor(for: monitor.ramInfo.usagePercent)
                    )

                    Text("MEMORY USAGE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity)
            }

            // CPU Gauge
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(spacing: MandySpacing.md) {
                    CircularGauge(
                        value: monitor.cpuUsage / 100,
                        label: "CPU",
                        detail: "\(ProcessInfo.processInfo.processorCount) Cores",
                        color: gaugeColor(for: monitor.cpuUsage / 100)
                    )

                    Text("CPU LOAD")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity)
            }

            // Storage Gauge
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(spacing: MandySpacing.md) {
                    CircularGauge(
                        value: diskUsagePercent,
                        label: "DISK",
                        detail: "\(RAMInfo.formatBytes(monitor.diskFree)) free",
                        color: gaugeColor(for: diskUsagePercent)
                    )

                    Text("STORAGE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Live 60-Sec Charts

    private var chartsRow: some View {
        HStack(spacing: MandySpacing.lg) {
            // RAM History Chart
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.sm) {
                    HStack {
                        Label("RAM History (60s)", systemImage: "memorychip")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))
                        Spacer()
                        Text("\(Int(monitor.ramInfo.usagePercent * 100))%")
                            .font(.system(size: 13, weight: .black))
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
                        .foregroundStyle(Color.neoYellow.opacity(0.3))

                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("RAM %", point.value)
                        )
                        .foregroundStyle(Color.neoYellow)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis(.hidden)
                    .frame(height: 120)
                }
                .padding(MandySpacing.md)
            }

            // CPU History Chart
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.sm) {
                    HStack {
                        Label("CPU History (60s)", systemImage: "cpu")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))
                        Spacer()
                        Text("\(Int(monitor.cpuUsage))%")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.neoCyan)
                    }

                    Rectangle()
                        .fill(Color.neoBorder(colorScheme))
                        .frame(height: 1.5)

                    Chart(monitor.cpuHistory) { point in
                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("CPU %", point.value)
                        )
                        .foregroundStyle(Color.neoCyan.opacity(0.3))

                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("CPU %", point.value)
                        )
                        .foregroundStyle(Color.neoCyan)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis(.hidden)
                    .frame(height: 120)
                }
                .padding(MandySpacing.md)
            }
        }
    }

    // MARK: - Info Cards

    private var infoCards: some View {
        HStack(spacing: MandySpacing.lg) {
            // System Specs Card
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.md) {
                    Label("System Info", systemImage: "desktopcomputer")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Rectangle()
                        .fill(Color.neoBorder(colorScheme))
                        .frame(height: 2)

                    infoRow("macOS", ProcessInfo.processInfo.operatingSystemVersionString)
                    infoRow("CPU Cores", "\(ProcessInfo.processInfo.processorCount)")
                    infoRow("Physical RAM", RAMInfo.formatBytes(ProcessInfo.processInfo.physicalMemory))
                    infoRow("Active Apps", "\(monitor.processCount)")
                    infoRow("Disk Total", RAMInfo.formatBytes(monitor.diskTotal))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Quick Control Card
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.md) {
                    Label("Quick Actions", systemImage: "bolt.fill")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Rectangle()
                        .fill(Color.neoBorder(colorScheme))
                        .frame(height: 2)

                    VStack(spacing: MandySpacing.md) {
                        MandyPrimaryButton("Refresh System Data", icon: "arrow.clockwise") {
                            monitor.update()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Helpers

    private var diskUsagePercent: Double {
        guard monitor.diskTotal > 0 else { return 0 }
        return Double(monitor.diskUsed) / Double(monitor.diskTotal)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
        }
    }

    private func gaugeColor(for value: Double) -> Color {
        if value < 0.6 { return .neoCyan }
        if value < 0.85 { return .neoYellow }
        return .neoPink
    }
}
