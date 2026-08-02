import Foundation

class LanguageStripperService {
    private let fileManager = FileManager.default

    private let keepLanguages = ["en.lproj", "de.lproj", "Base.lproj"]

    func scanUnusedLanguagePacks() -> [LanguagePackItem] {
        var items: [LanguagePackItem] = []
        let appsPath = "/Applications"

        guard let contents = try? fileManager.contentsOfDirectory(atPath: appsPath) else { return [] }

        for app in contents where app.hasSuffix(".app") {
            let appPath = (appsPath as NSString).appendingPathComponent(app)
            let resourcesPath = "\(appPath)/Contents/Resources"

            guard fileManager.fileExists(atPath: resourcesPath),
                  let resContents = try? fileManager.contentsOfDirectory(atPath: resourcesPath) else { continue }

            for resItem in resContents where resItem.hasSuffix(".lproj") {
                if keepLanguages.contains(resItem) { continue }

                let fullPath = (resourcesPath as NSString).appendingPathComponent(resItem)
                let sz = directorySize(at: fullPath)
                if sz > 0 {
                    let appName = (app as NSString).deletingPathExtension
                    items.append(LanguagePackItem(appName: appName, languageCode: resItem, path: fullPath, size: sz, isSelected: true))
                }
            }
        }

        return items
    }

    func removeLanguagePacks(_ items: [LanguagePackItem]) -> UInt64 {
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
        while let file = enumerator.nextObject() as? String {
            let full = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: full), let sz = attrs[.size] as? UInt64 {
                totalSize += sz
            }
        }
        return totalSize
    }
}
