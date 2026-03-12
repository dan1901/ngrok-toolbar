import XCTest
@testable import NgrokTools

final class ConfigParserTests: XCTestCase {
    func testParseAuthtokenFromYAML() {
        let yaml = """
        version: "2"
        authtoken: 2abc123def456_TESTTOKEN
        region: us
        """
        let token = ConfigParser.parseAuthtoken(from: yaml)
        XCTAssertEqual(token, "2abc123def456_TESTTOKEN")
    }

    func testParseAuthtokenWithQuotes() {
        let yaml = """
        authtoken: "quoted-token-value"
        """
        let token = ConfigParser.parseAuthtoken(from: yaml)
        XCTAssertEqual(token, "quoted-token-value")
    }

    func testParseAuthtokenReturnsNilWhenMissing() {
        let yaml = """
        version: "2"
        region: us
        """
        let token = ConfigParser.parseAuthtoken(from: yaml)
        XCTAssertNil(token)
    }

    func testParseAuthtokenFromEmptyString() {
        let token = ConfigParser.parseAuthtoken(from: "")
        XCTAssertNil(token)
    }

    func testConfigPathCandidates() {
        let paths = ConfigParser.configPathCandidates()
        XCTAssertFalse(paths.isEmpty)
        XCTAssertTrue(paths.contains { $0.contains("ngrok") })
    }
}
