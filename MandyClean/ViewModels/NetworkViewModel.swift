import Foundation

class NetworkViewModel: ObservableObject {
    @Published var stats = NetworkStats()
    private let service = NetworkService()
    private var timer: Timer?

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func update() {
        let res = service.fetchNetworkStats()
        DispatchQueue.main.async {
            self.stats = res
        }
    }
}
