import Foundation

class ShredderViewModel: ObservableObject {
    @Published var itemsToShred: [ShredderItem] = []
    @Published var isShredding = false
    @Published var statusMessage: String? = nil

    private let service = ShredderService()

    func addFile(at path: String) {
        guard !itemsToShred.contains(where: { $0.path == path }) else { return }
        let name = (path as NSString).lastPathComponent
        let sz = (try? FileManager.default.attributesOfItem(atPath: path)[.size] as? UInt64) ?? 0
        itemsToShred.append(ShredderItem(path: path, name: name, size: sz))
    }

    func removeItem(_ item: ShredderItem) {
        itemsToShred.removeAll { $0.id == item.id }
    }

    func shredAll() {
        guard !itemsToShred.isEmpty else { return }
        isShredding = true
        statusMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var count = 0
            for item in self.itemsToShred {
                if self.service.shredFile(at: item.path) {
                    count += 1
                }
            }

            DispatchQueue.main.async {
                AudioService.shared.playCleanSound()
                self.itemsToShred.removeAll()
                self.isShredding = false
                self.statusMessage = "Permanently shredded \(count) files with DOD multi-pass"
            }
        }
    }
}
