import Foundation

struct NetworkStats {
    var downloadBytesPerSec: Double = 0
    var uploadBytesPerSec: Double = 0

    var downloadFormatted: String {
        RAMInfo.formatBytes(UInt64(downloadBytesPerSec)) + "/s"
    }

    var uploadFormatted: String {
        RAMInfo.formatBytes(UInt64(uploadBytesPerSec)) + "/s"
    }
}
