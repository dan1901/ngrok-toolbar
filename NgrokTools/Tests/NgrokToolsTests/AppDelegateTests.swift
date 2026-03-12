import XCTest
@testable import NgrokTools

final class AppDelegateTests: XCTestCase {
    func testUpdateBadgeWithPositiveCount() {
        let delegate = AppDelegate()
        delegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        delegate.updateBadge(count: 3)
        // Badge update runs without crash - functional test via UI
    }

    func testUpdateBadgeWithZeroCount() {
        let delegate = AppDelegate()
        delegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        delegate.updateBadge(count: 0)
    }
}
