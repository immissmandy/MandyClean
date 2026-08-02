import Foundation

class CleanupViewModel: ObservableObject {
    @Published var categories: [CleanupCategory] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var scanComplete = false
    @Published var cleanResult: String?

    private let cleanupService = CleanupService()

    var totalReclaimable: UInt64 {
        categories.filter(\.isSelected).reduce(0) { $0 + $1.totalSize }
    }

    var totalReclaimableFormatted: String {
        RAMInfo.formatBytes(totalReclaimable)
    }

    func scan() {
        isScanning = true
        scanComplete = false
        cleanResult = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let results = self.cleanupService.scanAll()
            DispatchQueue.main.async {
                self.categories = results
                self.isScanning = false
                self.scanComplete = true
            }
        }
    }

    func clean() {
        guard !categories.isEmpty else { return }
        isCleaning = true

        let selectedCategories = categories.filter(\.isSelected)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let result = self.cleanupService.cleanItems(selectedCategories)
            DispatchQueue.main.async {
                self.cleanResult =
                    "Deleted \(result.deleted) items, freed \(RAMInfo.formatBytes(result.freedBytes))"
                self.isCleaning = false
                self.categories = []
                self.scanComplete = false
            }
        }
    }

    func toggleCategory(id: UUID) {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            categories[index].isSelected.toggle()
        }
    }
}
