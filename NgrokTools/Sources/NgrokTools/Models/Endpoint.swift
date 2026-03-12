import Foundation

struct Endpoint: Codable, Identifiable {
    let id: String
    let region: String?
    let createdAt: String?
    let proto: String?
    let url: String?
    let upstreamURL: String?
    let metadata: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case id
        case region
        case createdAt = "created_at"
        case proto
        case url
        case upstreamURL = "upstream_url"
        case metadata
        case uri
    }
}

struct EndpointList: Codable {
    let endpoints: [Endpoint]
    let nextPageURI: String?

    enum CodingKeys: String, CodingKey {
        case endpoints
        case nextPageURI = "next_page_uri"
    }
}
