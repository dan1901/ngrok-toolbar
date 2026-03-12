import Foundation

struct Tunnel: Codable, Identifiable {
    let id: String
    let publicURL: String
    let startedAt: String
    let metadata: String?
    let proto: String
    let region: String
    let forwardsTo: String?

    enum CodingKeys: String, CodingKey {
        case id
        case publicURL = "public_url"
        case startedAt = "started_at"
        case metadata
        case proto
        case region
        case forwardsTo = "forwards_to"
    }
}

struct TunnelList: Codable {
    let tunnels: [Tunnel]
    let nextPageURI: String?

    enum CodingKeys: String, CodingKey {
        case tunnels
        case nextPageURI = "next_page_uri"
    }
}
