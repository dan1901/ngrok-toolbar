import Foundation

struct TunnelSession: Codable, Identifiable {
    let id: String
    let agentVersion: String?
    let ip: String
    let region: String
    let startedAt: String
    let os: String?
    let transport: String?
    let metadata: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case id
        case agentVersion = "agent_version"
        case ip
        case region
        case startedAt = "started_at"
        case os
        case transport
        case metadata
        case uri
    }
}

struct TunnelSessionList: Codable {
    let tunnelSessions: [TunnelSession]
    let nextPageURI: String?

    enum CodingKeys: String, CodingKey {
        case tunnelSessions = "tunnel_sessions"
        case nextPageURI = "next_page_uri"
    }
}
