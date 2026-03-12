import XCTest
@testable import NgrokTools

final class KeychainServiceTests: XCTestCase {
    private let testService = "com.letsur.ngrok-tools.test"
    private var sut: KeychainService!

    override func setUp() {
        super.setUp()
        sut = KeychainService(service: testService)
        sut.delete()
    }

    override func tearDown() {
        sut.delete()
        super.tearDown()
    }

    func testSaveAndReadToken() throws {
        let token = "test-api-token-12345"
        let saved = sut.save(token: token)
        XCTAssertTrue(saved, "Token should be saved successfully")

        let retrieved = sut.read()
        XCTAssertEqual(retrieved, token, "Retrieved token should match saved token")
    }

    func testReadReturnsNilWhenNoToken() {
        let retrieved = sut.read()
        XCTAssertNil(retrieved, "Should return nil when no token stored")
    }

    func testDeleteToken() {
        let token = "token-to-delete"
        sut.save(token: token)

        let deleted = sut.delete()
        XCTAssertTrue(deleted, "Token should be deleted successfully")

        let retrieved = sut.read()
        XCTAssertNil(retrieved, "Should return nil after deletion")
    }

    func testSaveOverwritesExistingToken() {
        sut.save(token: "old-token")
        sut.save(token: "new-token")

        let retrieved = sut.read()
        XCTAssertEqual(retrieved, "new-token", "Should return the updated token")
    }
}
