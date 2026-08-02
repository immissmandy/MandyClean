import Foundation

enum PrivacyCategory: String, CaseIterable, Identifiable {
    case terminal = "Terminal History"
    case quicklook = "QuickLook Caches"
    case recentDocs = "Recent Documents"
    case clipboard = "Clipboard"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .terminal: return "terminal.fill"
        case .quicklook: return "eye.fill"
        case .recentDocs: return "clock.arrow.circlepath"
        case .clipboard: return "doc.on.clipboard.fill"
        }
    }
}

struct PrivacyItem: Identifiable {
    let id = UUID()
    let name: String
    let category: PrivacyCategory
    let path: String
    let description: String
    let size: UInt64
    var isSelected: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
