import Foundation

final class DomainService {
    private let client: NgrokAPIClient

    init(client: NgrokAPIClient) {
        self.client = client
    }

    func listDomains() async throws -> [ReservedDomain] {
        let result = try await client.request(ReservedDomainList.self, path: "/reserved_domains")
        return result.reservedDomains
    }
}
