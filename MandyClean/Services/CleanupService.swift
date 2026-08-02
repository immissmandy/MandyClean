import Foundation

class CleanupService {

    private let fileManager = FileManager.default

    // System Safety Protection Whitelist
    private let protectedPathKeywords = [
        "keychain", "certificates", "identity", "accounts",
        "safari/history", "safari/bookmarks", "login", "auth"
    ]

    // MARK: - Scan All Categories

    func scanAll() -> [CleanupCategory] {
        var categories: [CleanupCategory] = []

        categories.append(scanUserCaches())
        categories.append(scanSystemLogs())
        categories.append(scanBrowserData())
        categories.append(scanTrash())
        categories.append(scanXcodeDerivedData())
        categories.append(scanOldDownloads())

        return categories.filter { !$0.items.isEmpty }
    }

    // MARK: - User Caches (~/Library/Caches)

    private func scanUserCaches() -> CleanupCategory {
        let cachesPath = NSHomeDirectory() + "/Library/Caches"
        let items = scanDirectoryTopLevel(cachesPath)
        return CleanupCategory(
            name: "User Caches",
            icon: "folder.badge.gearshape",
            description: "Application cache files in ~/Library/Caches",
            items: items
        )
    }

    // MARK: - User Logs (~/Library/Logs)

    private func scanSystemLogs() -> CleanupCategory {
        let logsPath = NSHomeDirectory() + "/Library/Logs"
        let items = scanDirectoryTopLevel(logsPath)
        return CleanupCategory(
            name: "User Logs",
            icon: "doc.text",
            description: "Application log files in ~/Library/Logs",
            items: items
        )
    }

    // MARK: - Browser Data

    private func scanBrowserData() -> CleanupCategory {
        var items: [CleanupFile] = []

        let browserCaches = [
            (NSHomeDirectory() + "/Library/Caches/com.apple.Safari", "Safari Cache"),
            (NSHomeDirectory() + "/Library/Caches/Google/Chrome", "Chrome Cache"),
            (NSHomeDirectory() + "/Library/Caches/Firefox", "Firefox Cache"),
            (NSHomeDirectory() + "/Library/Caches/Microsoft Edge", "Edge Cache"),
        ]

        for (path, name) in browserCaches {
            if isWhitelisted(path) { continue }
            let size = directorySize(at: path)
            if size > 0 {
                items.append(CleanupFile(path: path, name: name, size: size))
            }
        }

        return CleanupCategory(
            name: "Browser Caches",
            icon: "globe",
            description: "Cached data from web browsers",
            items: items
        )
    }

    // MARK: - Trash (~/.Trash)

    private func scanTrash() -> CleanupCategory {
        let trashPath = NSHomeDirectory() + "/.Trash"
        let items = scanDirectoryTopLevel(trashPath)
        return CleanupCategory(
            name: "Trash",
            icon: "trash",
            description: "Files in the Trash",
            items: items
        )
    }

    // MARK: - Xcode Derived Data

    private func scanXcodeDerivedData() -> CleanupCategory {
        let derivedDataPath = NSHomeDirectory() + "/Library/Developer/Xcode/DerivedData"
        let items = scanDirectoryTopLevel(derivedDataPath)
        return CleanupCategory(
            name: "Xcode Derived Data",
            icon: "hammer",
            description: "Build artifacts from Xcode projects",
            items: items
        )
    }

    // MARK: - Old Downloads (> 30 days)

    private func scanOldDownloads() -> CleanupCategory {
        let downloadsPath = NSHomeDirectory() + "/Downloads"
        var items: [CleanupFile] = []

        guard let contents = try? fileManager.contentsOfDirectory(atPath: downloadsPath) else {
            return CleanupCategory(
                name: "Old Downloads", icon: "arrow.down.circle",
                description: "Files in Downloads older than 30 days", items: [])
        }

        let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 3600)

        for item in contents {
            guard !item.hasPrefix(".") else { continue }
            let fullPath = (downloadsPath as NSString).appendingPathComponent(item)
            if isWhitelisted(fullPath) { continue }
            
            guard let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
                let modDate = attrs[.modificationDate] as? Date,
                modDate < thirtyDaysAgo
            else { continue }

            let size = directorySize(at: fullPath)
            if size > 0 {
                items.append(CleanupFile(path: fullPath, name: item, size: size))
            }
        }

        return CleanupCategory(
            name: "Old Downloads",
            icon: "arrow.down.circle",
            description: "Files in Downloads older than 30 days",
            items: items
        )
    }

    // MARK: - Helpers

    private func isWhitelisted(_ path: String) -> Bool {
        let lowPath = path.lowercased()
        for keyword in protectedPathKeywords {
            if lowPath.contains(keyword) { return true }
        }
        return false
    }

    private func scanDirectoryTopLevel(_ path: String) -> [CleanupFile] {
        guard fileManager.fileExists(atPath: path),
            let contents = try? fileManager.contentsOfDirectory(atPath: path)
        else { return [] }

        var items: [CleanupFile] = []
        for item in contents {
            guard !item.hasPrefix(".") else { continue }
            let fullPath = (path as NSString).appendingPathComponent(item)
            if isWhitelisted(fullPath) { continue }

            let size = directorySize(at: fullPath)
            if size > 0 {
                items.append(CleanupFile(path: fullPath, name: item, size: size))
            }
        }
        return items
    }

    func directorySize(at path: String) -> UInt64 {
        var totalSize: UInt64 = 0
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }

        if !isDir.boolValue {
            return (try? fileManager.attributesOfItem(atPath: path)[.size] as? UInt64) ?? 0
        }

        guard let enumerator = fileManager.enumerator(atPath: path) else { return 0 }

        while let file = enumerator.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
                let size = attrs[.size] as? UInt64
            {
                totalSize += size
            }
        }

        return totalSize
    }

    // MARK: - Clean

    func cleanItems(_ categories: [CleanupCategory]) -> (deleted: Int, freedBytes: UInt64) {
        var deleted = 0
        var freed: UInt64 = 0

        for category in categories where category.isSelected {
            for item in category.items {
                if isWhitelisted(item.path) { continue }
                do {
                    try fileManager.removeItem(atPath: item.path)
                    deleted += 1
                    freed += item.size
                } catch {
                    // Skip files that can't be deleted
                }
            }
        }

        return (deleted, freed)
    }
}
