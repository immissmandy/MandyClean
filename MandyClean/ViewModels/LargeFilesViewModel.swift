import Foundation

class LargeFilesViewModel: ObservableObject {
    @Published var items: [LargeFileItem] = []
    @Published var isScanning = false
    @Published var isDeleting = false
    @Published var searchText = ""
    @Published var selectedCategory: FileCategory = .all
    @Published var minSizeMB: Double = 100 // 100 MB default
    @Published var resultMessage: String? = nil

    private let service = LargeFilesService()

    var filteredItems: [LargeFileItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == .all || item.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var selectedTotalSize: UInt64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.size }
    }

    var selectedTotalSizeFormatted: String {
        RAMInfo.formatBytes(selectedTotalSize)
    }

    func scan() {
        isScanning = true
        resultMessage = nil
        let minBytes = UInt64(minSizeMB * 1024 * 1024)

        service.scanLargeFiles(minSizeBytes: minBytes) { [weak self] results in
            guard let self = self else { return }
            self.items = results
            self.isScanning = false
        }
    }

    func toggleItemSelection(_ item: LargeFileItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isSelected.toggle()
        }
    }

    func selectAll(_ select: Bool) {
        for i in items.indices {
            items[i].isSelected = select
        }
    }

    func deleteSelected() {
        let selected = items.filter(\.isSelected)
        guard !selected.isEmpty else { return }
        isDeleting = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.deleteFiles(selected)
            DispatchQueue.main.async {
                self.items.removeAll(where: { $0.isSelected })
                self.isDeleting = false
                self.resultMessage = "Deleted \(res.deletedCount) files, freed \(RAMInfo.formatBytes(res.freedBytes))"

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.resultMessage = nil
                }
            }
        }
    }
}
