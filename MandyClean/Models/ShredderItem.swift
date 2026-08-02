import Foundation

struct ShredderItem: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: UInt64

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
