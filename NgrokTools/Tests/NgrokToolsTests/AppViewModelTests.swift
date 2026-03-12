import XCTest
@testable import NgrokTools

@MainActor
final class AppViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = AppViewModel()
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertEqual(vm.activeTunnelCount, 0)
        XCTAssertFalse(vm.showSettings)
    }

    func testSetupWithTokenSetsAuthenticated() {
        let vm = AppViewModel()
        vm.setupWithToken("test-token-123")
        XCTAssertTrue(vm.isAuthenticated)
    }

    func testCleanupStopsPolling() {
        let vm = AppViewModel()
        vm.setupWithToken("test-token")
        XCTAssertTrue(vm.pollingManager.isRunning)
        vm.cleanup()
        XCTAssertFalse(vm.pollingManager.isRunning)
    }

    func testDashboardViewModelExists() {
        let vm = AppViewModel()
        XCTAssertNotNil(vm.dashboardViewModel)
    }

    func testPollingManagerExists() {
        let vm = AppViewModel()
        XCTAssertNotNil(vm.pollingManager)
    }
}
