import Foundation

class DeveloperCleanService {
    private let fileManager = FileManager.default

    func scanDeveloperItems() -> [DeveloperItem] {
        var items: [DeveloperItem] = []
        let home = NSHomeDirectory()

        let devPaths: [(String, String, DeveloperCategory)] = [
            ("\(home)/Library/Developer/Xcode/DerivedData", "Xcode DerivedData", .derivedData),
            ("\(home)/Library/Developer/CoreSimulator/Caches", "iOS Simulator Caches", .simulator),
            ("\(home)/Library/Caches/org.swift.swiftpm", "Swift Package Manager Caches", .spm),
            ("\(home)/Library/Caches/CocoaPods", "CocoaPods Cache", .cocoapods)
        ]

        for (path, name, category) in devPaths {
            if fileManager.fileExists(atPath: path) {
                let size = directorySize(at: path)
                if size > 0 {
                    items.append(DeveloperItem(name: name, category: category, path: path, size: size))
                }
            }
        }

        // Scan for node_modules in Documents / Downloads / Projects
        let projectFolders = ["\(home)/Documents", "\(home)/Downloads", "\(home)/Desktop"]
        for folder in projectFolders {
            guard fileManager.fileExists(atPath: folder) else { continue }
            if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: folder), includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                var count = 0
                for case let fileURL as URL in enumerator {
                    count += 1
                    if count > 10000 { break }
                    if fileURL.lastPathComponent == "node_modules" {
                        let size = directorySize(at: fileURL.path)
                        if size > 0 {
                            items.append(DeveloperItem(name: "node_modules (\((fileURL.path as NSString).deletingLastPathComponent.components(separatedBy: "/").last ?? "Project"))", category: .nodeModules, path: fileURL.path, size: size))
                        }
                    }
                }
            }
        }

        return items
    }

    func cleanItems(_ items: [DeveloperItem]) -> UInt64 {
        var freed: UInt64 = 0
        for item in items where item.isSelected {
            do {
                try fileManager.removeItem(atPath: item.path)
                freed += item.size
            } catch {}
        }
        return freed
    }

    private func directorySize(at path: String) -> UInt64 {
        var totalSize: UInt64 = 0
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }
        if !isDir.boolValue {
            return (try? fileManager.attributesOfItem(atPath: path)[.size] as? UInt64) ?? 0
        }
        guard let enumerator = fileManager.enumerator(atPath: path) else { return 0 }
        var count = 0
        while let file = enumerator.nextObject() as? String {
            count += 1
            if count > 5000 { break }
            let full = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: full), let sz = attrs[.size] as? UInt64 {
                totalSize += sz
            }
        }
        return totalSize
    }
}
