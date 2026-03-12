import Foundation

struct NgrokAPIError: Decodable, Error, LocalizedError {
    let msg: String
    let statusCode: Int

    enum CodingKeys: String, CodingKey {
        case msg
        case statusCode = "status_code"
    }

    var errorDescription: String? { msg }
}

final class NgrokAPIClient {
    let baseURL: URL
    private let token: String
    private let session: URLSession

    init(token: String, session: URLSession = .shared) {
        self.baseURL = URL(string: "https://api.ngrok.com")!
        self.token = token
        self.session = session
    }

    func buildRequest(path: String, method: String, body: [String: Any]? = nil) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2", forHTTPHeaderField: "Ngrok-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    func request<T: Decodable>(_ type: T.Type, path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        let urlRequest = try buildRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(NgrokAPIError.self, from: data) {
                throw apiError
            }
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    func requestVoid(path: String, method: String, body: [String: Any]? = nil) async throws {
        let urlRequest = try buildRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(NgrokAPIError.self, from: data) {
                throw apiError
            }
            throw URLError(.badServerResponse)
        }
    }
}
