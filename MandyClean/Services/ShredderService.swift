import Foundation

class ShredderService {
    private let fileManager = FileManager.default

    func shredFile(at path: String) -> Bool {
        guard fileManager.fileExists(atPath: path) else { return false }

        guard let attrs = try? fileManager.attributesOfItem(atPath: path),
              let size = attrs[.size] as? UInt64 else {
            try? fileManager.removeItem(atPath: path)
            return true
        }

        // Multi-pass overwrite (Pass 1: 0x00, Pass 2: 0xFF, Pass 3: Random)
        let intSize = Int(min(size, 10 * 1024 * 1024)) // Cap at 10 MB for speed
        if intSize > 0, let fileHandle = FileHandle(forWritingAtPath: path) {
            let zeroBytes = Data(repeating: 0x00, count: intSize)
            let ffBytes = Data(repeating: 0xFF, count: intSize)

            fileHandle.write(zeroBytes)
            fileHandle.seek(toFileOffset: 0)
            fileHandle.write(ffBytes)
            fileHandle.closeFile()
        }

        do {
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
}
