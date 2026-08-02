import Foundation

class OrganizerViewModel: ObservableObject {
    @Published var items: [OrganizeItem] = []
    @Published var isLoading = false
    @Published var resultMessage: String? = nil

    private let service = OrganizerService()

    init() {
        loadItems()
    }

    func loadItems() {
        isLoading = true
        resultMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.scanItemsToOrganize()
            DispatchQueue.main.async {
                self.items = res
                self.isLoading = false
            }
        }
    }

    func toggleItem(_ item: OrganizeItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isSelected.toggle()
        }
    }

    func organizeSelected() {
        let count = service.organizeItems(items)
        AudioService.shared.playCleanSound()
        resultMessage = "Organized \(count) files into Pictures & Downloads archives"
        loadItems()
    }
}
