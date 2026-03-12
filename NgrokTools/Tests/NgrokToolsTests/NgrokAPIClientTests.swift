import XCTest
@testable import NgrokTools

final class NgrokAPIClientTests: XCTestCase {
    func testBaseURLIsCorrect() {
        let client = NgrokAPIClient(token: "test-token")
        XCTAssertEqual(client.baseURL.absoluteString, "https://api.ngrok.com")
    }

    func testBuildRequestSetsAuthorizationHeader() throws {
        let client = NgrokAPIClient(token: "my-test-token")
        let request = try client.buildRequest(path: "/tunnels", method: "GET")

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer my-test-token")
    }

    func testBuildRequestSetsNgrokVersionHeader() throws {
        let client = NgrokAPIClient(token: "test")
        let request = try client.buildRequest(path: "/tunnels", method: "GET")

        XCTAssertEqual(request.value(forHTTPHeaderField: "Ngrok-Version"), "2")
    }

    func testBuildRequestSetsContentTypeHeader() throws {
        let client = NgrokAPIClient(token: "test")
        let request = try client.buildRequest(path: "/tunnels", method: "GET")

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testBuildRequestConstructsCorrectURL() throws {
        let client = NgrokAPIClient(token: "test")
        let request = try client.buildRequest(path: "/tunnels", method: "GET")

        XCTAssertEqual(request.url?.absoluteString, "https://api.ngrok.com/tunnels")
    }

    func testBuildRequestSetsHTTPMethod() throws {
        let client = NgrokAPIClient(token: "test")
        let postRequest = try client.buildRequest(path: "/tunnel_sessions/123/stop", method: "POST")

        XCTAssertEqual(postRequest.httpMethod, "POST")
    }

    func testBuildRequestWithBody() throws {
        let client = NgrokAPIClient(token: "test")
        let body = ["key": "value"]
        let request = try client.buildRequest(path: "/endpoints", method: "POST", body: body)

        XCTAssertNotNil(request.httpBody)
        let decoded = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String]
        XCTAssertEqual(decoded?["key"], "value")
    }

    func testAPIErrorDecoding() throws {
        let json = """
        {"msg": "Not Found", "status_code": 404}
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(NgrokAPIError.self, from: json)
        XCTAssertEqual(error.msg, "Not Found")
        XCTAssertEqual(error.statusCode, 404)
    }
}
