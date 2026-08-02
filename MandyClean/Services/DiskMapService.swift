import Foundation
import SwiftUI

class DiskMapService {
    private let fileManager = FileManager.default

    private let colors: [Color] = [.neoYellow, .neoPink, .neoCyan, .neoLime, .neoOrange, .neoPurple]

    func scanDiskTree(completion: @escaping (DiskNode?) -> Void) {
        let homePath = NSHomeDirectory()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let root = self.buildNode(at: homePath, depth: 0)
            DispatchQueue.main.async {
                completion(root)
            }
        }
    }

    private func buildNode(at path: String, depth: Int) -> DiskNode {
        let name = (path as NSString).lastPathComponent
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else {
            return DiskNode(name: name, path: path, size: 0, isDirectory: false, children: nil, color: colors[depth % colors.count])
        }

        if !isDir.boolValue || depth >= 2 {
            let size = directorySize(at: path)
            return DiskNode(name: name, path: path, size: size, isDirectory: isDir.boolValue, children: nil, color: colors[depth % colors.count])
        }

        var children: [DiskNode] = []
        var totalSize: UInt64 = 0

        if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
            for item in contents {
                if item.hasPrefix(".") { continue }
                let fullPath = (path as NSString).appendingPathComponent(item)
                let childNode = buildNode(at: fullPath, depth: depth + 1)
                if childNode.size > 10 * 1024 * 1024 { // > 10 MB
                    children.append(childNode)
                }
                totalSize += childNode.size
            }
        }

        children.sort { $0.size > $1.size }

        return DiskNode(
            name: name,
            path: path,
            size: totalSize,
            isDirectory: true,
            children: children.isEmpty ? nil : children,
            color: colors[depth % colors.count]
        )
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
