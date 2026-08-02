import Foundation
import IOKit.ps

class HardwareService {
    func fetchHardwareInfo() -> HardwareInfo {
        var info = HardwareInfo()

        // 1. Battery Info via IOKit
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as [CFTypeRef]

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] else {
                continue
            }

            info.hasBattery = true
            let currentCap = description[kIOPSCurrentCapacityKey] as? Int ?? 0
            let maxCap = description[kIOPSMaxCapacityKey] as? Int ?? 100
            info.batteryPercentage = maxCap > 0 ? Int((Double(currentCap) / Double(maxCap)) * 100.0) : currentCap

            info.isCharging = (description[kIOPSIsChargingKey] as? Bool) ?? false
            info.powerSource = (description[kIOPSPowerSourceStateKey] as? String) ?? "AC Power"
        }

        // 2. Thermal State
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: info.thermalState = "Nominal (Cool)"
        case .fair: info.thermalState = "Fair (Warm)"
        case .serious: info.thermalState = "Serious (Hot)"
        case .critical: info.thermalState = "Critical (Overheating)"
        @unknown default: info.thermalState = "Normal"
        }

        return info
    }
}
