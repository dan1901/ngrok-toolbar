import Foundation

struct LocalTunnel: Codable {
    let name: String
    let publicURL: String
    let proto: String
    let config: LocalTunnelConfig?
    let metrics: LocalTunnelMetrics?

    enum CodingKeys: String, CodingKey {
        case name
        case publicURL = "public_url"
        case proto, config, metrics
    }
}

struct LocalTunnelConfig: Codable {
    let addr: String?
    let inspect: Bool?
}

struct LocalTunnelMetrics: Codable {
    let conns: MetricStats?
    let http: MetricStats?
}

struct MetricStats: Codable {
    let count: Int
    let gauge: Int?
    let rate1: Double?
    let rate5: Double?
    let rate15: Double?
    let p50: Double?
    let p90: Double?
    let p95: Double?
    let p99: Double?
}

struct LocalTunnelList: Codable {
    let tunnels: [LocalTunnel]
}

/// Each ngrok process runs its own inspect API on a different port (4040, 4041, ...).
/// This service scans ports to find the correct one for a given tunnel.
final class LocalInspectService {
    private static let portRange = 4040...4049

    /// Cached inspect port for a given public URL
    private var resolvedPort: Int?

    /// Find which inspect port serves a tunnel with the given publicURL
    func findInspectPort(forPublicURL publicURL: String) async -> Int? {
        if let cached = resolvedPort {
            // Verify cache is still valid
            if let tunnels = try? await fetchLocalTunnels(port: cached),
               tunnels.contains(where: { $0.publicURL == publicURL }) {
                return cached
            }
            resolvedPort = nil
        }

        for port in Self.portRange {
            guard let tunnels = try? await fetchLocalTunnels(port: port) else { continue }
            if tunnels.contains(where: { $0.publicURL == publicURL }) {
                resolvedPort = port
                return port
            }
        }
        return nil
    }

    func fetchRequests(port: Int, limit: Int = 50) async throws -> [InspectRequest] {
        guard let url = URL(string: "http://127.0.0.1:\(port)/api/requests/http?limit=\(limit)") else {
            throw LocalInspectError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 3

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LocalInspectError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(InspectRequestList.self, from: data)
        return decoded.requests
    }

    func fetchLocalTunnels(port: Int) async throws -> [LocalTunnel] {
        guard let url = URL(string: "http://127.0.0.1:\(port)/api/tunnels") else {
            throw LocalInspectError.invalidURL
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        let (data, _) = try await URLSession.shared.data(for: request)
        let list = try JSONDecoder().decode(LocalTunnelList.self, from: data)
        return list.tunnels
    }

    /// Stop a tunnel by scanning all inspect ports for the matching publicURL
    func stopTunnel(publicURL: String) async throws {
        guard let port = await findInspectPort(forPublicURL: publicURL) else {
            throw LocalInspectError.tunnelNotFound
        }

        let tunnels = try await fetchLocalTunnels(port: port)
        guard let tunnel = tunnels.first(where: { $0.publicURL == publicURL }) else {
            throw LocalInspectError.tunnelNotFound
        }

        let encodedName = tunnel.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tunnel.name
        guard let deleteURL = URL(string: "http://127.0.0.1:\(port)/api/tunnels/\(encodedName)") else { return }

        var deleteReq = URLRequest(url: deleteURL)
        deleteReq.httpMethod = "DELETE"
        deleteReq.timeoutInterval = 5

        let (_, response) = try await URLSession.shared.data(for: deleteReq)
        if let httpResp = response as? HTTPURLResponse, httpResp.statusCode >= 400 {
            throw LocalInspectError.httpError(httpResp.statusCode)
        }
    }

    /// Check if any inspect API is available
    func isAnyAvailable() async -> Bool {
        for port in Self.portRange {
            if await isAvailable(port: port) { return true }
        }
        return false
    }

    func isAvailable(port: Int) async -> Bool {
        guard let url = URL(string: "http://127.0.0.1:\(port)/api/tunnels") else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}

enum LocalInspectError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case tunnelNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid inspect API URL"
        case .invalidResponse: return "Invalid response from inspect API"
        case .httpError(let code): return "Inspect API returned \(code)"
        case .tunnelNotFound: return "Tunnel not found in local ngrok"
        }
    }
}
