import Foundation

class AutoPilotService {
    static let shared = AutoPilotService()

    private var timer: Timer?

    private init() {}

    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.checkThresholds()
        }
    }

    private func checkThresholds() {
        let ram = SystemMonitorService()
        if ram.ramInfo.free < 1 * 1024 * 1024 * 1024 { // < 1 GB
            let script = NSAppleScript(source: "do shell script \"/usr/sbin/purge\" with administrator privileges")
            var err: NSDictionary?
            script?.executeAndReturnError(&err)
            NotificationService.shared.sendAlert(
                title: "Auto-Pilot RAM Purge",
                body: "Free memory dropped below 1 GB. Purged inactive RAM automatically.",
                identifier: "autopilot_ram"
            )
        }
    }
}
