import Foundation

final class EndpointService {
    private let client: NgrokAPIClient

    init(client: NgrokAPIClient) {
        self.client = client
    }

    func listEndpoints() async throws -> [Endpoint] {
        let result = try await client.request(EndpointList.self, path: "/endpoints")
        return result.endpoints
    }

    func getEndpoint(id: String) async throws -> Endpoint {
        return try await client.request(Endpoint.self, path: "/endpoints/\(id)")
    }

    func deleteEndpoint(id: String) async throws {
        try await client.requestVoid(path: "/endpoints/\(id)", method: "DELETE")
    }
}
