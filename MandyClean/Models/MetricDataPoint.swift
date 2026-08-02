import Foundation

struct MetricDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double  // 0.0 to 100.0 percent
}
