import Foundation
import SwiftUI

struct DiskNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let size: UInt64
    let isDirectory: Bool
    var children: [DiskNode]?
    let color: Color

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }
}
