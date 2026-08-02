import Foundation

class ExtensionsService {
    private let fileManager = FileManager.default

    func fetchExtensions() -> [SystemExtensionItem] {
        var items: [SystemExtensionItem] = []
        let home = NSHomeDirectory()

        let extensionFolders: [(String, ExtensionCategory)] = [
            ("\(home)/Library/PreferencePanes", .preferencePane),
            ("/Library/PreferencePanes", .preferencePane),
            ("\(home)/Library/QuickLook", .quickLook),
            ("/Library/QuickLook", .quickLook),
            ("\(home)/Library/Spotlight", .spotlight),
            ("/Library/Spotlight", .spotlight)
        ]

        for (path, category) in extensionFolders {
            guard fileManager.fileExists(atPath: path),
                  let contents = try? fileManager.contentsOfDirectory(atPath: path) else { continue }

            for file in contents {
                if file.hasPrefix(".") { continue }
                let fullPath = (path as NSString).appendingPathComponent(file)
                let name = ((file as NSString).deletingPathExtension as NSString).lastPathComponent
                let size = directorySize(at: fullPath)

                items.append(SystemExtensionItem(name: name, category: category, path: fullPath, size: size, isEnabled: true))
            }
        }

        return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func deleteExtension(_ item: SystemExtensionItem) -> Bool {
        do {
            try fileManager.removeItem(atPath: item.path)
            return true
        } catch {
            return false
        }
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
