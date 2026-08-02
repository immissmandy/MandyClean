import Foundation

class DeveloperCleanViewModel: ObservableObject {
    @Published var items: [DeveloperItem] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var resultMessage: String? = nil

    private let service = DeveloperCleanService()

    var selectedTotalSize: UInt64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.size }
    }

    var selectedTotalSizeFormatted: String {
        RAMInfo.formatBytes(selectedTotalSize)
    }

    init() {
        scan()
    }

    func scan() {
        isScanning = true
        resultMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.scanDeveloperItems()
            DispatchQueue.main.async {
                self.items = res
                self.isScanning = false
            }
        }
    }

    func toggleItem(_ item: DeveloperItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isSelected.toggle()
        }
    }

    func cleanSelected() {
        isCleaning = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let freed = self.service.cleanItems(self.items)
            DispatchQueue.main.async {
                AudioService.shared.playCleanSound()
                self.isCleaning = false
                self.resultMessage = "Cleaned developer artifacts, freed \(RAMInfo.formatBytes(freed))"
                self.scan()
            }
        }
    }
}
