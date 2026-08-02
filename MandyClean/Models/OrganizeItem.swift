import Foundation

struct OrganizeItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let isScreenshot: Bool
    let size: UInt64
    var isSelected: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
