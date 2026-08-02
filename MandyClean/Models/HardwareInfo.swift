import Foundation

struct HardwareInfo {
    var hasBattery: Bool = false
    var batteryPercentage: Int = 0
    var cycleCount: Int = 0
    var isCharging: Bool = false
    var powerSource: String = "AC Power"
    var cpuName: String = "Apple Silicon"
    var cpuCores: Int = ProcessInfo.processInfo.processorCount
    var memorySize: String = RAMInfo.formatBytes(ProcessInfo.processInfo.physicalMemory)
    var thermalState: String = "Normal"
}
