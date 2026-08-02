import Foundation

struct SystemProcess: Identifiable {
    let id = UUID()
    let pid: Int32
    let name: String
    let memoryBytes: UInt64
    let cpuPercent: Double

    var memoryFormatted: String {
        RAMInfo.formatBytes(memoryBytes)
    }

    var cpuFormatted: String {
        String(format: "%.1f%%", cpuPercent)
    }
}
