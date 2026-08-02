import AppKit
import Foundation

class AudioService {
    static let shared = AudioService()

    private init() {}

    func playCleanSound() {
        NSSound.beep()
    }
}
