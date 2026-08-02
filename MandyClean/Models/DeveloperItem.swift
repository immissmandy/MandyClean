import Foundation

enum DeveloperCategory: String, CaseIterable, Identifiable {
    case derivedData = "Xcode DerivedData"
    case simulator = "iOS Simulator Caches"
    case spm = "Swift Package Manager"
    case cocoapods = "CocoaPods Caches"
    case nodeModules = "Node.js node_modules"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .derivedData: return "hammer.fill"
        case .simulator: return "iphone"
        case .spm: return "shippingbox.fill"
        case .cocoapods: return "cube.box.fill"
        case .nodeModules: return "network"
        }
    }
}

struct DeveloperItem: Identifiable {
    let id = UUID()
    let name: String
    let category: DeveloperCategory
    let path: String
    let size: UInt64
    var isSelected: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
