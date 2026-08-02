import Foundation
import AppKit

class PrivacyService {
    private let fileManager = FileManager.default

    func scanPrivacyItems() -> [PrivacyItem] {
        var items: [PrivacyItem] = []
        let home = NSHomeDirectory()

        // 1. Terminal History
        let shellHistories = [
            ("\(home)/.zsh_history", "Zsh Command History"),
            ("\(home)/.bash_history", "Bash Command History")
        ]

        for (path, name) in shellHistories {
            if fileManager.fileExists(atPath: path),
               let attrs = try? fileManager.attributesOfItem(atPath: path),
               let size = attrs[.size] as? UInt64, size > 0 {
                items.append(PrivacyItem(name: name, category: .terminal, path: path, description: "Command line shell history logs", size: size))
            }
        }

        // 2. QuickLook Thumbnail Cache
        let qlCachePath = "\(home)/Library/Caches/com.apple.QuickLook.thumbnailcache"
        if fileManager.fileExists(atPath: qlCachePath) {
            let size = directorySize(at: qlCachePath)
            if size > 0 {
                items.append(PrivacyItem(name: "QuickLook Thumbnail Cache", category: .quicklook, path: qlCachePath, description: "Generated image & video thumbnails", size: size))
            }
        }

        // 3. Recent Documents List
        let recentPath = "\(home)/Library/Application Support/com.apple.sharedfilelist"
        if fileManager.fileExists(atPath: recentPath) {
            let size = directorySize(at: recentPath)
            if size > 0 {
                items.append(PrivacyItem(name: "Finder Recent Items", category: .recentDocs, path: recentPath, description: "List of recently opened documents and servers", size: size))
            }
        }

        // 4. System Clipboard
        let pasteboard = NSPasteboard.general
        if let types = pasteboard.types, !types.isEmpty {
            items.append(PrivacyItem(name: "System Clipboard", category: .clipboard, path: "NSPasteboard", description: "Currently copied text or image data", size: 1024))
        }

        return items
    }

    func cleanItems(_ items: [PrivacyItem]) -> Int {
        var cleaned = 0
        for item in items where item.isSelected {
            if item.category == .clipboard {
                NSPasteboard.general.clearContents()
                cleaned += 1
            } else {
                do {
                    try fileManager.removeItem(atPath: item.path)
                    cleaned += 1
                } catch {}
            }
        }
        return cleaned
    }

    private func directorySize(at path: String) -> UInt64 {
        var totalSize: UInt64 = 0
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }
        if !isDir.boolValue {
            return (try? fileManager.attributesOfItem(atPath: path)[.size] as? UInt64) ?? 0
        }
        guard let enumerator = fileManager.enumerator(atPath: path) else { return 0 }
        while let file = enumerator.nextObject() as? String {
            let full = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: full), let sz = attrs[.size] as? UInt64 {
                totalSize += sz
            }
        }
        return totalSize
    }
}
