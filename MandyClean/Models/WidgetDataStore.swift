import Foundation

struct WidgetMetricSnapshot: Codable {
    let timestamp: Date
    let ramUsagePercent: Double
    let cpuUsagePercent: Double
    let diskFreeBytes: UInt64
    let downloadSpeedBytesPerSec: Double
    let uploadSpeedBytesPerSec: Double

    var ramPercentFormatted: String {
        "\(Int(ramUsagePercent * 100))%"
    }

    var cpuPercentFormatted: String {
        "\(Int(cpuUsagePercent))%"
    }

    var diskFreeFormatted: String {
        RAMInfo.formatBytes(diskFreeBytes)
    }

    var downloadFormatted: String {
        RAMInfo.formatBytes(UInt64(downloadSpeedBytesPerSec)) + "/s"
    }
}

class WidgetDataStore {
    static let shared = WidgetDataStore()
    private let defaults = UserDefaults.standard

    private let key = "MandyCleanWidgetSnapshot"

    func saveSnapshot(_ snapshot: WidgetMetricSnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: key)
        }
    }

    func loadSnapshot() -> WidgetMetricSnapshot {
        if let data = defaults.data(forKey: key),
           let snapshot = try? JSONDecoder().decode(WidgetMetricSnapshot.self, from: data) {
            return snapshot
        }
        return WidgetMetricSnapshot(
            timestamp: Date(),
            ramUsagePercent: 0.65,
            cpuUsagePercent: 18.0,
            diskFreeBytes: 45 * 1024 * 1024 * 1024,
            downloadSpeedBytesPerSec: 1250000,
            uploadSpeedBytesPerSec: 450000
        )
    }
}
