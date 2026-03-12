import XCTest
@testable import NgrokTools

@MainActor
final class PollingManagerTests: XCTestCase {
    func testDefaultInterval() {
        let manager = PollingManager()
        XCTAssertEqual(manager.interval, 30.0)
    }

    func testCustomInterval() {
        let manager = PollingManager(interval: 15.0)
        XCTAssertEqual(manager.interval, 15.0)
    }

    func testUpdateInterval() {
        let manager = PollingManager()
        manager.updateInterval(20.0)
        XCTAssertEqual(manager.interval, 20.0)
    }

    func testIntervalClamping() {
        let manager = PollingManager()
        manager.updateInterval(5.0)
        XCTAssertEqual(manager.interval, 10.0, "Interval should be clamped to minimum 10s")

        manager.updateInterval(120.0)
        XCTAssertEqual(manager.interval, 60.0, "Interval should be clamped to maximum 60s")
    }

    func testIsRunningInitiallyFalse() {
        let manager = PollingManager()
        XCTAssertFalse(manager.isRunning)
    }

    func testStartSetsRunning() {
        let manager = PollingManager()
        manager.start {}
        XCTAssertTrue(manager.isRunning)
        manager.stop()
    }

    func testStopClearsRunning() {
        let manager = PollingManager()
        manager.start {}
        manager.stop()
        XCTAssertFalse(manager.isRunning)
    }

    func testChangeDetection() {
        let oldTunnels = ["tn_1", "tn_2"]
        let newTunnels = ["tn_1", "tn_3"]

        let added = PollingManager.detectAdded(old: oldTunnels, new: newTunnels)
        let removed = PollingManager.detectRemoved(old: oldTunnels, new: newTunnels)

        XCTAssertEqual(added, ["tn_3"])
        XCTAssertEqual(removed, ["tn_2"])
    }
}
