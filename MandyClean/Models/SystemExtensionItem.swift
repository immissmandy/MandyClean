import Foundation

enum ExtensionCategory: String, CaseIterable, Identifiable {
    case preferencePane = "Preference Panes"
    case quickLook = "QuickLook Plugins"
    case spotlight = "Spotlight Plugins"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .preferencePane: return "slider.horizontal.3"
        case .quickLook: return "eye"
        case .spotlight: return "magnifyingglass"
        }
    }
}

struct SystemExtensionItem: Identifiable {
    let id = UUID()
    let name: String
    let category: ExtensionCategory
    let path: String
    let size: UInt64
    var isEnabled: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
