import Foundation

struct DuplicateFile: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: UInt64
    let modificationDate: Date
    var isSelected: Bool = false

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let hash: String
    let fileSize: UInt64
    var files: [DuplicateFile]

    var totalWastedSize: UInt64 {
        guard files.count > 1 else { return 0 }
        return fileSize * UInt64(files.count - 1)
    }

    var totalWastedFormatted: String {
        RAMInfo.formatBytes(totalWastedSize)
    }
}
