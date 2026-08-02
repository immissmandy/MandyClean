import Foundation
import AppKit

class RAMViewModel: ObservableObject {
    @Published var processes: [SystemProcess] = []
    @Published var isLoadingProcesses = false
    @Published var isCleaningRAM = false
    @Published var cleanResult: String?
    @Published var searchText = ""

    private let processService = ProcessService()

    var filteredProcesses: [SystemProcess] {
        if searchText.isEmpty { return processes }
        return processes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        loadProcesses()
    }

    func loadProcesses() {
        isLoadingProcesses = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let procs = self.processService.fetchProcesses()
            DispatchQueue.main.async {
                self.processes = procs
                self.isLoadingProcesses = false
            }
        }
    }

    /// Terminates a process by PID using SIGKILL or NSRunningApplication
    func killProcess(_ process: SystemProcess) {
        if let app = NSRunningApplication(processIdentifier: process.pid) {
            app.terminate()
        } else {
            kill(process.pid, SIGKILL)
        }

        processes.removeAll { $0.pid == process.pid }
        cleanResult = "Terminated \(process.name) (PID \(process.pid))"

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.cleanResult = nil
        }
    }

    /// Runs `purge` with administrator privileges via AppleScript to free inactive RAM.
    func deepClean() {
        isCleaningRAM = true
        cleanResult = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let script = NSAppleScript(
                source:
                    "do shell script \"/usr/sbin/purge\" with administrator privileges"
            )
            var error: NSDictionary?
            script?.executeAndReturnError(&error)
            DispatchQueue.main.async {
                self?.isCleaningRAM = false
                self?.cleanResult =
                    error == nil ? "RAM cleaned successfully" : "RAM cleaning cancelled"

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.cleanResult = nil
                }
            }
        }
    }
}
