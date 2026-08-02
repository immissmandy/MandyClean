import Foundation

class AutostartViewModel: ObservableObject {
    @Published var items: [LaunchItem] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedType: LaunchItemType? = nil
    @Published var statusMessage: String? = nil

    private let service = AutostartService()

    var filteredItems: [LaunchItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.label.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedType == nil || item.type == selectedType
            return matchesSearch && matchesType
        }
    }

    init() {
        loadItems()
    }

    func loadItems() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let result = self.service.fetchLaunchItems()
            DispatchQueue.main.async {
                self.items = result
                self.isLoading = false
            }
        }
    }

    func toggleItem(_ item: LaunchItem) {
        if service.toggleLaunchItem(item) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isEnabled.toggle()
            }
            statusMessage = "Updated autostart item"
        } else {
            statusMessage = "Failed to update item (permission required)"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusMessage = nil
        }
    }

    func deleteItem(_ item: LaunchItem) {
        if service.deleteLaunchItem(item) {
            items.removeAll { $0.id == item.id }
            statusMessage = "Removed \(item.name)"
        } else {
            statusMessage = "Failed to remove item"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusMessage = nil
        }
    }
}
