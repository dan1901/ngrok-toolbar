import Foundation

struct ReservedDomain: Codable, Identifiable {
    let id: String
    let uri: String?
    let domain: String
    let description: String?
    let metadata: String?
    let cnameTarget: String?

    enum CodingKeys: String, CodingKey {
        case id, uri, domain, description, metadata
        case cnameTarget = "cname_target"
    }
}

struct ReservedDomainList: Codable {
    let reservedDomains: [ReservedDomain]
    let nextPageURI: String?

    enum CodingKeys: String, CodingKey {
        case reservedDomains = "reserved_domains"
        case nextPageURI = "next_page_uri"
    }
}
