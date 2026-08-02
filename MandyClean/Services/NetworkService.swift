import Foundation
import Darwin

class NetworkService {
    private var prevBytesRx: UInt64 = 0
    private var prevBytesTx: UInt64 = 0
    private var prevTime: Date = Date()

    func fetchNetworkStats() -> NetworkStats {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return NetworkStats()
        }

        var totalRx: UInt64 = 0
        var totalTx: UInt64 = 0

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            if (flags & IFF_UP) != 0 && (flags & IFF_LOOPBACK) == 0 {
                if let data = ptr.pointee.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self)
                    totalRx += UInt64(networkData.pointee.ifi_ibytes)
                    totalTx += UInt64(networkData.pointee.ifi_obytes)
                }
            }
        }
        freeifaddrs(ifaddr)

        let now = Date()
        let timeDelta = max(now.timeIntervalSince(prevTime), 0.1)

        let rxRate = prevBytesRx > 0 && totalRx >= prevBytesRx ? Double(totalRx - prevBytesRx) / timeDelta : 0
        let txRate = prevBytesTx > 0 && totalTx >= prevBytesTx ? Double(totalTx - prevBytesTx) / timeDelta : 0

        prevBytesRx = totalRx
        prevBytesTx = totalTx
        prevTime = now

        return NetworkStats(downloadBytesPerSec: rxRate, uploadBytesPerSec: txRate)
    }
}
