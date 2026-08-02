import Foundation

struct CleanupCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    var items: [CleanupFile]
    var isSelected: Bool = true

    var totalSize: UInt64 {
        items.reduce(0) { $0 + $1.size }
    }

    var totalSizeFormatted: String {
        RAMInfo.formatBytes(totalSize)
    }
}

struct CleanupFile: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: UInt64

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
