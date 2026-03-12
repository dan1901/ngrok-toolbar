import XCTest
@testable import NgrokTools

final class ModelsTests: XCTestCase {

    // MARK: - Tunnel

    func testTunnelDecoding() throws {
        let json = """
        {
            "id": "tn_abc123",
            "public_url": "https://example.ngrok.io",
            "started_at": "2026-03-12T10:00:00Z",
            "proto": "https",
            "region": "us",
            "forwards_to": "localhost:8080",
            "metadata": ""
        }
        """.data(using: .utf8)!

        let tunnel = try JSONDecoder().decode(Tunnel.self, from: json)
        XCTAssertEqual(tunnel.id, "tn_abc123")
        XCTAssertEqual(tunnel.publicURL, "https://example.ngrok.io")
        XCTAssertEqual(tunnel.proto, "https")
        XCTAssertEqual(tunnel.region, "us")
        XCTAssertEqual(tunnel.forwardsTo, "localhost:8080")
    }

    func testTunnelListDecoding() throws {
        let json = """
        {
            "tunnels": [
                {
                    "id": "tn_1",
                    "public_url": "https://a.ngrok.io",
                    "started_at": "2026-03-12T10:00:00Z",
                    "proto": "https",
                    "region": "us"
                }
            ],
            "next_page_uri": null
        }
        """.data(using: .utf8)!

        let list = try JSONDecoder().decode(TunnelList.self, from: json)
        XCTAssertEqual(list.tunnels.count, 1)
        XCTAssertNil(list.nextPageURI)
    }

    // MARK: - TunnelSession

    func testTunnelSessionDecoding() throws {
        let json = """
        {
            "id": "ts_abc123",
            "agent_version": "3.5.0",
            "ip": "192.168.1.1",
            "region": "us",
            "started_at": "2026-03-12T10:00:00Z",
            "os": "darwin",
            "transport": "ngrok/v2"
        }
        """.data(using: .utf8)!

        let session = try JSONDecoder().decode(TunnelSession.self, from: json)
        XCTAssertEqual(session.id, "ts_abc123")
        XCTAssertEqual(session.agentVersion, "3.5.0")
        XCTAssertEqual(session.ip, "192.168.1.1")
        XCTAssertEqual(session.os, "darwin")
    }

    func testTunnelSessionListDecoding() throws {
        let json = """
        {
            "tunnel_sessions": [
                {
                    "id": "ts_1",
                    "ip": "10.0.0.1",
                    "region": "eu",
                    "started_at": "2026-03-12T10:00:00Z"
                }
            ],
            "next_page_uri": "/api/v1/next"
        }
        """.data(using: .utf8)!

        let list = try JSONDecoder().decode(TunnelSessionList.self, from: json)
        XCTAssertEqual(list.tunnelSessions.count, 1)
        XCTAssertEqual(list.nextPageURI, "/api/v1/next")
    }

    // MARK: - Endpoint

    func testEndpointDecoding() throws {
        let json = """
        {
            "id": "ep_abc123",
            "region": "us",
            "created_at": "2026-03-12T10:00:00Z",
            "proto": "https",
            "url": "https://example.ngrok.io",
            "upstream_url": "http://localhost:3000"
        }
        """.data(using: .utf8)!

        let endpoint = try JSONDecoder().decode(Endpoint.self, from: json)
        XCTAssertEqual(endpoint.id, "ep_abc123")
        XCTAssertEqual(endpoint.url, "https://example.ngrok.io")
        XCTAssertEqual(endpoint.upstreamURL, "http://localhost:3000")
    }

    func testEndpointListDecoding() throws {
        let json = """
        {
            "endpoints": [],
            "next_page_uri": null
        }
        """.data(using: .utf8)!

        let list = try JSONDecoder().decode(EndpointList.self, from: json)
        XCTAssertTrue(list.endpoints.isEmpty)
    }
}
