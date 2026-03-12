import XCTest
@testable import NgrokTools

final class NotificationServiceTests: XCTestCase {
    func testSharedInstanceExists() {
        let service = NotificationService.shared
        XCTAssertNotNil(service)
    }

    func testSharedIsSingleton() {
        let a = NotificationService.shared
        let b = NotificationService.shared
        XCTAssertTrue(a === b)
    }
}
