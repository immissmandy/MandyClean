import Foundation

class ExtensionsViewModel: ObservableObject {
    @Published var items: [SystemExtensionItem] = []
    @Published var isLoading = false
    @Published var selectedCategory: ExtensionCategory = .preferencePane
    @Published var statusMessage: String? = nil

    private let service = ExtensionsService()

    var filteredItems: [SystemExtensionItem] {
        items.filter { $0.category == selectedCategory }
    }

    init() {
        loadItems()
    }

    func loadItems() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.fetchExtensions()
            DispatchQueue.main.async {
                self.items = res
                self.isLoading = false
            }
        }
    }

    func deleteExtension(_ item: SystemExtensionItem) {
        if service.deleteExtension(item) {
            items.removeAll { $0.id == item.id }
            statusMessage = "Deleted extension \(item.name)"
        } else {
            statusMessage = "Failed to delete extension"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusMessage = nil
        }
    }
}
