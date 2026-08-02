import Foundation

enum FileCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case videos = "Videos"
    case archives = "Archives"
    case documents = "Documents"
    case audio = "Audio"
    case diskImages = "Disk Images"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "folder.fill"
        case .videos: return "film.fill"
        case .archives: return "archivebox.fill"
        case .documents: return "doc.text.fill"
        case .audio: return "music.note"
        case .diskImages: return "externaldrive.fill"
        case .other: return "doc.fill"
        }
    }

    static func category(for extensionString: String) -> FileCategory {
        let ext = extensionString.lowercased()
        switch ext {
        case "mp4", "mov", "mkv", "avi", "m4v", "webm":
            return .videos
        case "zip", "tar", "gz", "7z", "rar", "bz2", "xz":
            return .archives
        case "pdf", "pages", "docx", "doc", "xlsx", "pptx", "txt", "rtf":
            return .documents
        case "mp3", "wav", "m4a", "flac", "aac", "ogg":
            return .audio
        case "dmg", "iso", "pkg", "img":
            return .diskImages
        default:
            return .other
        }
    }
}

struct LargeFileItem: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: UInt64
    let modificationDate: Date
    let category: FileCategory
    var isSelected: Bool = false

    var sizeFormatted: String {
        RAMInfo.formatBytes(size)
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
}
