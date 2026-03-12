import XCTest
@testable import NgrokTools

@MainActor
final class AppDelegateTests: XCTestCase {
    func testAppDelegateCreation() {
        // Verify AppDelegate can be instantiated
        let delegate = AppDelegate()
        XCTAssertNotNil(delegate)
    }

    func testUpdateBadgeWithoutSetup() {
        // updateBadge should handle nil statusItem gracefully
        let delegate = AppDelegate()
        delegate.updateBadge(count: 3)
        delegate.updateBadge(count: 0)
        // No crash = pass (statusItem is nil without applicationDidFinishLaunching)
    }
}
