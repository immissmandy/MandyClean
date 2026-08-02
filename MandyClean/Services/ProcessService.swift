import Foundation

class ProcessService {

    func fetchProcesses() -> [SystemProcess] {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-axo", "pid=,rss=,%cpu=,comm="]
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        let pattern = #"^\s*(\d+)\s+(\d+)\s+([\d.]+)\s+(.+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        else {
            return []
        }

        var processes: [SystemProcess] = []
        let nsOutput = output as NSString
        let matches = regex.matches(
            in: output, range: NSRange(location: 0, length: nsOutput.length))

        for match in matches {
            guard match.numberOfRanges == 5 else { continue }

            let pidStr = nsOutput.substring(with: match.range(at: 1))
            let rssStr = nsOutput.substring(with: match.range(at: 2))
            let cpuStr = nsOutput.substring(with: match.range(at: 3))
            let commStr = nsOutput.substring(with: match.range(at: 4)).trimmingCharacters(
                in: .whitespaces)

            let pid = Int32(pidStr) ?? 0
            let rss = UInt64(rssStr) ?? 0  // KB from ps
            let cpu = Double(cpuStr) ?? 0
            let name = (commStr as NSString).lastPathComponent

            guard pid > 0, rss > 0 else { continue }

            processes.append(
                SystemProcess(
                    pid: pid,
                    name: name,
                    memoryBytes: rss * 1024,
                    cpuPercent: cpu
                ))
        }

        return processes.sorted { $0.memoryBytes > $1.memoryBytes }
    }
}
