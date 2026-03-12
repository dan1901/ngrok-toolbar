import Foundation

final class TunnelService {
    private let client: NgrokAPIClient

    init(client: NgrokAPIClient) {
        self.client = client
    }

    func listTunnels() async throws -> [Tunnel] {
        let result = try await client.request(TunnelList.self, path: "/tunnels")
        return result.tunnels
    }

    func getTunnel(id: String) async throws -> Tunnel {
        return try await client.request(Tunnel.self, path: "/tunnels/\(id)")
    }
}
