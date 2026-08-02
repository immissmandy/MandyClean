import Foundation

class MaintenanceViewModel: ObservableObject {
    @Published var tasks: [MaintenanceTask] = [
        MaintenanceTask(name: "Flush DNS Cache", description: "Fixes domain resolution & network connectivity issues", icon: "network", command: "dscacheutil -flushcache; killall -HUP mDNSResponder"),
        MaintenanceTask(name: "Rebuild Spotlight Index", description: "Resolves file search indexing errors and slow search", icon: "magnifyingglass", command: "mdutil -E /"),
        MaintenanceTask(name: "Reset LaunchServices Database", description: "Fixes corrupted open-with application menu associations", icon: "arrow.triangle.2.circlepath", command: "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user"),
        MaintenanceTask(name: "Run macOS Maintenance Scripts", description: "Executes periodic daily, weekly, and monthly system tasks", icon: "terminal", command: "periodic daily weekly monthly")
    ]

    private let service = MaintenanceService()

    func executeTask(_ task: MaintenanceTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isExecuting = true
        tasks[idx].isSuccess = nil

        service.executeTask(task) { [weak self] success in
            guard let self = self else { return }
            if let targetIdx = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[targetIdx].isExecuting = false
                self.tasks[targetIdx].isSuccess = success
                AudioService.shared.playCleanSound()
            }
        }
    }
}
