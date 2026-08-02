import Foundation
import AppKit

struct InstalledApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let path: String
    let icon: NSImage
    var appSize: UInt64 = 0
    var relatedFiles: [RelatedFile] = []

    var totalSize: UInt64 {
        appSize + relatedFiles.reduce(0) { $0 + $1.size }
    }

    var totalSizeFormatted: String {
        RAMInfo.formatBytes(totalSize)
    }

    var appSizeFormatted: String {
        RAMInfo.formatBytes(appSize)
    }

    static func == (lhs: InstalledApp, rhs: InstalledApp) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct RelatedFile: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: UInt64
    var isSelected: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
