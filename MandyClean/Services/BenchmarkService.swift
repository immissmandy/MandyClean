import Foundation

class BenchmarkService {
    func runBenchmark(progress: @escaping (Double) -> Void, completion: @escaping (BenchmarkResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            progress(0.1)

            // 1. Single Core CPU Compute Benchmark
            let startSingle = Date()
            var countSingle = 0
            for i in 0..<50000000 {
                countSingle += (i * 3) % 7
            }
            let durationSingle = max(Date().timeIntervalSince(startSingle), 0.001)
            let singleScore = Int(50.0 / durationSingle * 100)

            progress(0.5)

            // 2. Multi-Threaded CPU Compute Benchmark
            let startMulti = Date()
            let group = DispatchGroup()
            let cores = ProcessInfo.processInfo.processorCount

            for _ in 0..<cores {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    var innerCount = 0
                    for j in 0..<30000000 {
                        innerCount += (j * 5) % 11
                    }
                    group.leave()
                }
            }
            group.wait()

            let durationMulti = max(Date().timeIntervalSince(startMulti), 0.001)
            let multiScore = Int((30.0 * Double(cores)) / durationMulti * 120)

            progress(0.8)

            // 3. Memory Throughput Test
            let arraySize = 10 * 1024 * 1024
            var testArray = [Int](repeating: 42, count: arraySize)
            let startMem = Date()
            for i in 0..<arraySize {
                testArray[i] = i &+ 1
            }
            let durationMem = max(Date().timeIntervalSince(startMem), 0.001)
            let bytesWritten = Double(arraySize * MemoryLayout<Int>.size)
            let throughputGBs = (bytesWritten / (1024 * 1024 * 1024)) / durationMem

            progress(1.0)

            let totalNeoPoints = singleScore + multiScore + Int(throughputGBs * 500)

            let result = BenchmarkResult(
                singleCoreScore: singleScore,
                multiCoreScore: multiScore,
                memoryThroughputGBs: throughputGBs,
                neoPointsScore: totalNeoPoints,
                executionDate: Date()
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
