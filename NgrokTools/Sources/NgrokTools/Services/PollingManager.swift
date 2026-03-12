import Foundation

@MainActor
final class PollingManager: ObservableObject {
    @Published private(set) var interval: TimeInterval
    @Published private(set) var isRunning = false

    private var timer: Timer?
    private var action: (@Sendable () -> Void)?

    private let minInterval: TimeInterval = 10.0
    private let maxInterval: TimeInterval = 60.0

    init(interval: TimeInterval = 30.0) {
        self.interval = max(10.0, min(60.0, interval))
    }

    func updateInterval(_ newInterval: TimeInterval) {
        interval = max(minInterval, min(maxInterval, newInterval))
        if isRunning {
            stop()
            if let action = action {
                start(action: action)
            }
        }
    }

    func start(action: @escaping @Sendable () -> Void) {
        self.action = action
        isRunning = true
        let savedAction = action
        let t = Timer(timeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                savedAction()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    static func detectAdded(old: [String], new: [String]) -> [String] {
        let oldSet = Set(old)
        return new.filter { !oldSet.contains($0) }
    }

    static func detectRemoved(old: [String], new: [String]) -> [String] {
        let newSet = Set(new)
        return old.filter { !newSet.contains($0) }
    }
}
