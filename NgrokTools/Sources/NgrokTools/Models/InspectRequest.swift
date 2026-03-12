import Foundation

struct InspectRequestList: Codable {
    let requests: [InspectRequest]
}

struct InspectRequest: Codable, Identifiable {
    let id: String
    let tunnelName: String
    let uri: String
    let start: String
    let duration: Int?
    let request: RequestDetail
    let response: ResponseDetail?

    enum CodingKeys: String, CodingKey {
        case id
        case tunnelName = "tunnel_name"
        case uri, start, duration, request, response
    }

    var startDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: start)
    }

    var timestampString: String {
        guard let date = startDate else { return start }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss"
        return fmt.string(from: date)
    }

    var durationMs: String {
        guard let d = duration else { return "-" }
        let ms = Double(d) / 1_000_000
        if ms < 1000 {
            return String(format: "%.0fms", ms)
        }
        return String(format: "%.1fs", ms / 1000)
    }
}

struct RequestDetail: Codable {
    let method: String
    let proto: String
    let headers: [String: [String]]
    let uri: String
    let raw: String?
}

struct ResponseDetail: Codable {
    let status: String
    let statusCode: Int
    let headers: [String: [String]]
    let raw: String?

    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status_code"
        case headers, raw
    }
}
