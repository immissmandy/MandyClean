import Foundation

struct BenchmarkResult {
    var singleCoreScore: Int = 0
    var multiCoreScore: Int = 0
    var memoryThroughputGBs: Double = 0.0
    var neoPointsScore: Int = 0
    var executionDate: Date = Date()

    var scoreFormatted: String {
        "\(neoPointsScore) NEO-POINTS"
    }
}
