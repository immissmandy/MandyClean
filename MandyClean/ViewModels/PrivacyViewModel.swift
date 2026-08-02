import Foundation

class PrivacyViewModel: ObservableObject {
    @Published var items: [PrivacyItem] = []
    @Published var isLoading = false
    @Published var resultMessage: String? = nil

    private let service = PrivacyService()

    var selectedTotalSize: UInt64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.size }
    }

    var selectedTotalSizeFormatted: String {
        RAMInfo.formatBytes(selectedTotalSize)
    }

    init() {
        loadItems()
    }

    func loadItems() {
        isLoading = true
        resultMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.scanPrivacyItems()
            DispatchQueue.main.async {
                self.items = res
                self.isLoading = false
            }
        }
    }

    func toggleItem(_ item: PrivacyItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isSelected.toggle()
        }
    }

    func cleanSelected() {
        let count = service.cleanItems(items)
        AudioService.shared.playCleanSound()
        resultMessage = "Cleaned \(count) privacy trace items"
        loadItems()
    }
}
