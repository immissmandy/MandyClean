import Foundation

enum LaunchItemType: String, CaseIterable, Identifiable {
    case userAgent = "User Agent"
    case systemAgent = "System Agent"
    case systemDaemon = "System Daemon"

    var id: String { rawValue }

    var path: String {
        switch self {
        case .userAgent:
            return NSHomeDirectory() + "/Library/LaunchAgents"
        case .systemAgent:
            return "/Library/LaunchAgents"
        case .systemDaemon:
            return "/Library/LaunchDaemons"
        }
    }
}

struct LaunchItem: Identifiable {
    let id = UUID()
    let name: String
    let label: String
    let path: String
    let type: LaunchItemType
    var isEnabled: Bool
    let programPath: String?
}
