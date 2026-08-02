import SwiftUI

@main
struct MandyCleanApp: App {
    @StateObject private var monitor = SystemMonitorService()
    @StateObject private var netVM = NetworkViewModel()
    @StateObject private var ramVM = RAMViewModel()
    @StateObject private var maintenanceVM = MaintenanceViewModel()
    @StateObject private var privacyVM = PrivacyViewModel()
    @StateObject private var organizerVM = OrganizerViewModel()

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitor)
                .frame(minWidth: 980, minHeight: 660)
                .onReceive(monitor.$ramInfo) { _ in
                    syncWidgetSnapshot()
                }
        }
        .defaultSize(width: 1180, height: 760)

        MenuBarExtra {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.neoYellow)
                    Text("MandyClean Pro Status")
                        .font(.system(size: 14, weight: .black))
                }

                Divider()

                // Live Stats
                menuStatRow("RAM Usage:", "\(Int(monitor.ramInfo.usagePercent * 100))%", Color.neoYellow)
                menuStatRow("CPU Load:", "\(Int(monitor.cpuUsage))%", Color.neoCyan)
                menuStatRow("Free Storage:", RAMInfo.formatBytes(monitor.diskFree), Color.neoLime)
                menuStatRow("Download:", netVM.stats.downloadFormatted, Color.neoPink)

                Divider()

                // Quick Actions
                Text("QUICK ACTIONS")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.gray)

                Button("⚡ Deep Clean RAM") {
                    ramVM.deepClean()
                }

                Button("🧹 Flush DNS Cache") {
                    if let dnsTask = maintenanceVM.tasks.first(where: { $0.name.contains("DNS") }) {
                        maintenanceVM.executeTask(dnsTask)
                    }
                }

                Button("🛡️ Clear Clipboard") {
                    privacyVM.cleanSelected()
                }

                Button("📸 Organize Screenshots") {
                    organizerVM.organizeSelected()
                }

                Divider()

                Button("Quit MandyClean") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(10)
            .frame(width: 220)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                Text("\(Int(monitor.ramInfo.usagePercent * 100))%")
                    .font(.system(size: 11, weight: .bold))
            }
        }
    }

    private func menuStatRow(_ label: String, _ val: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Text(val)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(color))
        }
    }

    private func syncWidgetSnapshot() {
        let snapshot = WidgetMetricSnapshot(
            timestamp: Date(),
            ramUsagePercent: monitor.ramInfo.usagePercent,
            cpuUsagePercent: monitor.cpuUsage,
            diskFreeBytes: monitor.diskFree,
            downloadSpeedBytesPerSec: netVM.stats.downloadBytesPerSec,
            uploadSpeedBytesPerSec: netVM.stats.uploadBytesPerSec
        )
        WidgetDataStore.shared.saveSnapshot(snapshot)
    }
}
