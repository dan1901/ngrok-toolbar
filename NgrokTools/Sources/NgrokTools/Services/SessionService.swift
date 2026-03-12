import Foundation

final class SessionService {
    private let client: NgrokAPIClient

    init(client: NgrokAPIClient) {
        self.client = client
    }

    func listSessions() async throws -> [TunnelSession] {
        let result = try await client.request(TunnelSessionList.self, path: "/tunnel_sessions")
        return result.tunnelSessions
    }

    func getSession(id: String) async throws -> TunnelSession {
        return try await client.request(TunnelSession.self, path: "/tunnel_sessions/\(id)")
    }

    func restartSession(id: String) async throws {
        try await client.requestVoid(path: "/tunnel_sessions/\(id)/restart", method: "POST")
    }

    func stopSession(id: String) async throws {
        try await client.requestVoid(path: "/tunnel_sessions/\(id)/stop", method: "POST")
    }
}
