import Foundation

class OrganizerService {
    private let fileManager = FileManager.default

    func scanItemsToOrganize() -> [OrganizeItem] {
        var items: [OrganizeItem] = []
        let home = NSHomeDirectory()
        let desktop = "\(home)/Desktop"
        let downloads = "\(home)/Downloads"

        // 1. Desktop Screenshots
        if let contents = try? fileManager.contentsOfDirectory(atPath: desktop) {
            for file in contents {
                if file.lowercased().contains("screenshot") || file.lowercased().contains("bildschirmfoto") {
                    let full = (desktop as NSString).appendingPathComponent(file)
                    let sz = (try? fileManager.attributesOfItem(atPath: full)[.size] as? UInt64) ?? 0
                    items.append(OrganizeItem(name: file, path: full, isScreenshot: true, size: sz))
                }
            }
        }

        // 2. Downloads Installers / DMGs
        if let contents = try? fileManager.contentsOfDirectory(atPath: downloads) {
            for file in contents {
                let ext = (file as NSString).pathExtension.lowercased()
                if ext == "dmg" || ext == "pkg" || ext == "iso" {
                    let full = (downloads as NSString).appendingPathComponent(file)
                    let sz = (try? fileManager.attributesOfItem(atPath: full)[.size] as? UInt64) ?? 0
                    items.append(OrganizeItem(name: file, path: full, isScreenshot: false, size: sz))
                }
            }
        }

        return items
    }

    func organizeItems(_ items: [OrganizeItem]) -> Int {
        var moved = 0
        let home = NSHomeDirectory()
        let picturesScreenshots = "\(home)/Pictures/Screenshots Archive"
        let downloadsInstallers = "\(home)/Downloads/Disk Images Archive"

        try? fileManager.createDirectory(atPath: picturesScreenshots, withIntermediateDirectories: true)
        try? fileManager.createDirectory(atPath: downloadsInstallers, withIntermediateDirectories: true)

        for item in items where item.isSelected {
            let destFolder = item.isScreenshot ? picturesScreenshots : downloadsInstallers
            let destPath = (destFolder as NSString).appendingPathComponent(item.name)
            do {
                try fileManager.moveItem(atPath: item.path, toPath: destPath)
                moved += 1
            } catch {}
        }
        return moved
    }
}
