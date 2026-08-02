import Foundation

class AutostartService {
    private let fileManager = FileManager.default

    func fetchLaunchItems() -> [LaunchItem] {
        var items: [LaunchItem] = []

        for itemType in LaunchItemType.allCases {
            let path = itemType.path
            guard fileManager.fileExists(atPath: path),
                  let files = try? fileManager.contentsOfDirectory(atPath: path) else {
                continue
            }

            for file in files where file.hasSuffix(".plist") {
                let fullPath = (path as NSString).appendingPathComponent(file)
                if let item = parsePlist(at: fullPath, type: itemType) {
                    items.append(item)
                }
            }
        }

        return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func parsePlist(at path: String, type: LaunchItemType) -> LaunchItem? {
        guard let data = fileManager.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }

        let label = plist["Label"] as? String ?? (path as NSString).lastPathComponent
        let name = label.components(separatedBy: ".").last ?? label
        let disabled = plist["Disabled"] as? Bool ?? false
        let isEnabled = !disabled

        var programPath: String? = nil
        if let prog = plist["Program"] as? String {
            programPath = prog
        } else if let args = plist["ProgramArguments"] as? [String], let first = args.first {
            programPath = first
        }

        return LaunchItem(
            name: name.capitalized,
            label: label,
            path: path,
            type: type,
            isEnabled: isEnabled,
            programPath: programPath
        )
    }

    func toggleLaunchItem(_ item: LaunchItem) -> Bool {
        let disabledPath = item.path + ".disabled"
        do {
            if item.isEnabled {
                // Disable by renaming .plist to .plist.disabled
                try fileManager.moveItem(atPath: item.path, toPath: disabledPath)
            } else {
                // Enable by renaming back
                let enabledPath = item.path.replacingOccurrences(of: ".disabled", with: "")
                try fileManager.moveItem(atPath: item.path, toPath: enabledPath)
            }
            return true
        } catch {
            return false
        }
    }

    func deleteLaunchItem(_ item: LaunchItem) -> Bool {
        do {
            try fileManager.removeItem(atPath: item.path)
            return true
        } catch {
            return false
        }
    }
}
