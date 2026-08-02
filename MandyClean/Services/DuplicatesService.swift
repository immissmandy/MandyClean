import Foundation
import CryptoKit

class DuplicatesService {
    private let fileManager = FileManager.default

    func scanDuplicates(completion: @escaping ([DuplicateGroup]) -> Void) {
        let home = NSHomeDirectory()
        let scanFolders = [
            "\(home)/Downloads",
            "\(home)/Documents",
            "\(home)/Pictures",
            "\(home)/Movies",
            "\(home)/Desktop"
        ]

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var filesBySize: [UInt64: [String]] = [:]

            for folder in scanFolders {
                guard self.fileManager.fileExists(atPath: folder) else { continue }
                if let enumerator = self.fileManager.enumerator(at: URL(fileURLWithPath: folder), includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    var count = 0
                    for case let fileURL as URL in enumerator {
                        count += 1
                        if count > 20000 { break }
                        guard let vals = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey]),
                              let isDir = vals.isDirectory, !isDir,
                              let size = vals.fileSize, size > 100 * 1024 else { continue } // > 100 KB

                        let uSize = UInt64(size)
                        filesBySize[uSize, default: []].append(fileURL.path)
                    }
                }
            }

            // Keep sizes with > 1 file
            let potentialDuplicates = filesBySize.filter { $0.value.count > 1 }

            var groups: [DuplicateGroup] = []

            for (size, paths) in potentialDuplicates {
                var hashDict: [String: [DuplicateFile]] = [:]
                for path in paths {
                    guard let hash = self.computeSHA256(at: path),
                          let attrs = try? self.fileManager.attributesOfItem(atPath: path),
                          let modDate = attrs[.modificationDate] as? Date else { continue }

                    let name = (path as NSString).lastPathComponent
                    let file = DuplicateFile(path: path, name: name, size: size, modificationDate: modDate, isSelected: false)
                    hashDict[hash, default: []].append(file)
                }

                for (hash, files) in hashDict where files.count > 1 {
                    var sortedFiles = files.sorted { $0.modificationDate < $1.modificationDate }
                    // Smart select: select all except oldest (first)
                    for i in 1..<sortedFiles.count {
                        sortedFiles[i].isSelected = true
                    }
                    groups.append(DuplicateGroup(hash: hash, fileSize: size, files: sortedFiles))
                }
            }

            let sortedGroups = groups.sorted { $0.totalWastedSize > $1.totalWastedSize }

            DispatchQueue.main.async {
                completion(sortedGroups)
            }
        }
    }

    private func computeSHA256(at path: String) -> String? {
        guard let data = fileManager.contents(atPath: path) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func deleteFiles(_ files: [DuplicateFile]) -> UInt64 {
        var freed: UInt64 = 0
        for file in files {
            do {
                try fileManager.removeItem(atPath: file.path)
                freed += file.size
            } catch {}
        }
        return freed
    }
}
