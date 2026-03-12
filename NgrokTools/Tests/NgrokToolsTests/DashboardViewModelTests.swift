import XCTest
@testable import NgrokTools

@MainActor
final class DashboardViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = DashboardViewModel()
        XCTAssertTrue(vm.tunnels.isEmpty)
        XCTAssertTrue(vm.sessions.isEmpty)
        XCTAssertTrue(vm.endpoints.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testConfigureSetsUpServices() {
        let vm = DashboardViewModel()
        let client = NgrokAPIClient(token: "test-token")
        vm.configure(with: client)
        // No crash = services configured correctly
    }
}
