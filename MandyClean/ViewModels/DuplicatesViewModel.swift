import Foundation

class DuplicatesViewModel: ObservableObject {
    @Published var groups: [DuplicateGroup] = []
    @Published var isScanning = false
    @Published var isDeleting = false
    @Published var resultMessage: String? = nil

    private let service = DuplicatesService()

    var totalSelectedSize: UInt64 {
        var total: UInt64 = 0
        for group in groups {
            for file in group.files where file.isSelected {
                total += file.size
            }
        }
        return total
    }

    var totalSelectedFormatted: String {
        RAMInfo.formatBytes(totalSelectedSize)
    }

    func scan() {
        isScanning = true
        resultMessage = nil
        service.scanDuplicates { [weak self] results in
            guard let self = self else { return }
            self.groups = results
            self.isScanning = false
        }
    }

    func toggleFileSelection(groupIndex: Int, fileIndex: Int) {
        groups[groupIndex].files[fileIndex].isSelected.toggle()
    }

    func deleteSelected() {
        var filesToDelete: [DuplicateFile] = []
        for group in groups {
            for file in group.files where file.isSelected {
                filesToDelete.append(file)
            }
        }

        guard !filesToDelete.isEmpty else { return }
        isDeleting = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let freed = self.service.deleteFiles(filesToDelete)
            DispatchQueue.main.async {
                AudioService.shared.playCleanSound()
                self.isDeleting = false
                self.resultMessage = "Deleted \(filesToDelete.count) duplicate files, freed \(RAMInfo.formatBytes(freed))"
                self.scan() // Rescan
            }
        }
    }
}
