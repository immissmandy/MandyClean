import AppKit
import Foundation

class AppUninstallerService {

    private let fileManager = FileManager.default

    // MARK: - Scan Installed Apps

    func getInstalledApps() -> [InstalledApp] {
        var apps: [InstalledApp] = []
        let appDirs = ["/Applications", NSHomeDirectory() + "/Applications"]

        for dir in appDirs {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: dir) else {
                continue
            }

            for item in contents where item.hasSuffix(".app") {
                let appPath = (dir as NSString).appendingPathComponent(item)
                if let app = createAppInfo(at: appPath) {
                    apps.append(app)
                }
            }
        }

        return apps.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private func createAppInfo(at path: String) -> InstalledApp? {
        let plistPath = (path as NSString).appendingPathComponent("Contents/Info.plist")

        guard let plistData = fileManager.contents(atPath: plistPath),
            let plist = try? PropertyListSerialization.propertyList(
                from: plistData, format: nil) as? [String: Any]
        else {
            return nil
        }

        let bundleID = plist["CFBundleIdentifier"] as? String ?? ""
        let name =
            plist["CFBundleName"] as? String
            ?? plist["CFBundleDisplayName"] as? String
            ?? ((path as NSString).lastPathComponent as NSString).deletingPathExtension

        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 64, height: 64)

        return InstalledApp(
            name: name,
            bundleIdentifier: bundleID,
            path: path,
            icon: icon
        )
    }

    // MARK: - Find Related Files

    func findRelatedFiles(for app: InstalledApp) -> [RelatedFile] {
        var files: [RelatedFile] = []
        let home = NSHomeDirectory()
        let bundleID = app.bundleIdentifier
        let appName = app.name

        guard !bundleID.isEmpty else { return [] }

        let searchPaths = [
            "\(home)/Library/Application Support",
            "\(home)/Library/Caches",
            "\(home)/Library/Preferences",
            "\(home)/Library/Containers",
            "\(home)/Library/Saved Application State",
            "\(home)/Library/HTTPStorages",
            "\(home)/Library/WebKit",
            "\(home)/Library/Cookies",
            "\(home)/Library/Group Containers",
        ]

        for searchPath in searchPaths {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: searchPath) else {
                continue
            }

            for item in contents {
                let lowItem = item.lowercased()
                let lowBundleID = bundleID.lowercased()
                let lowAppName = appName.lowercased()

                if lowItem.contains(lowBundleID) || lowItem.contains(lowAppName) {
                    let fullPath = (searchPath as NSString).appendingPathComponent(item)
                    let size = directorySize(at: fullPath)
                    files.append(
                        RelatedFile(
                            path: fullPath,
                            name: item,
                            size: size
                        ))
                }
            }
        }

        // Preferences plist
        let prefsPlist = "\(home)/Library/Preferences/\(bundleID).plist"
        if fileManager.fileExists(atPath: prefsPlist) {
            let size =
                (try? fileManager.attributesOfItem(atPath: prefsPlist)[.size] as? UInt64) ?? 0
            // Avoid duplicate if already found in directory scan
            if !files.contains(where: { $0.path == prefsPlist }) {
                files.append(
                    RelatedFile(path: prefsPlist, name: "\(bundleID).plist", size: size))
            }
        }

        return files
    }

    // MARK: - Uninstall (moves to Trash for safety)

    func uninstallApp(_ app: InstalledApp, removeRelatedFiles: Bool) -> Bool {
        do {
            var trashedURL: NSURL?
            try fileManager.trashItem(
                at: URL(fileURLWithPath: app.path), resultingItemURL: &trashedURL)

            if removeRelatedFiles {
                for file in app.relatedFiles where file.isSelected {
                    try? fileManager.trashItem(
                        at: URL(fileURLWithPath: file.path), resultingItemURL: nil)
                }
            }

            return true
        } catch {
            return false
        }
    }

    // MARK: - Helpers

    func calculateAppSize(at path: String) -> UInt64 {
        return directorySize(at: path)
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
            let fullPath = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
                let size = attrs[.size] as? UInt64
            {
                totalSize += size
            }
        }

        return totalSize
    }
}
