import Foundation

struct LanguagePackItem: Identifiable {
    let id = UUID()
    let appName: String
    let languageCode: String
    let path: String
    let size: UInt64
    var isSelected: Bool = true

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
