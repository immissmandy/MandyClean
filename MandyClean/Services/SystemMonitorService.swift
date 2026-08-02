import AppKit
import Foundation
import Darwin

class SystemMonitorService: ObservableObject {
    @Published var ramInfo = RAMInfo()
    @Published var cpuUsage: Double = 0
    @Published var diskTotal: UInt64 = 0
    @Published var diskUsed: UInt64 = 0
    @Published var diskFree: UInt64 = 0
    @Published var processCount: Int = 0

    // 60-Second Metrics History for SwiftUI Charts
    @Published var ramHistory: [MetricDataPoint] = []
    @Published var cpuHistory: [MetricDataPoint] = []

    private var timer: Timer?
    private var prevCPUTicks: (user: Double, system: Double, idle: Double, nice: Double)?
    private var lastNotificationTime: Date = Date.distantPast

    init() {
        update()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func update() {
        ramInfo = fetchRAMInfo()
        cpuUsage = fetchCPUUsage()
        fetchDiskInfo()
        processCount = NSWorkspace.shared.runningApplications.count

        // Update history data points
        let now = Date()
        let ramPercent = ramInfo.usagePercent * 100.0
        
        ramHistory.append(MetricDataPoint(timestamp: now, value: ramPercent))
        cpuHistory.append(MetricDataPoint(timestamp: now, value: cpuUsage))

        // Keep only last 20 points (60 seconds with 3s intervals)
        if ramHistory.count > 20 { ramHistory.removeFirst(ramHistory.count - 20) }
        if cpuHistory.count > 20 { cpuHistory.removeFirst(cpuHistory.count - 20) }

        // Check for threshold notifications (cooldown 5 minutes)
        if Date().timeIntervalSince(lastNotificationTime) > 300 {
            if ramPercent > 90.0 {
                NotificationService.shared.sendAlert(
                    title: "High RAM Usage Warning",
                    body: String(format: "System memory is at %.0f%%. Run Deep Clean to free up memory.", ramPercent),
                    identifier: "ram_warning"
                )
                lastNotificationTime = Date()
            } else if diskFree > 0 && diskFree < 15 * 1024 * 1024 * 1024 { // < 15 GB
                NotificationService.shared.sendAlert(
                    title: "Low Disk Space Warning",
                    body: "Less than 15 GB of free space available. Run System Cleanup.",
                    identifier: "disk_warning"
                )
                lastNotificationTime = Date()
            }
        }
    }

    // MARK: - RAM (host_statistics64 / HOST_VM_INFO64)

    private func fetchRAMInfo() -> RAMInfo {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return RAMInfo() }

        let pageSize = UInt64(vm_page_size)
        let total = ProcessInfo.processInfo.physicalMemory
        let active = UInt64(stats.active_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize
        let free = UInt64(stats.free_count) * pageSize
        let used = active + wired + compressed

        return RAMInfo(
            total: total,
            used: used,
            free: total > used ? total - used : free,
            active: active,
            inactive: inactive,
            wired: wired,
            compressed: compressed
        )
    }

    // MARK: - CPU (host_statistics / HOST_CPU_LOAD_INFO with delta)

    private func fetchCPUUsage() -> Double {
        let loadInfoCount =
            MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(loadInfoCount)
        var cpuLoadInfo = host_cpu_load_info_data_t()

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: loadInfoCount) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        let user = Double(cpuLoadInfo.cpu_ticks.0)
        let system = Double(cpuLoadInfo.cpu_ticks.1)
        let idle = Double(cpuLoadInfo.cpu_ticks.2)
        let nice = Double(cpuLoadInfo.cpu_ticks.3)

        let current = (user: user, system: system, idle: idle, nice: nice)
        defer { prevCPUTicks = current }

        guard let prev = prevCPUTicks else { return 0 }

        let dUser = current.user - prev.user
        let dSystem = current.system - prev.system
        let dIdle = current.idle - prev.idle
        let dNice = current.nice - prev.nice
        let dTotal = dUser + dSystem + dIdle + dNice

        guard dTotal > 0 else { return 0 }
        return ((dUser + dSystem + dNice) / dTotal) * 100
    }

    // MARK: - Disk (FileManager attributesOfFileSystem)

    private func fetchDiskInfo() {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/")
            diskTotal = attrs[.systemSize] as? UInt64 ?? 0
            diskFree = attrs[.systemFreeSize] as? UInt64 ?? 0
            diskUsed = diskTotal > diskFree ? diskTotal - diskFree : 0
        } catch {
            // Keep previous values on error
        }
    }
}
