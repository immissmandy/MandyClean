import Foundation

class HardwareViewModel: ObservableObject {
    @Published var info = HardwareInfo()
    @Published var isLoading = false

    private let service = HardwareService()

    init() {
        loadInfo()
    }

    func loadInfo() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let res = self.service.fetchHardwareInfo()
            DispatchQueue.main.async {
                self.info = res
                self.isLoading = false
            }
        }
    }
}
