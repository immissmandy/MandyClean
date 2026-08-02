import Foundation

struct MaintenanceTask: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let command: String
    var isExecuting: Bool = false
    var isSuccess: Bool? = nil
}
