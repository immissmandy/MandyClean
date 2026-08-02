import Foundation

class LargeFilesService {
    private let fileManager = FileManager.default

    func scanLargeFiles(minSizeBytes: UInt64 = 100 * 1024 * 1024, completion: @escaping ([LargeFileItem]) -> Void) {
        let homeDir = NSHomeDirectory()
        let scanPaths = [
            "\(homeDir)/Downloads",
            "\(homeDir)/Documents",
            "\(homeDir)/Desktop",
            "\(homeDir)/Movies",
            "\(homeDir)/Music",
            "\(homeDir)/Pictures",
            "\(homeDir)/Library/Application Support",
            "\(homeDir)/Library/Caches"
        ]

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var results: [LargeFileItem] = []

            for scanPath in scanPaths {
                guard self.fileManager.fileExists(atPath: scanPath) else { continue }
                let items = self.scanDirectory(scanPath, minSize: minSizeBytes)
                results.append(contentsOf: items)
            }

            // Remove duplicates and sort descending by size
            let uniqueResults = Array(Dictionary(grouping: results, by: { $0.path }).values.compactMap { $0.first })
                .sorted { $0.size > $1.size }

            DispatchQueue.main.async {
                completion(uniqueResults)
            }
        }
    }

    private func scanDirectory(_ path: String, minSize: UInt64) -> [LargeFileItem] {
        var items: [LargeFileItem] = []
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey, .isPackageKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }

        var count = 0
        for case let fileURL as URL in enumerator {
            count += 1
            if count > 50000 { break } // Guard against infinite loop

            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey, .isPackageKey]),
                  let isDirectory = resourceValues.isDirectory,
                  let isPackage = resourceValues.isPackage else { continue }

            // If it's a normal directory or package, skip inside
            if isDirectory || isPackage { continue }

            let fileSize = UInt64(resourceValues.fileSize ?? 0)
            if fileSize >= minSize {
                let modDate = resourceValues.contentModificationDate ?? Date()
                let fileName = fileURL.lastPathComponent
                let category = FileCategory.category(for: fileURL.pathExtension)

                items.append(
                    LargeFileItem(
                        path: fileURL.path,
                        name: fileName,
                        size: fileSize,
                        modificationDate: modDate,
                        category: category
                    )
                )
            }
        }

        return items
    }

    func deleteFiles(_ items: [LargeFileItem]) -> (deletedCount: Int, freedBytes: UInt64) {
        var deleted = 0
        var freed: UInt64 = 0

        for item in items {
            do {
                try fileManager.removeItem(atPath: item.path)
                deleted += 1
                freed += item.size
            } catch {
                // Ignore items that fail to delete
            }
        }

        return (deleted, freed)
    }
}
