import Foundation

class LanguageStripperViewModel: ObservableObject {
    @Published var items: [LanguagePackItem] = []
    @Published var isScanning = false
    @Published var resultMessage: String? = nil

    private let service = LanguageStripperService()

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
            let res = self.service.scanUnusedLanguagePacks()
            DispatchQueue.main.async {
                self.items = res
                self.isScanning = false
            }
        }
    }

    func toggleItem(_ item: LanguagePackItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isSelected.toggle()
        }
    }

    func removeSelected() {
        let freed = service.removeLanguagePacks(items)
        AudioService.shared.playCleanSound()
        resultMessage = "Removed unused language packs, freed \(RAMInfo.formatBytes(freed))"
        scan()
    }
}
