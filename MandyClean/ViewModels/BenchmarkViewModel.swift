import Foundation

class BenchmarkViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var progress: Double = 0.0
    @Published var result: BenchmarkResult? = nil

    private let service = BenchmarkService()

    func runTest() {
        isRunning = true
        progress = 0.0
        result = nil

        service.runBenchmark(progress: { [weak self] p in
            DispatchQueue.main.async {
                self?.progress = p
            }
        }, completion: { [weak self] res in
            self?.result = res
            self?.isRunning = false
            AudioService.shared.playCleanSound()
        })
    }
}
