import Foundation

class DiskMapViewModel: ObservableObject {
    @Published var rootNode: DiskNode? = nil
    @Published var selectedNode: DiskNode? = nil
    @Published var isScanning = false

    private let service = DiskMapService()

    func scan() {
        isScanning = true
        service.scanDiskTree { [weak self] root in
            guard let self = self else { return }
            self.rootNode = root
            self.selectedNode = root
            self.isScanning = false
        }
    }
}
